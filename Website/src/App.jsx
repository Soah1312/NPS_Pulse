import { BrowserRouter, Routes, Route } from 'react-router-dom';
import LandingPage from './pages/LandingPage';
import Onboarding from './pages/Onboarding';
import Dashboard from './pages/Dashboard';
import TaxShield from './pages/TaxShield';
import Learn from './pages/Learn';
import Methodology from './pages/Methodology';

function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/onboarding" element={<Onboarding />} />
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/tax-shield" element={<TaxShield />} />
        <Route path="/learn" element={<Learn />} />
        <Route path="/methodology" element={<Methodology />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;
