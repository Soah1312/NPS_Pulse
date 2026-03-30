import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { 
  Home, Shield, Moon, Bot, Settings, TrendingUp, Zap, 
  Clock, PiggyBank, Wallet, LogOut, Info, AlertTriangle, BookOpen, 
  ExternalLink, BarChart2, ShieldAlert
} from 'lucide-react';
import { auth, db } from '../lib/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { onAuthStateChanged, signOut } from 'firebase/auth';
import { 
  SCHEME_E_RETURN, SCHEME_C_RETURN, SCHEME_G_RETURN, 
  LIFESTYLE_MULTIPLIERS, INFLATION_RATE, SWR, 
  LUMP_SUM_PCT, ANNUITY_PCT, ANNUITY_RATE,
  NEW_REGIME_SLABS, OLD_REGIME_SLABS
} from '../utils/math';

const COLORS = {
  bg: '#FFFDF5',
  fg: '#1E293B',
  violet: '#8B5CF6',
  pink: '#F472B6',
  amber: '#FBBF24',
  emerald: '#34D399',
  slate: '#1E293B',
};

const FormulaBox = ({ title, formula, example }) => (
  <div className="bg-[#FBBF24]/5 border-2 border-[#1E293B] rounded-xl p-6 space-y-4 shadow-[4px_4px_0_0_#1E293B]">
     <div className="text-[10px] font-black uppercase tracking-[2px] text-[#1E293B]/40">{title}</div>
     <div className="bg-white border-2 border-[#1E293B] p-4 rounded-lg font-mono text-xs md:text-sm text-[#1E293B] overflow-x-auto">
        {formula}
     </div>
     {example && (
       <div className="text-xs font-bold text-[#1E293B]/60 italic pl-2 border-l-2 border-[#FBBF24]">
          {example}
       </div>
     )}
  </div>
);

const SectionCard = ({ title, icon: Icon, accent, children }) => (
  <section className="bg-white border-2 border-[#1E293B] rounded-[24px] overflow-hidden pop-shadow">
     <div className="h-2 w-full" style={{ backgroundColor: accent }} />
     <div className="p-8 space-y-8">
        <div className="flex items-center gap-4">
           <div className={`w-12 h-12 rounded-full border-2 border-[#1E293B] flex items-center justify-center shadow-[3px_3px_0_0_#1E293B] shrink-0`} style={{ backgroundColor: `${accent}22` }}>
              <Icon className="w-6 h-6" style={{ color: accent }} strokeWidth={2.5} />
           </div>
           <h2 className="font-heading font-black text-2xl md:text-3xl uppercase tracking-widest text-[#1E293B]">{title}</h2>
        </div>
        <div className="space-y-6">
           {children}
        </div>
     </div>
  </section>
);

export default function Methodology() {
  const navigate = useNavigate();
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    document.title = "RetireSahi | How We Calculate";
    const unsub = onAuthStateChanged(auth, async (user) => {
      if (user) {
        const snap = await getDoc(doc(db, 'users', user.uid));
        if (snap.exists()) {
          setUserData(snap.data());
        } else {
          navigate('/onboarding');
        }
      } else {
        navigate('/');
      }
      setLoading(false);
    });
    return () => unsub();
  }, [navigate]);

  const navItems = [
    { label: 'Dashboard', icon: Home, path: '/dashboard' },
    { label: 'Tax Shield', icon: Shield, path: '/tax-shield' },
    { label: 'Dream Planner', icon: Moon, path: '/dream-planner' },
    { label: 'AI Co-Pilot', icon: Bot, path: '/ai-copilot' },
    { label: 'Methodology', icon: BarChart2, path: '/methodology', active: true },
    { label: 'Settings', icon: Settings, path: '/settings' },
  ];

  if (loading) return (
    <div className="min-h-screen flex items-center justify-center bg-[#FFFDF5]">
       <div className="animate-spin w-10 h-10 border-4 border-[#8B5CF6] border-t-transparent rounded-full" />
    </div>
  );

  return (
    <div className="min-h-screen bg-[#FFFDF5] text-[#1E293B] relative" style={{ fontFamily: '"Plus Jakarta Sans", sans-serif' }}>
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@700;800&family=Plus+Jakarta+Sans:wght@400;500;700;800&display=swap');
        h1, h2, h3, .font-heading { font-family: 'Outfit', sans-serif; }
        .pop-shadow { box-shadow: 4px 4px 0px 0px #1E293B; }
        .sidebar-item-active { background: #8B5CF6; color: white; border-radius: 9999px; box-shadow: 2px 2px 0px 0px rgba(0,0,0,0.3); }
      `}</style>

      {/* --- Sidebar (Same as Dashboard) --- */}
      <aside className="fixed left-0 top-0 h-full w-60 bg-[#1E293B] z-40 hidden lg:flex flex-col p-6 overflow-hidden">
         <div className="flex items-center gap-3 mb-12 cursor-pointer" onClick={() => navigate('/dashboard')}>
            <div className="w-10 h-10 bg-[#8B5CF6] rounded-full border-2 border-white flex items-center justify-center font-heading font-extrabold text-white text-xl">R</div>
            <span className="font-heading font-extrabold text-white text-xl uppercase tracking-widest">RetireSahi</span>
         </div>
         <nav className="flex-1 space-y-4">
            {navItems.map(item => (
              <button 
                key={item.label}
                onClick={() => navigate(item.path)}
                className={`w-full flex items-center gap-4 py-3 px-4 font-bold transition-all ${item.active ? 'sidebar-item-active' : 'text-white/70 hover:bg-white/10 rounded-full'}`}
              >
                <item.icon className="w-5 h-5" strokeWidth={2.5} />
                <span className="text-xs">{item.label}</span>
              </button>
            ))}
         </nav>
      </aside>

      <main className="lg:ml-60 min-h-screen flex flex-col relative">
         <div className="absolute inset-0 z-0 pointer-events-none opacity-[0.03]" style={{ backgroundImage: 'radial-gradient(#1E293B 1px, transparent 1px)', backgroundSize: '28px 28px' }} />

         <header className="h-16 border-b border-slate-200 bg-white/80 backdrop-blur-md sticky top-0 z-30 flex items-center justify-between px-8">
            <h1 className="font-heading font-extrabold text-2xl text-[#1E293B] uppercase tracking-widest">Methodology</h1>
            <div className="flex items-center gap-2 px-4 py-1.5 rounded-full border-2 border-[#1E293B] font-black uppercase tracking-widest text-[9px] bg-[#FBBF24]/10">
               <span className="text-[#FBBF24]">LAST UPDATED: BUDGET 2025</span>
            </div>
         </header>

         <div className="flex-1 p-8 space-y-12 max-w-5xl z-10">
            
            <div className="space-y-4">
               <p className="font-bold text-[#1E293B]/60 leading-relaxed text-lg italic">
                  "Every number in RetireSahi is computed from real-world data and disclosed assumptions. No black boxes."
               </p>
            </div>

            {/* 1. Returns */}
            <SectionCard title="Investment Returns" icon={TrendingUp} accent={COLORS.violet}>
               <div className="space-y-6">
                  <p className="text-sm font-bold text-[#1E293B]/70 leading-relaxed">
                     We use 10-year rolling average returns benchmarked against the largest NPS funds (SBI Pension Fund) as our primary engine.
                  </p>
                  
                  <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                     {[
                       { label: 'Scheme E (Equity)', val: (SCHEME_E_RETURN * 100).toFixed(2), color: COLORS.violet },
                       { label: 'Scheme C (Corp)', val: (SCHEME_C_RETURN * 100).toFixed(2), color: COLORS.pink },
                       { label: 'Scheme G (Govt)', val: (SCHEME_G_RETURN * 100).toFixed(2), color: COLORS.emerald }
                     ].map(r => (
                       <div key={r.label} className="p-4 rounded-xl border-2 border-[#1E293B] bg-white pop-shadow relative">
                          <div className="text-[9px] font-black uppercase tracking-widest text-[#1E293B]/40 mb-1">{r.label}</div>
                          <div className="font-heading font-black text-2xl" style={{ color: r.color }}>{r.val}%</div>
                          <div className="text-[10px] font-bold text-[#1E293B]/30 uppercase tracking-widest mt-1">p.a. ROI</div>
                       </div>
                     ))}
                  </div>

                  <FormulaBox 
                    title="Blended Return Formula"
                    formula="Blended Return = (Equity% × 12.69%) + ((1 - Equity%) ÷ 2 × 8.87%) + ((1 - Equity%) ÷ 2 × 8.74%)"
                    example="Example (50% Equity): (0.50 × 12.69%) + (0.25 × 8.87%) + (0.25 × 8.74%) = 10.75% blended ROI."
                  />

                  <div className="p-4 bg-slate-50 border-2 border-[#1E293B] rounded-xl flex items-center gap-4">
                     <Shield className="w-6 h-6 text-[#8B5CF6]" />
                     <p className="text-[10px] font-black uppercase tracking-widest leading-relaxed">
                        We enforce PFRDA Equity Caps by age (e.g., 75% max until age 50, tapering to 50% by age 60).
                     </p>
                  </div>
               </div>
            </SectionCard>

            {/* 2. Corpus Projection */}
            <SectionCard title="Corpus Projection" icon={Wallet} accent={COLORS.pink}>
               <div className="space-y-6">
                  <p className="text-sm font-bold text-[#1E293B]/70 leading-relaxed">
                     Projections use the standard Future Value of an Ordinary Annuity, assuming monthly compounding as per the industry standard for SIPs.
                  </p>
                  <FormulaBox 
                    title="Future Value Calculation"
                    formula="Projected Value = [Current Corpus × (1 + r)^n] + [Monthly Contribution × ((1 + r)^n - 1) ÷ r]"
                    example="Where r = Monthly Blended Return and n = Months to Retirement."
                  />
               </div>
            </SectionCard>

            {/* 3. SWR & Score */}
            <SectionCard title="Retirement Readiness" icon={Zap} accent={COLORS.amber}>
               <div className="space-y-8">
                  <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-start">
                     <div className="space-y-4">
                        <h4 className="font-black uppercase tracking-widest text-xs text-[#FBBF24]">Inflation Assumption</h4>
                        <div className="p-5 bg-[#FFF8E7] border-2 border-[#1E293B] rounded-xl font-heading font-black text-2xl flex justify-between items-center text-[#1E293B]">
                           {(INFLATION_RATE * 100).toFixed(0)}% <span className="text-xs opacity-40 font-bold uppercase tracking-widest">p.a.</span>
                        </div>
                        <p className="text-[10px] font-bold text-[#1E293B]/50 uppercase tracking-widest leading-relaxed">
                           Consistent with RBI long-term targets and private sector salary growth benchmarks.
                        </p>
                     </div>
                     <div className="space-y-4">
                        <h4 className="font-black uppercase tracking-widest text-xs text-[#8B5CF6]">Safe Withdrawal Rate</h4>
                        <div className="p-5 bg-white border-2 border-[#1E293B] rounded-xl font-heading font-black text-2xl flex justify-between items-center text-[#1E293B] shadow-[4px_4px_0_0_#8B5CF6]">
                           {SWR * 100}% <span className="text-xs opacity-40 font-bold uppercase tracking-widest">SWR</span>
                        </div>
                        <p className="text-[10px] font-bold text-[#1E293B]/50 uppercase tracking-widest leading-relaxed">
                           Adjusted for India (vs US 4% rules) due to higher inflation and specific annuity splits.
                        </p>
                     </div>
                  </div>

                  <div className="space-y-4">
                     <h4 className="font-black uppercase tracking-[3px] text-[10px] text-[#1E293B]/50">Lifestyle Income Replacement</h4>
                     <div className="grid grid-cols-3 gap-4">
                        {Object.entries(LIFESTYLE_MULTIPLIERS).map(([key, val]) => (
                           <div key={key} className="text-center p-3 border-2 border-[#1E293B] rounded-xl bg-white">
                              <div className="font-black text-lg text-[#1E293B]">{val * 100}%</div>
                              <div className="text-[8px] font-black uppercase tracking-widest text-[#1E293B]/30">{key}</div>
                           </div>
                        ))}
                     </div>
                  </div>

                  <FormulaBox 
                    title="Score Formula"
                    formula="Score = min(100, round((Projected Value ÷ Required Corpus) × 100))"
                  />
               </div>
            </SectionCard>

            {/* 4. Tax */}
            <SectionCard title="Tax Methodology" icon={Shield} accent={COLORS.emerald}>
               <div className="space-y-8">
                  <p className="text-sm font-bold text-[#1E293B]/70 leading-relaxed">
                     Compliant with the Finance Act 2024 / AY 2025-26 updates. New Regime as the system default.
                  </p>

                  <div className="bg-slate-50 border-2 border-[#1E293B] rounded-2xl p-6">
                     <h4 className="font-black uppercase tracking-widest text-xs mb-4 text-[#34D399]">New Regime Slabs (AY 2025-26)</h4>
                     <div className="space-y-2">
                        {NEW_REGIME_SLABS.map((s, i) => (
                           <div key={i} className="flex justify-between text-xs font-bold border-b border-slate-200 pb-2 uppercase tracking-wider">
                              <span className="text-[#1E293B]/50">{i === 0 ? '₹0 - ' : `₹${NEW_REGIME_SLABS[i-1].limit/100000}L - `}₹{s.limit/100000}L</span>
                              <span className="text-[#1E293B]">{s.rate * 100}%</span>
                           </div>
                        ))}
                     </div>
                     <div className="mt-4 pt-4 border-t-2 border-white flex justify-between text-[10px] font-black text-[#1E293B]">
                        <span>Standard Deduction: ₹75,000</span>
                        <span>87A Rebate: ₹12 Lakh</span>
                     </div>
                  </div>

                  <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                     <div className="p-4 border-2 border-[#1E293B] rounded-xl">
                        <div className="text-[9px] font-black uppercase tracking-widest text-[#1E293B]/40 mb-2">80CCD(1B)</div>
                        <p className="text-xs font-bold leading-relaxed">Flat ₹50,000 extra deduction exclusively for NPS. Only available in Old Regime.</p>
                     </div>
                     <div className="p-4 border-2 border-[#1E293B] rounded-xl bg-[#34D399]/5">
                        <div className="text-[9px] font-black uppercase tracking-widest text-[#1E293B]/40 mb-2">80CCD(2)</div>
                        <p className="text-xs font-bold leading-relaxed">Employer contribution up to 10% Basic. Available in BOTH regimes.</p>
                     </div>
                  </div>
               </div>
            </SectionCard>

            {/* 5. Data Sources */}
            <SectionCard title="Data Sources" icon={BookOpen} accent={COLORS.slate}>
               <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 items-start">
                  {[
                    { label: 'NPS Trust', desc: 'Daily NAV data for all schemes', icon: ExternalLink },
                    { label: 'PFRDA', desc: 'Investment & Withdrawal guidelines', icon: Shield },
                    { label: 'Income Tax Dept', desc: 'Finance Act 2025 slab rules', icon: BarChart2 },
                    { label: 'SBI Pension Fund', desc: '10-year Benchmark returns', icon: TrendingUp }
                  ].map(src => (
                    <div key={src.label} className="p-4 border-2 border-[#1E293B] rounded-xl flex items-center gap-4 group hover:bg-[#FBBF24]/5 transition-colors">
                       <src.icon className="w-5 h-5 text-[#1E293B]/30" />
                       <div>
                          <div className="text-xs font-black uppercase tracking-widest">{src.label}</div>
                          <div className="text-[10px] font-bold text-[#1E293B]/50 uppercase tracking-widest">{src.desc}</div>
                       </div>
                    </div>
                  ))}
               </div>
            </SectionCard>

            {/* Disclaimer */}
            <div className="bg-[#FBBF24] border-2 border-[#1E293B] rounded-[24px] p-8 pop-shadow space-y-4">
               <div className="flex items-center gap-3">
                  <ShieldAlert className="w-6 h-6 text-[#1E293B]" />
                  <h3 className="font-heading font-black text-xl uppercase tracking-widest">Important Disclaimer</h3>
               </div>
               <div className="text-xs font-bold text-[#1E293B] leading-relaxed space-y-3 prose-strong:font-black">
                  <p>RetireSahi provides financial projections for <strong>educational and planning purposes only</strong>. We are not a SEBI-registered investment advisor or an IRDAI-licensed agent.</p>
                  <p>All returns are based on historical data. <strong>Past performance does not guarantee future results.</strong> Tax laws are subject to change; verify with a qualified Chartered Accountant for your situation.</p>
                  <p className="border-t border-[#1E293B]/10 pt-4 uppercase tracking-widest text-[9px] opacity-70">RetireSahi is an independent project and is not affiliated with PFRDA or the NPS Trust.</p>
               </div>
            </div>

         </div>
      </main>
    </div>
  );
}
