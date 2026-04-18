#!/usr/bin/env node

/**
 * Script to create 3 test accounts in Firebase
 * Usage: node scripts/create-test-accounts.js
 */

import pkg from 'firebase-admin';

const admin = pkg;
import * as fs from 'fs';
import * as path from 'path';
import { fileURLToPath } from 'url';

// Load .env.local manually
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const envPath = path.join(__dirname, '../.env.local');
const envContent = fs.readFileSync(envPath, 'utf-8');
const envVars = {};
envContent.split('\n').forEach(line => {
  const match = line.match(/^([^=]+)=(.*)$/);
  if (match) {
    let value = match[2].trim();
    // Remove quotes if present
    if ((value.startsWith('"') && value.endsWith('"')) || (value.startsWith("'") && value.endsWith("'"))) {
      value = value.slice(1, -1);
    }
    envVars[match[1].trim()] = value;
  }
});

// Initialize Firebase Admin SDK
const serviceAccount = {
  type: "service_account",
  project_id: envVars.FIREBASE_PROJECT_ID || "retiresahi",
  private_key_id: "key-id",
  private_key: (envVars.FIREBASE_PRIVATE_KEY || "").replace(/\\n/g, '\n'),
  client_email: envVars.FIREBASE_CLIENT_EMAIL || "firebase-adminsdk-fbsvc@retiresahi.iam.gserviceaccount.com",
  client_id: "123",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
};

console.log('Initializing Firebase Admin SDK...');
console.log('Project ID:', envVars.FIREBASE_PROJECT_ID || "retiresahi");
console.log('Client Email:', envVars.FIREBASE_CLIENT_EMAIL);

try {
  const app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    projectId: envVars.FIREBASE_PROJECT_ID || "retiresahi",
  });
  console.log('Firebase App initialized successfully');
} catch (error) {
  console.log('Firebase App already initialized or error:', error.message);
}

const TEST_ACCOUNTS = [
  { email: 'test1@gmail.com', password: '123456' },
  { email: 'test2@gmail.com', password: '123456' },
  { email: 'test3@gmail.com', password: '123456' },
];

async function createTestAccounts() {
  const auth = admin.auth();
  const db = admin.firestore();
  
  console.log('Creating test accounts...\n');

  for (const account of TEST_ACCOUNTS) {
    try {
      // Check if user already exists
      let existingUser;
      try {
        existingUser = await auth.getUserByEmail(account.email);
      } catch (e) {
        existingUser = null;
      }

      if (existingUser) {
        console.log(`✓ ${account.email} already exists (UID: ${existingUser.uid})`);
      } else {
        // Create new user
        const userRecord = await auth.createUser({
          email: account.email,
          password: account.password,
          displayName: account.email.replace('@gmail.com', ''),
        });

        // Also create an empty user doc in Firestore so they can complete onboarding
        await db.collection('users').doc(userRecord.uid).set({
          email: account.email,
          createdAt: new Date().toISOString(),
          isTestAccount: true,
        }, { merge: true });

        console.log(`✓ Created ${account.email} (UID: ${userRecord.uid})`);
      }
    } catch (error) {
      console.error(`✗ Error creating ${account.email}:`, error.message);
    }
  }

  console.log('\nTest accounts setup complete!');
  console.log('Credentials to share with testers:');
  TEST_ACCOUNTS.forEach(acc => {
    console.log(`  Email: ${acc.email}`);
    console.log(`  Password: ${acc.password}`);
    console.log();
  });

  process.exit(0);
}

createTestAccounts().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
