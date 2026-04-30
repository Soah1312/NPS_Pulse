// ============================================
// Auth Session Provider
// ============================================
// Global auth state management for the entire app.
// Watches Firebase auth state changes and provides currentUser + authLoading
// to all components via AuthSessionContext.
//
// Usage: const { currentUser, authLoading } = useAuthSession();

import { useEffect, useMemo, useState } from 'react';
import { onAuthStateChanged } from 'firebase/auth';
import { auth } from '../lib/firebase';
import { AuthSessionContext } from './authSessionContext';

export function AuthSessionProvider({ children }) {
  const hasAuthInstance = Boolean(auth);
  const [currentUser, setCurrentUser] = useState(null);
  const [authLoading, setAuthLoading] = useState(hasAuthInstance);

  useEffect(() => {
    // Skip if Firebase isn't initialized
    if (!hasAuthInstance) {
      return undefined;
    }

    // Subscribe to auth state changes
    // This fires immediately with the current user (or null if logged out)
    // and again whenever user logs in/out
    const unsubscribe = onAuthStateChanged(auth, (user) => {
      setCurrentUser(user);
      setAuthLoading(false); // Auth check complete
    });

    // Cleanup listener on unmount
    return () => unsubscribe();
  }, [hasAuthInstance]);

  // Memoize value to prevent unnecessary re-renders
  const value = useMemo(
    () => ({ currentUser, authLoading }),
    [currentUser, authLoading]
  );

  // Provide auth state to entire app
  return (
    <AuthSessionContext.Provider value={value}>
      {children}
    </AuthSessionContext.Provider>
  );
}
