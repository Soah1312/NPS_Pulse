// ============================================
// Test Mode Utilities
// ============================================
// Helpers for managing and identifying test accounts.
// Used during QA and development to create test data without cluttering real user data.
//
// TEST ACCOUNT NAMING: All test accounts follow pattern test[0-9]*@gmail.com
// TEST PASSWORD: Same for all test accounts (insecure, never use in production)
// USAGE: Use these accounts to test onboarding, retirement calculations, etc.

/**
 * Checks if an email address belongs to a test account.
 * Pattern: test0@gmail.com, test1@gmail.com, test2@gmail.com, etc.
 * @param {string} email - The email to check
 * @returns {boolean} True if this is a test account email
 */
export const isTestAccount = (email) => {
  // Input validation: must be a non-empty string
  if (!email || typeof email !== 'string') return false;
  
  // Test pattern: starts with "test", optional number, ends with "@gmail.com" (case-insensitive)
  return /^test[0-9]*@gmail\.com$/i.test(email);
};

/**
 * List of pre-created test accounts for QA team to use.
 * These accounts have dummy data and can be deleted/recreated freely.
 */
export const TEST_ACCOUNT_EMAILS = [
  'test1@gmail.com',
  'test2@gmail.com',
  'test3@gmail.com',
];

/**
 * Standard password for all test accounts.
 * WARNING: This is intentionally weak and simple for testing only.
 * Never use in production or for real user data.
 */
export const TEST_ACCOUNT_PASSWORD = '123456';
