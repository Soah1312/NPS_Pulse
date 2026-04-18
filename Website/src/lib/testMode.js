/**
 * Test mode utilities for identifying and managing test accounts
 */

export const isTestAccount = (email) => {
  if (!email || typeof email !== 'string') return false;
  return /^test[0-9]*@gmail\.com$/i.test(email);
};

export const TEST_ACCOUNT_EMAILS = [
  'test1@gmail.com',
  'test2@gmail.com',
  'test3@gmail.com',
];

export const TEST_ACCOUNT_PASSWORD = '123456';
