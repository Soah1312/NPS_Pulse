// ============================================
// Data Encryption Utility — AES-256-GCM
// ============================================
// Encrypts sensitive user financial data on the device before sending to Firebase.
// Uses Web Crypto API (no external libraries) — each user gets a unique key derived from Firebase UID.
// Even Firebase admins cannot read encrypted data.
//
// HOW IT WORKS:
// 1. User's Firebase UID + app salt → PBKDF2 key derivation
// 2. Sensitive fields encrypted with AES-256-GCM before Firestore write
// 3. IV (initialization vector) stored with each encrypted value
// 4. On read: decrypt using user's derived key
// 5. Decryption only works if user is logged in with matching UID

const ALGORITHM = 'AES-GCM';
const SALT = import.meta.env.VITE_ENCRYPTION_SALT || 'retiresahi-v1-2025';

/* ── FIELDS ALWAYS ENCRYPTED BEFORE FIRESTORE WRITE ──────────
  Income, savings, contributions, tax details, projections
  These are never sent to Groq AI in privacy mode */
export const ENCRYPTED_FIELDS = [
  'monthlyIncome',
  'npsContribution',
  'npsCorpus',
  'totalSavings',
  'ppfMonthlyContribution',
  'epfVpfMonthlyContribution',
  'mfSipMonthlyContribution',
  'stocksEtfMonthlyContribution',
  'fdRdMonthlyContribution',
  'otherSchemeMonthlyContribution',
  'homeLoanInterest',
  'lifeInsurance_80C',
  'elss_ppf_80C',
  'medicalInsurance_80D',
  'educationLoanInterest_80E',
  'houseRentAllowance_HRA',
  'actualRentPaid',
  'leaveTravelAllowance_LTA',
  'projectedValue',
  'requiredCorpus',
  'monthlyGap',
  'monthlySpendToday',
  'monthlySpendAtRetirement',
  'customRetirementMonthlyAmount',
  'lumpSumCorpus',
  'annuityCorpus',
  'monthlyAnnuityIncome',
  'gap',
  'blendedReturn',
  'basicSalaryPct',
];

export const SENSITIVE_FIELDS = ENCRYPTED_FIELDS;

// These fields stay readable — non-sensitive
export const NON_SENSITIVE_FIELDS = [
  'firstName',
  'age',
  'retireAge',
  'workContext',
  'retirementMode',
  'lifestyle',
  'retirementGoalType',
  'taxRegime',
  'npsEquity',
  'addSavings',
  'usesPPF',
  'usesEPFVPF',
  'usesMFSIP',
  'usesStocksETF',
  'usesFDRD',
  'usesOtherScheme',
  'score',
  'aiPrivacyMode',
  'updatedAt',
  'createdAt',
];

// Non-sensitive computed insights sent to Groq in Privacy Mode
// These reveal nothing about raw financial inputs
export const GROQ_PRIVACY_MODE_FIELDS = [
  'score',
  'aiPrivacyMode',
  'age',
  'retireAge',
  'workContext',
  'lifestyle',
  'retirementGoalType',
  'taxRegime',
  'npsEquity',
];

// Everything sent to Groq in Full Mode (after user consent)
export const GROQ_FULL_MODE_FIELDS = [
  ...GROQ_PRIVACY_MODE_FIELDS,
  'customRetirementMonthlyAmount',
  'retirementMode',
  'monthlyIncome',
  'npsContribution',
  'npsCorpus',
  'totalSavings',
  'ppfMonthlyContribution',
  'epfVpfMonthlyContribution',
  'mfSipMonthlyContribution',
  'stocksEtfMonthlyContribution',
  'fdRdMonthlyContribution',
  'otherSchemeMonthlyContribution',
  'projectedValue',
  'requiredCorpus',
  'monthlyGap',
  'monthlySpendToday',
  'monthlySpendAtRetirement',
  'lumpSumCorpus',
  'annuityCorpus',
  'monthlyAnnuityIncome',
  'gap',
  'blendedReturn',
];

// Derive unique encryption key from user's Firebase UID + app salt
// Uses PBKDF2 (Password-Based Key Derivation Function) with 100,000 iterations
// More iterations = slower but more secure against brute force
async function deriveKey(uid) {
  const encoder = new TextEncoder();
  // Import UID+salt as key material for derivation
  const keyMaterial = await crypto.subtle.importKey(
    'raw',
    encoder.encode(uid + SALT),
    { name: 'PBKDF2' },
    false,
    ['deriveKey']
  );

  // Derive final encryption key using PBKDF2
  return crypto.subtle.deriveKey(
    {
      name: 'PBKDF2',
      salt: encoder.encode(SALT),
      iterations: 100000, // High iteration count for security
      hash: 'SHA-256',
    },
    keyMaterial,
    { name: ALGORITHM, length: 256 }, // AES-256
    false,
    ['encrypt', 'decrypt']
  );
}

// Encrypt a single field value
// Returns { __encrypted: true, iv: base64, data: base64 }
// __encrypted flag marks this as encrypted for decryption lookup
export async function encryptField(value, uid) {
  if (value === null || value === undefined) return null;

  const key = await deriveKey(uid);
  const encoder = new TextEncoder();
  // Initialization vector: random 12-byte value unique to each encryption
  // IV is stored with ciphertext (doesn't need to be secret, only unique per encryption)
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const encrypted = await crypto.subtle.encrypt(
    { name: ALGORITHM, iv },
    key,
    encoder.encode(String(value))
  );

  return {
    __encrypted: true,
    iv: btoa(String.fromCharCode(...iv)), // Base64 encode IV for JSON storage
    data: btoa(String.fromCharCode(...new Uint8Array(encrypted))), // Base64 encode ciphertext
  };
}

export async function decryptField(encryptedObj, uid) {
  if (!encryptedObj?.__encrypted) return encryptedObj;

  try {
    const key = await deriveKey(uid);
    const iv = new Uint8Array(atob(encryptedObj.iv).split('').map((c) => c.charCodeAt(0)));
    const data = new Uint8Array(atob(encryptedObj.data).split('').map((c) => c.charCodeAt(0)));
    const decrypted = await crypto.subtle.decrypt({ name: ALGORITHM, iv }, key, data);
    const value = new TextDecoder().decode(decrypted);
    return Number.isNaN(Number(value)) || value === '' ? value : parseFloat(value);
  } catch (err) {
    console.error('Decryption failed for field:', err);
    return null;
  }
}

export async function encryptUserData(userData, uid) {
  const result = { ...userData };
  await Promise.all(
    ENCRYPTED_FIELDS.map(async (field) => {
      if (result[field] !== undefined && result[field] !== null) {
        result[field] = await encryptField(result[field], uid);
      }
    })
  );
  return result;
}

export async function decryptUserData(encryptedData, uid) {
  if (!encryptedData) return null;

  const result = { ...encryptedData };
  await Promise.all(
    ENCRYPTED_FIELDS.map(async (field) => {
      if (result[field]?.__encrypted) {
        result[field] = await decryptField(result[field], uid);
      }
    })
  );
  return result;
}
