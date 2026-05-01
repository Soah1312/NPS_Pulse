/**
 * @file groq.js
 * @description Serverless function for handling chat completion requests to the Groq API.
 * This file handles user authentication via Firebase, rate limiting to prevent abuse,
 * fallback mechanisms for the LLMs, and streams the responses back to the client.
 */

import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

// ── Configuration Variables ────────────────────────────────────────────────────────
const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';
// Primary and fallback models for the chat functionality
// Keep these aligned with the frontend defaults so local and deployed behavior match.
const PRIMARY_MODEL = getEnv('GROQ_PRIMARY_MODEL') || 'qwen-2.5-32b';
const FALLBACK_MODEL = getEnv('GROQ_FALLBACK_MODEL') || 'llama-3.3-70b-versatile';

// ── Rate Limiting & Message Constraints ────────────────────────────────────────────
const MAX_MESSAGES = 12; // Maximum number of past messages to send for context
const MAX_CHARS_PER_MESSAGE = 6000; // Limit length to prevent extreme payloads
const RATE_LIMIT_MAX = 10;       // Max requests allowed per user
const RATE_LIMIT_WINDOW_MS = 60 * 1000; // Time window (1 minute)

// In-memory store for rate limiting (Mapping of UID -> array of timestamps)
// Note: In serverless environments, this memory state might reset on cold starts.
const rateLimitStore = new Map();

/**
 * Checks if the user (by UID) has exceeded the rate limit.
 * Throws an error with a retry time if the limit is exceeded.
 * @param {string} uid - The Firebase User ID
 */
function checkRateLimit(uid) {
  const now = Date.now();
  const windowStart = now - RATE_LIMIT_WINDOW_MS;
  
  // Filter out timestamps older than the 1-minute window
  const timestamps = (rateLimitStore.get(uid) || []).filter(t => t > windowStart);
  
  if (timestamps.length >= RATE_LIMIT_MAX) {
    const oldestInWindow = timestamps[0];
    const retryAfterMs = RATE_LIMIT_WINDOW_MS - (now - oldestInWindow);
    // Throw an error indicating the user must wait
    throw Object.assign(new Error('RATE_LIMITED'), { retryAfterMs });
  }
  
  // Record the new request timestamp
  timestamps.push(now);
  rateLimitStore.set(uid, timestamps);
}

/**
 * Utility to safely retrieve environment variables.
 * @param {string} name - The name of the environment variable.
 * @returns {string} The trimmed environment variable value or an empty string.
 */
function getEnv(name) {
  const value = process.env[name];
  return typeof value === 'string' ? value.trim() : '';
}

/**
 * Sets Cross-Origin Resource Sharing (CORS) headers to allow the frontend to access this API.
 * @param {object} req - The HTTP request object.
 * @param {object} res - The HTTP response object.
 */
function setCorsHeaders(req, res) {
  const origin = req.headers.origin || '';

  if (origin) {
    res.setHeader('Access-Control-Allow-Origin', origin);
  }

  res.setHeader('Vary', 'Origin');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Firebase-Auth, X-Firebase-Token');
}

/**
 * Determines if the request originated from a local development environment.
 * Useful for bypassing certain strict production checks during local testing.
 * @param {object} req - The HTTP request object.
 * @returns {boolean} True if the request comes from localhost.
 */
function isLocalhostRequest(req) {
  const hostHeader = Array.isArray(req.headers.host) ? req.headers.host[0] : (req.headers.host || '');
  const xfHostHeader = Array.isArray(req.headers['x-forwarded-host'])
    ? req.headers['x-forwarded-host'][0]
    : (req.headers['x-forwarded-host'] || '');

  const host = `${hostHeader} ${xfHostHeader}`.toLowerCase();
  return host.includes('localhost') || host.includes('127.0.0.1') || host.includes('[::1]');
}

/**
 * Initializes and returns the Firebase Admin Authentication instance.
 * Ensures the app is only initialized once to prevent errors.
 * @returns {import('firebase-admin/auth').Auth}
 */
function getFirebaseAuth() {
  const projectId = getEnv('FIREBASE_PROJECT_ID');
  const clientEmail = getEnv('FIREBASE_CLIENT_EMAIL');
  let privateKey = getEnv('FIREBASE_PRIVATE_KEY');

  // Strip extraneous quotes that might come from .env parsing
  if (privateKey.startsWith('"') && privateKey.endsWith('"')) {
    privateKey = privateKey.slice(1, -1);
  }

  // Handle escaped newlines properly so the private key is valid PEM format
  privateKey = privateKey.replace(/\\n/g, '\n');

  // Ensure all necessary Firebase config properties exist
  if (!projectId || !clientEmail || !privateKey) {
    console.error('Missing Firebase config:', { projectId: !!projectId, clientEmail: !!clientEmail, privateKey: !!privateKey });
    throw new Error('FIREBASE_ADMIN_CONFIG_MISSING');
  }

  // Initialize Firebase App if it hasn't been initialized yet
  if (!getApps().length) {
      try {
        initializeApp({
          credential: cert({
            projectId,
            clientEmail,
            privateKey,
          }),
        });
      } catch (err) {
        console.error('Firebase init error:', err.message);
        throw err;
      }
  }

  return getAuth();
}

/**
 * Cleans and validates the incoming chat messages array.
 * Enforces role types, message lengths, and total message counts.
 * @param {Array} input - Raw messages array from the client.
 * @returns {Array} Sanitized array of messages suitable for the LLM.
 */
function normalizeMessages(input) {
  if (!Array.isArray(input)) {
    throw new Error('INVALID_MESSAGES');
  }

  // Only take the last MAX_MESSAGES to prevent exceeding token limits
  return input
    .slice(-MAX_MESSAGES)
    .map((message) => {
      const role = typeof message?.role === 'string' ? message.role : '';
      const content = typeof message?.content === 'string' ? message.content : '';

      // Validate roles
      if (!['system', 'user', 'assistant'].includes(role)) {
        throw new Error('INVALID_MESSAGE_ROLE');
      }

      // Validate content isn't empty or excessively long
      if (!content.trim() || content.length > MAX_CHARS_PER_MESSAGE) {
        throw new Error('INVALID_MESSAGE_CONTENT');
      }

      return { role, content };
    });
}

/**
 * Safely parses the JSON body of the incoming request.
 * @param {object} req - The HTTP request object.
 * @returns {object} Parsed JSON body or an empty object.
 */
function parseRequestBody(req) {
  if (typeof req.body === 'string') {
    try {
      return JSON.parse(req.body);
    } catch {
      return {};
    }
  }

  if (req.body && typeof req.body === 'object') {
    return req.body;
  }

  return {};
}

/**
 * Relays an active stream from the Groq API back to the client.
 * Decodes the chunks coming from Groq and immediately writes them to the HTTP response.
 * @param {object} groqResponse - The fetch response from Groq.
 * @param {object} res - The HTTP response object to write to.
 * @param {object} streamMeta - Optional metadata to prepend before streaming data starts.
 */
async function relayGroqStream(groqResponse, res, streamMeta = null) {
  if (!groqResponse.body) {
    throw new Error('STREAM_BODY_MISSING');
  }

  // Set necessary headers for Server-Sent Events (SSE) streaming
  res.setHeader('Content-Type', 'text/event-stream; charset=utf-8');
  res.setHeader('Cache-Control', 'no-store');
  res.setHeader('Connection', 'keep-alive');
  res.setHeader('X-Accel-Buffering', 'no'); // Disable buffering in some proxies

  if (typeof res.flushHeaders === 'function') {
    res.flushHeaders();
  }

  // Send metadata (like which model is being used) before the content
  if (streamMeta) {
    res.write(`data: ${JSON.stringify({ type: 'meta', ...streamMeta })}\n\n`);
  }

  const reader = groqResponse.body.getReader();
  const decoder = new TextDecoder();

  // Continuously read the stream and pipe chunks to the client
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    const chunk = decoder.decode(value, { stream: true });
    if (chunk) {
      res.write(chunk);
    }
  }

  // End the response once streaming finishes
  res.end();
}

/**
 * Makes an API call to Groq with a specific model.
 * @param {string} groqApiKey - The authentication key for Groq.
 * @param {string} model - The specific model to use (e.g., 'qwen/qwen3-32b').
 * @param {Array} messages - Chat history.
 * @param {boolean} stream - Whether to stream the response.
 * @returns {Promise<Response>} Fetch API Response object.
 */
async function callGroqWithModel(groqApiKey, model, messages, stream) {
  const response = await fetch(GROQ_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${groqApiKey}`,
    },
    body: JSON.stringify({
      model,
      messages,
      temperature: 0.7, // Creativity level
      max_tokens: 1024, // Limit size of the output
      stream,
    }),
  });

  return response;
}

/**
 * Determines the order of models to try.
 * @param {boolean} forceFallback - If true, tries the fallback model first.
 * @returns {Array<string>} List of unique model identifiers to try.
 */
function getModelOrder(forceFallback = false) {
  const ordered = forceFallback
    ? [FALLBACK_MODEL, PRIMARY_MODEL]
    : [PRIMARY_MODEL, FALLBACK_MODEL];

  return [...new Set(ordered.filter(Boolean))];
}

/**
 * Calls the Groq API and handles model fallbacks if the primary model fails.
 * Ensures high availability by silently switching models if one is down.
 * @param {string} groqApiKey - Groq API Key.
 * @param {Array} messages - Formatted message list.
 * @param {boolean} stream - Whether to stream.
 * @param {object} options - Options like forcing a fallback model.
 * @returns {Promise<object>} Result containing ok status, response, model used, and attempt logs.
 */
async function callGroqWithFallback(groqApiKey, messages, stream, options = {}) {
  const forceFallback = Boolean(options.forceFallback);
  const models = getModelOrder(forceFallback);
  const attempts = [];
  let lastResponse = null;

  // Try models in order until one succeeds
  for (const model of models) {
    try {
      const response = await callGroqWithModel(groqApiKey, model, messages, stream);

      if (response.ok) {
        return { ok: true, response, model, attempts };
      }

      // If failed, log the error and loop to try the next model
      const errorData = await response.json().catch(() => ({}));
      attempts.push({
        model,
        status: response.status,
        error: errorData?.error?.message || 'Groq request failed',
      });
      lastResponse = response;
    } catch (error) {
      // Catch network errors entirely
      attempts.push({
        model,
        status: 0,
        error: error?.message || 'Network error while calling model',
      });
    }
  }

  // All models failed
  return {
    ok: false,
    response: lastResponse,
    attempts,
  };
}

/**
 * Extracts and verifies the Firebase auth token from the incoming request.
 * @param {object} req - HTTP request.
 * @param {object} body - Parsed JSON body.
 * @returns {Promise<object>} The decoded user object if verification succeeds.
 */
async function verifyUserFromRequest(req, body = {}) {
  // Check standard Authorization header first
  const authHeader = Array.isArray(req.headers.authorization)
    ? req.headers.authorization[0]
    : (req.headers.authorization || '');
  const bearerToken = authHeader.startsWith('Bearer ') ? authHeader.slice(7) : '';

  // Fallbacks: Custom headers or body token
  const fallbackHeader = req.headers['x-firebase-auth'] || req.headers['x-firebase-token'] || '';
  const fallbackToken = Array.isArray(fallbackHeader) ? fallbackHeader[0] : fallbackHeader;
  const bodyToken = typeof body?.idToken === 'string' ? body.idToken : '';
  
  const token = (bearerToken || fallbackToken || bodyToken || '').trim();

  if (!token) {
    throw new Error('AUTH_REQUIRED');
  }

  const adminAuth = getFirebaseAuth();
  try {
    // Standard validation using Firebase Admin SDK
    return await adminAuth.verifyIdToken(token);
  } catch (adminErr) {
    // In some dev environments, Admin SDK verification fails (clock skew, proxy, etc.).
    // Fall back to verifying via Firebase Auth REST API if available.
    const webApiKey = getEnv('FIREBASE_WEB_API_KEY') || getEnv('VITE_FIREBASE_API_KEY');
    if (!webApiKey) {
      throw new Error('AUTH_INVALID');
    }

    const lookupResponse = await fetch(
      `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${encodeURIComponent(webApiKey)}`,
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idToken: token }),
      }
    );

    const lookupData = await lookupResponse.json().catch(() => ({}));
    if (!lookupResponse.ok || !Array.isArray(lookupData.users) || !lookupData.users[0]?.localId) {
      console.error('Firebase token validation failed:', adminErr?.message || 'verifyIdToken failed');
      throw new Error('AUTH_INVALID');
    }

    return {
      uid: lookupData.users[0].localId,
      email: lookupData.users[0].email,
      fallbackValidated: true, // Mark it so we know how it was validated
    };
  }
}

/**
 * Main Serverless Handler.
 * This function handles CORS, authentication, parsing, calling Groq (with rate limits and fallback),
 * and responding to the client (standard JSON or Stream).
 */
export default async function handler(req, res) {
  // Do not allow caching of this endpoint
  res.setHeader('Cache-Control', 'no-store');
  setCorsHeaders(req, res);
  
  const isLocalDebug = getEnv('NODE_ENV') !== 'production';
  const isLocalhost = isLocalhostRequest(req);

  // Handle preflight CORS request
  if (req.method === 'OPTIONS') {
    return res.status(204).end();
  }

  // Only allow POST method
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const body = parseRequestBody(req);

    // Verify Firebase Auth unless it's a localhost testing request
    let decodedUser = null;
    if (!isLocalhost) {
      decodedUser = await verifyUserFromRequest(req, body);
    }

    // Apply rate limiting based on the User ID
    if (decodedUser?.uid) {
      checkRateLimit(decodedUser.uid);
    }

    // Prepare inputs
    const messages = normalizeMessages(body.messages);
    const stream = Boolean(body.stream);
    // Allow the frontend to explicitly request the fallback model in any environment.
    // The API still prefers the primary model first unless /fallback is used.
    const forceFallback = Boolean(body.forceFallback);

    const groqApiKey = getEnv('GROQ_API_KEY');
    if (!groqApiKey) {
      return res.status(503).json({ code: 'SERVER_MISCONFIGURED', error: 'Groq API key is not configured on the server.' });
    }

    // Attempt the API request using primary/fallback mechanism
    const groqResult = await callGroqWithFallback(groqApiKey, messages, stream, { forceFallback });

    // If both models failed, return an error block
    if (!groqResult.ok) {
      const status = groqResult.response?.status || 502;
      const lastError = groqResult.attempts[groqResult.attempts.length - 1]?.error || 'Groq request failed';
      return res.status(status).json({
        error: lastError,
        attempts: groqResult.attempts,
      });
    }

    const groqResponse = groqResult.response;
    const servedModel = groqResult.model;
    const fallbackUsed = servedModel !== PRIMARY_MODEL;

    // Output Mode 1: Streaming
    if (stream) {
      await relayGroqStream(groqResponse, res, {
        model: servedModel,
        primaryModel: PRIMARY_MODEL,
        fallbackModel: FALLBACK_MODEL,
        fallbackUsed,
        forceFallback,
      });
      return;
    }

    // Output Mode 2: Standard JSON Request/Response
    const groqData = await groqResponse.json();

    return res.status(200).json({
      content: groqData?.choices?.[0]?.message?.content || '',
      model: servedModel,
      fallbackUsed,
    });
    
  } catch (error) {
    // Handle predefined error types appropriately
    if (error.message === 'RATE_LIMITED') {
      const retryAfter = Math.ceil((error.retryAfterMs || RATE_LIMIT_WINDOW_MS) / 1000);
      res.setHeader('Retry-After', retryAfter);
      return res.status(429).json({
        error: `Slow down! You've hit the limit of ${RATE_LIMIT_MAX} messages per minute. Try again in ${retryAfter}s.`,
        code: 'RATE_LIMITED',
        retryAfterSeconds: retryAfter,
      });
    }

    if (error.message === 'AUTH_REQUIRED') {
      return res.status(401).json({
        error: 'Authentication required.',
        ...(isLocalDebug ? { debug: 'AUTH_REQUIRED_NO_TOKEN' } : {}),
      });
    }

    if (error.message === 'AUTH_INVALID') {
      return res.status(401).json({
        error: 'Authentication token is invalid or expired.',
        ...(isLocalDebug ? { debug: 'AUTH_INVALID_VERIFY_FAILED' } : {}),
      });
    }

    if (error.message === 'FIREBASE_ADMIN_CONFIG_MISSING') {
      return res.status(503).json({
        code: 'SERVER_MISCONFIGURED',
        error: 'Firebase Admin environment variables are missing on the server.',
        ...(isLocalDebug ? { debug: 'FIREBASE_ENV_MISSING' } : {}),
      });
    }

    if (error.message?.startsWith('INVALID_')) {
      return res.status(400).json({ error: 'Invalid request payload.' });
    }

    // Catch-all 500 error
    return res.status(500).json({
      error: 'Internal server error.',
      ...(isLocalDebug ? { debug: error?.message || 'UNKNOWN' } : {}),
    });
  }
}

