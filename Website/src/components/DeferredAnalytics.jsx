// ============================================
// Deferred Analytics Loader
// ============================================
// Lazily loads Vercel Analytics only in production.
//
// WHY DEFER LOADING:
// - Analytics library adds ~5KB to bundle
// - Not needed during local development
// - Lazy loading means it doesn't block page render
// - Dynamic import waits until React is ready
//
// RESULT: Users see content faster, analytics loads silently in background

import { useEffect, useState } from 'react';

/**
 * Conditionally loads analytics only in production environment.
 * Uses dynamic import to avoid bundling analytics code during development.
 */
export default function DeferredAnalytics() {
  const [AnalyticsComponent, setAnalyticsComponent] = useState(null);

  useEffect(() => {
    // Skip analytics in development (ENV variable PROD only true in production build)
    if (!import.meta.env.PROD) return;

    // Track component mount state to prevent memory leaks
    let isMounted = true;

    // Dynamically import analytics only when needed
    // This keeps it out of the main bundle and loads it asynchronously
    import('@vercel/analytics/react').then((mod) => {
      // Only set state if component is still mounted (prevents error if unmounted)
      if (isMounted) {
        setAnalyticsComponent(() => mod.Analytics); // Store as function for lazy evaluation
      }
    });

    // Cleanup: Mark component as unmounted to prevent state updates on unmounted component
    return () => {
      isMounted = false;
    };
  }, []); // Empty dependency array: runs once on mount only

  // Don't render anything until analytics module is loaded
  // (This prevents errors if component unmounts before async import completes)
  if (!AnalyticsComponent) return null;

  // Render the analytics component once loaded
  return <AnalyticsComponent />;
}
