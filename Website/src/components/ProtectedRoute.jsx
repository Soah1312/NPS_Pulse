// ============================================
// Protected Route Guard
// ============================================
// Wraps authenticated pages to block access if user is not logged in.
// If user is not authenticated, redirects to landing page.
// Shows loading spinner while auth state is being determined.
//
// Usage: <ProtectedRoute><Dashboard /></ProtectedRoute>

import React, { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuthSession } from './authSessionContext';

export default function ProtectedRoute({ children }) {
  const navigate = useNavigate();
  const { currentUser, authLoading } = useAuthSession();

  useEffect(() => {
    // Once auth check is done and user is not authenticated, redirect to landing
    if (!authLoading && !currentUser) {
      navigate('/');
    }
  }, [authLoading, currentUser, navigate]);

  // Show loading spinner while auth state is being determined
  if (authLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FFFDF5]">
        <div className="animate-pulse flex flex-col items-center">
          <div className="w-16 h-16 bg-[#8B5CF6]/20 rounded-full mb-4" />
          <div className="h-4 w-32 bg-slate-200 rounded" />
        </div>
      </div>
    );
  }

  // Don't render anything while redirecting
  if (!currentUser) {
    return null;
  }

  // Auth passed — render the protected page
  return children;
}
