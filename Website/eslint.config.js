// ============================================
// ESLint Configuration
// ============================================
// Defines code quality rules and standards for the entire project.
//
// PURPOSE:
// - Prevents common JavaScript/React mistakes (unused variables, improper hooks usage)
// - Enforces code style consistency across all developers
// - Catches bugs before code review or runtime
//
// RULES EXPLAINED:
// - ESLint recommended: Essential rules for error prevention
// - React Hooks plugin: Ensures hooks (useState, useEffect) are used correctly
// - React Fast Refresh: Allows hot module reloading during development
// - no-unused-vars: Allows uppercase or underscore-prefixed variables (typically constants/types)

import js from '@eslint/js'
import globals from 'globals'
import reactHooks from 'eslint-plugin-react-hooks'
import reactRefresh from 'eslint-plugin-react-refresh'
import { defineConfig, globalIgnores } from 'eslint/config'

export default defineConfig([
  // Don't lint the output build directory (it's generated code)
  globalIgnores(['dist']),
  
  // Backend API files use Node.js globals (no browser APIs available)
  {
    files: ['api/**/*.js'],
    languageOptions: {
      globals: {
        ...globals.node,
      },
    },
  },
  
  // Frontend React files use both browser and modern JavaScript features
  {
    files: ['**/*.{js,jsx}'],
    // Apply recommended rules from ESLint + React plugins
    extends: [
      js.configs.recommended,              // Core ESLint rules
      reactHooks.configs.flat.recommended, // React hooks rules (useEffect, useState, etc)
      reactRefresh.configs.vite,           // React Fast Refresh support
    ],
    languageOptions: {
      ecmaVersion: 2020,           // Supports ES2020 features
      globals: globals.browser,    // Browser APIs (document, window, fetch, etc)
      parserOptions: {
        ecmaVersion: 'latest',     // Support latest JavaScript features
        ecmaFeatures: { jsx: true }, // Enable JSX syntax
        sourceType: 'module',      // ES6 modules (import/export)
      },
    },
    rules: {
      // Allow variables like 'CONSTANT' or '_unused' without errors
      // This is useful for constants and intentionally unused parameters
      'no-unused-vars': ['error', { varsIgnorePattern: '^[A-Z_]' }],
    },
  },
])
