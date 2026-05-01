// ============================================
// App Router & Layout Configuration
// ============================================
// This file sets up the main app structure with:
// - AuthSessionProvider: Manages user auth state globally
// - BrowserRouter: Enables client-side routing
// - SeoHead: Manages SEO meta tags per page
// - Lazy-loaded pages: Code-split for faster initial load
// - ProtectedRoute: Guards authenticated pages behind auth check

import { Suspense, lazy } from 'react';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import ProtectedRoute from './components/ProtectedRoute';
import { AuthSessionProvider } from './components/AuthSessionProvider';
import SeoHead from './components/SeoHead';

// Code-split all pages for optimal performance
// Each page loads only when user navigates to it
const LandingPage = lazy(() => import('./pages/LandingPage'));
const Onboarding = lazy(() => import('./pages/Onboarding'));
const Dashboard = lazy(() => import('./pages/Dashboard'));
const TaxShield = lazy(() => import('./pages/TaxShield'));
const Learn = lazy(() => import('./pages/Learn'));
const Methodology = lazy(() => import('./pages/Methodology'));
const DreamPlanner = lazy(() => import('./pages/DreamPlanner'));
const AICopilot = lazy(() => import('./pages/AICopilot'));
const Settings = lazy(() => import('./pages/Settings'));

// Loading fallback shown while page code is being downloaded
function RouteFallback() {
  return (
    <div className="min-h-screen flex items-center justify-center bg-[#FFFDF5]">
      <div className="animate-pulse flex flex-col items-center">
        <div className="w-16 h-16 bg-[#8B5CF6]/20 rounded-full mb-4" />
        <div className="h-4 w-32 bg-slate-200 rounded" />
      </div>
    </div>
  );
}

// Main app component — sets up routing and auth flow
function App() {
  return (
    // AuthSessionProvider watches login/logout and updates global user state
    <AuthSessionProvider>
      <a href="#main-content" className="skip-link">
        Skip to main content
      </a>
      <BrowserRouter>
        {/* Update meta tags (title, description, og:image) per page */}
        <SeoHead />
        {/* Show loading spinner while page code chunks are downloading */}
        <Suspense fallback={<RouteFallback />}>
          <Routes>
            {/* Public routes — anyone can visit */}
            <Route path="/" element={<LandingPage />} />
            <Route path="/learn" element={<Learn />} />
            <Route path="/methodology" element={<Methodology />} />
            
            {/* Protected routes — only authenticated users can view */}
            {/* ProtectedRoute redirects to landing if user is not logged in */}
            <Route path="/onboarding" element={<ProtectedRoute><Onboarding /></ProtectedRoute>} />
            <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>} />
            <Route path="/tax-shield" element={<ProtectedRoute><TaxShield /></ProtectedRoute>} />
            <Route path="/dream-planner" element={<ProtectedRoute><DreamPlanner /></ProtectedRoute>} />
            <Route path="/ai-copilot" element={<ProtectedRoute><AICopilot /></ProtectedRoute>} />
            <Route path="/settings" element={<ProtectedRoute><Settings /></ProtectedRoute>} />
          </Routes>
        </Suspense>
      </BrowserRouter>
    </AuthSessionProvider>
  );
}

export default App;
