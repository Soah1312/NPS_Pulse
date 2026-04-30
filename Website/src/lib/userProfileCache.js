// ============================================
// User Profile Cache — In-Memory Caching
// ============================================
// Reduces redundant Firestore reads by caching user profile in memory.
// Cache expires after 5 minutes (default TTL).
// Prevents multiple simultaneous loads of same user (deduplication).
//
// USAGE:
// Instead of: const profile = await loadUserProfile(uid)  [hits Firestore every time]
// Use this: const profile = await getOrLoadUserProfile({ uid, loader: loadUserProfile, ttlMs: 5*60*1000 })
// Result: Returns cached copy if fresh, fetches once if multiple requests race

const DEFAULT_TTL_MS = 5 * 60 * 1000; // 5 minutes

const profileCache = new Map(); // In-memory store: { uid -> { data, timestamp } }
const inflightLoads = new Map(); // Track in-flight Firestore promises to prevent duplicate requests

// Clone object to prevent external mutations of cached data
function cloneProfile(data) {
  if (!data || typeof data !== 'object') return data;
  return { ...data };
}

// Read from cache if it exists and hasn't expired
export function readUserProfileCache(uid, ttlMs = DEFAULT_TTL_MS) {
  if (!uid) return null;

  const entry = profileCache.get(uid);
  if (!entry) return null;

  // Check if cache is stale (older than TTL)
  if (Date.now() - entry.timestamp > ttlMs) {
    profileCache.delete(uid);
    return null;
  }

  // Return a clone to prevent accidental mutations
  return cloneProfile(entry.data);
}

// Store profile in cache with current timestamp
export function writeUserProfileCache(uid, profile) {
  if (!uid || !profile) return;

  profileCache.set(uid, {
    data: cloneProfile(profile),
    timestamp: Date.now(),
  });
}

// Clear cache for specific user or entire cache
export function invalidateUserProfileCache(uid) {
  if (uid) {
    profileCache.delete(uid);
    inflightLoads.delete(uid);
    return;
  }

  // No UID provided = clear all cache
  profileCache.clear();
  inflightLoads.clear();
}

// Get cached profile or load it once if multiple requests hit simultaneously
// This prevents thundering herd problem: 5 components asking for same profile = 1 Firestore read
export async function getOrLoadUserProfile({ uid, loader, ttlMs = DEFAULT_TTL_MS }) {
  // Check cache first
  const cached = readUserProfileCache(uid, ttlMs);
  if (cached) return cached;

  // If another request is already loading this user, wait for it
  if (inflightLoads.has(uid)) {
    return inflightLoads.get(uid);
  }

  // New load: fetch once and cache the result
  const loadPromise = (async () => {
    const loaded = await loader();
    if (loaded) {
      writeUserProfileCache(uid, loaded);
    }
    return loaded;
  })().finally(() => {
    // Clean up inflight tracking after load completes
    inflightLoads.delete(uid);
  });

  inflightLoads.set(uid, loadPromise);
  return loadPromise;
}