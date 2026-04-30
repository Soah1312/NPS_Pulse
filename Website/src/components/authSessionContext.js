// ============================================
// Auth Session Context
// ============================================
// Global React context for authentication state.
// Provides currentUser and authLoading to all components.
//
// WHAT IT STORES:
// - currentUser: Firebase user object (null if logged out)
// - authLoading: boolean indicating if auth check is still in progress
//
// USAGE:
// import { useAuthSession } from './authSessionContext'
// const { currentUser, authLoading } = useAuthSession()

import { createContext, useContext } from 'react';

/**
 * React Context for sharing auth state across the app.
 * Created by AuthSessionProvider, consumed by useAuthSession hook.
 */
export const AuthSessionContext = createContext({
  currentUser: null,    // Firebase User object from onAuthStateChanged
  authLoading: true,    // True while checking auth status, false once done
});

/**
 * Hook to access authentication state from anywhere in the app.
 * Must be used inside a component wrapped by <AuthSessionProvider>.
 * @returns {object} { currentUser, authLoading }
 * @throws {Error} If used outside AuthSessionProvider
 */
export function useAuthSession() {
  return useContext(AuthSessionContext);
}
