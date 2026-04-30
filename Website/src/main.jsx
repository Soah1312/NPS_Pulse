// ============================================
// RetireSahi — React Application Entry Point
// ============================================
// This file initializes the React app with:
// - StrictMode: Detects unsafe practices in React components
// - HelmetProvider: Manages meta tags for SEO
// - DeferredAnalytics: Non-blocking analytics tracking
// - SpeedInsights: Vercel performance monitoring

import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { HelmetProvider } from 'react-helmet-async'
import './index.css'
import App from './App.jsx'
import DeferredAnalytics from './components/DeferredAnalytics.jsx'
import { SpeedInsights } from '@vercel/speed-insights/react'

// Mount React app to #root DOM element and enable all providers
createRoot(document.getElementById('root')).render(
  <StrictMode>
    <HelmetProvider>
      <App />
      <DeferredAnalytics />
      <SpeedInsights />
    </HelmetProvider>
  </StrictMode>,
)
