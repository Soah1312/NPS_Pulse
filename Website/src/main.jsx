import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App.jsx'
import DeferredAnalytics from './components/DeferredAnalytics.jsx'
import DeferredSpeedInsights from './components/DeferredSpeedInsights.jsx'

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <App />
    <DeferredAnalytics />
    <DeferredSpeedInsights />
  </StrictMode>,
)
