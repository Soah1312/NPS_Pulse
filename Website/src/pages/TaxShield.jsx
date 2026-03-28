import React, { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Shield, Zap, TrendingUp, Info, CheckCircle2, AlertCircle, ArrowRight } from 'lucide-react';
import { auth, db } from '../lib/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { onAuthStateChanged } from 'firebase/auth';
import { computeTax, NEW_REGIME_SLABS, OLD_REGIME_SLABS } from '../utils/math';

const COLORS = {
  bg: '#FFFDF5',
  fg: '#1E293B',
  violet: '#8B5CF6',
  pink: '#F472B6',
  amber: '#FBBF24',
  emerald: '#34D399'
};

const formatIndian = (num) => {
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0
  }).format(num);
};

export default function TaxShield() {
  const navigate = useNavigate();
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);
  
  // Custom states for what-if tax scenarios
  const [investments, setInvestments] = useState({
    extra80C: 0,
    nps80CCD1B: 50000,
    employerNPS: 0 // 80CCD(2)
  });

  useEffect(() => {
    document.title = "NPS Pulse | Tax Shield";
    const unsub = onAuthStateChanged(auth, async (user) => {
      if (user) {
        const snap = await getDoc(doc(db, 'users', user.uid));
        if (snap.exists()) {
          const data = snap.data();
          setUserData(data);
          // Set default employer contribution to 10% of basic (est 40% of CTC) if Govt/Private
          if (data.workContext === 'Government' || data.workContext === 'Private Sector') {
             const basic = data.monthlyIncome * 12 * 0.40;
             setInvestments(prev => ({ ...prev, employerNPS: Math.round(basic * 0.10) }));
          }
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

  const taxAnalysis = useMemo(() => {
    if (!userData) return null;
    const annualIncome = userData.monthlyIncome * 12;

    // 1. Current Situation (No NPS extra shield)
    // New Regime only allows Standard Deduction (75k) + 80CCD(2)
    const currentTaxNew = computeTax(annualIncome, 'new', investments.employerNPS); 
    
    // Old Regime allows 80C (1.5L) + 80CCD(1B) (50k)
    // We assume they already utilize some 80C (investments.extra80C)
    // and if they are NPS users in onboarding, we assume they use some 80CCD(1B)
    const oldDeductions = Math.min(150000, investments.extra80C) + investments.nps80CCD1B + investments.employerNPS;
    const currentTaxOld = computeTax(annualIncome, 'old', oldDeductions);

    // 2. Optimized Situation (Maxing everything)
    const optDeductions = 150000 + 50000 + investments.employerNPS;
    const optTaxOld = computeTax(annualIncome, 'old', optDeductions);

    return {
      annualIncome,
      newRegime: { tax: currentTaxNew, slabs: NEW_REGIME_SLABS },
      oldRegime: { tax: currentTaxOld, slabs: OLD_REGIME_SLABS },
      optimizedOld: optTaxOld,
      bestRegime: currentTaxNew < currentTaxOld ? 'new' : 'old',
      savings: Math.abs(currentTaxNew - currentTaxOld)
    };
  }, [userData, investments]);

  if (loading) return null;

  return (
    <div className="min-h-screen bg-[#FFFDF5] text-[#1E293B] pb-20 overflow-x-hidden" style={{ fontFamily: '"Plus Jakarta Sans", sans-serif' }}>
       <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Outfit:wght@700;800&family=Plus+Jakarta+Sans:wght@400;500;700;800&display=swap');
        h1, h2, h3, .font-heading { font-family: 'Outfit', sans-serif; }
        .cubic { transition-timing-function: cubic-bezier(0.34, 1.56, 0.64, 1); }
        .pop-shadow { box-shadow: 4px 4px 0px 0px #1E293B; }
        .pop-shadow-lg { box-shadow: 8px 8px 0px 0px #1E293B; }
        .no-scrollbar::-webkit-scrollbar { display: none; }
      `}</style>

      {/* Header */}
      <header className="h-20 border-b-2 border-[#1E293B] bg-white sticky top-0 z-30 flex items-center px-6 lg:px-12 gap-6">
         <button onClick={() => navigate('/dashboard')} className="p-3 bg-white border-2 border-[#1E293B] rounded-full hover:bg-slate-50 transition-colors pop-shadow">
            <ArrowLeft className="w-5 h-5" />
         </button>
         <div>
            <h1 className="font-heading font-black text-2xl uppercase tracking-widest leading-none">Tax Shield Analysis</h1>
            <p className="text-[10px] font-bold text-[#1E293B]/40 uppercase tracking-widest mt-1">AY 2025-26 Budget Update Ready</p>
         </div>
         <div className="ml-auto flex items-center gap-4">
            <div className="hidden md:flex items-center gap-2 px-4 py-2 bg-[#34D399]/10 border-2 border-[#1E293B] rounded-full font-black text-[10px] uppercase tracking-widest text-[#065F46] shadow-[2px_2px_0_0_#34D399]">
               <Shield className="w-3.5 h-3.5" /> Precise Calculator
            </div>
         </div>
      </header>

      <main className="max-w-6xl mx-auto p-6 lg:p-12 space-y-12">
         
         {/* 1. Hero Summary */}
         <section className="grid grid-cols-1 lg:grid-cols-12 gap-8 items-stretch">
            <div className="lg:col-span-7 bg-[#8B5CF6] border-2 border-[#1E293B] rounded-[32px] p-8 lg:p-10 text-white pop-shadow-lg relative overflow-hidden flex flex-col justify-between">
               <div className="relative z-10">
                  <div className="flex items-center gap-3 mb-6">
                     <Zap className="text-[#FBBF24]" fill="currentColor" />
                     <span className="font-black uppercase tracking-[3px] text-xs opacity-70">Tax Intelligence</span>
                  </div>
                  <h2 className="font-heading font-black text-4xl md:text-5xl lg:text-6xl leading-tight mb-6">
                     You save <span className="text-[#34D399]">{formatIndian(taxAnalysis.savings)}</span> in the {taxAnalysis.bestRegime} Regime.
                  </h2>
                  <p className="text-white/60 font-bold text-sm md:text-base max-w-lg leading-relaxed">
                     Based on your annual gross income of <span className="text-white">{formatIndian(taxAnalysis.annualIncome)}</span> and current NPS contributions.
                  </p>
               </div>
               
               <div className="mt-12 flex flex-wrap gap-4 relative z-10">
                  <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4 flex-1 min-w-[150px]">
                     <div className="text-[10px] font-black uppercase tracking-widest opacity-50 mb-1">New Regime Tax</div>
                     <div className="font-heading font-bold text-2xl">{formatIndian(taxAnalysis.newRegime.tax)}</div>
                  </div>
                  <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4 flex-1 min-w-[150px]">
                     <div className="text-[10px] font-black uppercase tracking-widest opacity-50 mb-1">Old Regime Tax</div>
                     <div className="font-heading font-bold text-2xl">{formatIndian(taxAnalysis.oldRegime.tax)}</div>
                  </div>
               </div>

               {/* Background Shapes */}
               <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 rounded-full translate-x-1/2 -translate-y-1/2" />
               <Shield className="absolute bottom-[-20px] right-[-20px] w-48 h-48 text-white/5 rotate-[-15deg] pointer-events-none" />
            </div>

            <div className="lg:col-span-5 bg-white border-2 border-[#1E293B] rounded-[32px] p-8 pop-shadow-lg flex flex-col justify-between">
               <div className="space-y-6">
                  <h3 className="font-heading font-black text-2xl uppercase tracking-widest text-[#1E293B]">NPS Benefits</h3>
                  <div className="space-y-4">
                     <div className="flex items-start gap-4">
                        <div className="w-8 h-8 rounded-full bg-[#34D399]/10 border-2 border-[#1E293B] flex items-center justify-center shrink-0">
                           <CheckCircle2 className="w-5 h-5 text-[#34D399]" />
                        </div>
                        <div>
                           <div className="font-black text-sm uppercase tracking-wide">80CCD(1B) Bonus</div>
                           <p className="text-xs font-bold text-[#1E293B]/50 leading-relaxed max-w-xs">Exclusive ₹50,000 deduction for NPS subscribers only in the Old Regime.</p>
                        </div>
                     </div>
                     <div className="flex items-start gap-4">
                        <div className="w-8 h-8 rounded-full bg-[#8B5CF6]/10 border-2 border-[#1E293B] flex items-center justify-center shrink-0">
                           <CheckCircle2 className="w-5 h-5 text-[#8B5CF6]" />
                        </div>
                        <div>
                           <div className="font-black text-sm uppercase tracking-wide">80CCD(2) Corporate</div>
                           <p className="text-xs font-bold text-[#1E293B]/50 leading-relaxed max-w-xs">Up to 10% basic salary deduction allowed in BOTH regimes. (14% for Govt)</p>
                        </div>
                     </div>
                  </div>
               </div>
               
               <div className="bg-[#FFFDF5] border-2 border-[#1E293B] border-dashed rounded-2xl p-4 mt-8">
                  <div className="flex items-center gap-2 text-[#EF4444] mb-2 font-black text-[10px] uppercase tracking-widest">
                     <AlertCircle className="w-4 h-4" /> Pro Tip
                  </div>
                  <p className="text-xs font-bold text-[#1E293B]/70 leading-relaxed">
                     Switching to the New Regime? Standard deduction is now ₹75,000. You still get NPS corporate benefits!
                  </p>
               </div>
            </div>
         </section>

         {/* 2. Slab Visualization */}
         <section className="space-y-8">
            <div className="flex items-center gap-4">
               <h2 className="font-heading font-black text-3xl uppercase tracking-widest leading-none">Tax Slab Pulse</h2>
               <div className="flex-1 h-1 bg-[#1E293B] relative opacity-10"></div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-12">
               {/* New Regime Slabs */}
               <div className="space-y-6">
                  <div className="flex justify-between items-end">
                     <h3 className="font-black text-xl uppercase tracking-wider text-[#8B5CF6]">New Regime</h3>
                     <span className="text-xs font-bold bg-[#E2E8F0] px-3 py-1 rounded-full border border-[#1E293B]/10">Default for FY 24-25</span>
                  </div>
                  <div className="space-y-3">
                     {NEW_REGIME_SLABS.map((slab, i) => {
                        const prev = i === 0 ? 0 : NEW_REGIME_SLABS[i-1].limit;
                        const range = slab.limit === Infinity ? `Above ${formatIndian(prev)}` : `${formatIndian(prev)} - ${formatIndian(slab.limit)}`;
                        return (
                          <div key={i} className="flex items-center gap-4">
                             <div className="w-16 text-xs font-black text-[#1E293B]/40">{slab.rate * 100}%</div>
                             <div className="flex-1 h-8 bg-white border-2 border-[#1E293B] rounded-lg overflow-hidden relative group">
                                <div className="absolute inset-0 bg-[#8B5CF6]/5 group-hover:bg-[#8B5CF6]/10 transition-colors" />
                                <div className="absolute inset-y-0 left-0 bg-[#8B5CF6]" style={{ width: `${slab.rate * 100 * 2.5}%` }} />
                                <div className="absolute inset-0 flex items-center px-4 justify-between">
                                   <span className="text-[10px] font-black uppercase tracking-widest text-[#1E293B]">{range}</span>
                                </div>
                             </div>
                          </div>
                        );
                     })}
                  </div>
               </div>

               {/* Old Regime Slabs */}
               <div className="space-y-6">
                  <div className="flex justify-between items-end">
                     <h3 className="font-black text-xl uppercase tracking-wider text-[#34D399]">Old Regime</h3>
                     <span className="text-xs font-bold bg-[#E2E8F0] px-3 py-1 rounded-full border border-[#1E293B]/10">With Deductions</span>
                  </div>
                  <div className="space-y-3">
                     {OLD_REGIME_SLABS.map((slab, i) => {
                        const prev = i === 0 ? 0 : OLD_REGIME_SLABS[i-1].limit;
                        const range = slab.limit === Infinity ? `Above ${formatIndian(prev)}` : `${formatIndian(prev)} - ${formatIndian(slab.limit)}`;
                        return (
                          <div key={i} className="flex items-center gap-4">
                             <div className="w-16 text-xs font-black text-[#1E293B]/40">{slab.rate * 100}%</div>
                             <div className="flex-1 h-8 bg-white border-2 border-[#1E293B] rounded-lg overflow-hidden relative group">
                                <div className="absolute inset-0 bg-[#34D399]/5 group-hover:bg-[#34D399]/10 transition-colors" />
                                <div className="absolute inset-y-0 left-0 bg-[#34D399]" style={{ width: `${slab.rate * 100 * 2.5}%` }} />
                                <div className="absolute inset-0 flex items-center px-4 justify-between">
                                   <span className="text-[10px] font-black uppercase tracking-widest text-[#1E293B]">{range}</span>
                                </div>
                             </div>
                          </div>
                        );
                     })}
                  </div>
               </div>
            </div>
         </section>

         {/* 3. Personalized Settings (What If) */}
         <section className="bg-white border-2 border-[#1E293B] rounded-[32px] p-8 lg:p-12 pop-shadow-lg relative overflow-hidden group">
            <div className="flex flex-col lg:flex-row gap-12 items-center">
               <div className="lg:w-1/3">
                  <h3 className="font-heading font-black text-3xl uppercase tracking-widest mb-4">Precision Tweak</h3>
                  <p className="text-sm font-bold text-[#1E293B]/60 leading-relaxed">
                     Add your other tax-saving investments to see if the Old Regime becomes more beneficial.
                  </p>
               </div>
               
               <div className="flex-1 grid grid-cols-1 md:grid-cols-2 gap-8 w-full">
                  <div className="space-y-4">
                     <label className="text-[10px] font-black uppercase tracking-[3px] text-[#1E293B]/50">Sec 80C (PPF, ELSS, Insurance)</label>
                     <div className="relative">
                        <span className="absolute left-4 top-1/2 -translate-y-1/2 font-black text-[#1E293B]/20">₹</span>
                        <input 
                           type="number" step="1000"
                           value={investments.extra80C}
                           onChange={e => setInvestments({...investments, extra80C: parseInt(e.target.value) || 0})}
                           className="w-full bg-[#FFFDF5] border-2 border-[#1E293B] rounded-2xl p-4 pl-10 font-black text-xl focus:shadow-[4px_4px_0_0_#8B5CF6] transition-all outline-none" 
                        />
                     </div>
                  </div>
                  <div className="space-y-4">
                     <label className="text-[10px] font-black uppercase tracking-[3px] text-[#1E293B]/50">NPS Bonus 80CCD(1B)</label>
                     <div className="flex gap-3">
                        {[0, 25000, 50000].map(val => (
                           <button 
                              key={val}
                              onClick={() => setInvestments({...investments, nps80CCD1B: val})}
                              className={`flex-1 py-3 rounded-xl border-2 border-[#1E293B] font-black text-xs uppercase tracking-widest transition-all ${investments.nps80CCD1B === val ? 'bg-[#FBBF24] shadow-[3px_3px_0_0_#1E293B] -translate-y-1' : 'bg-white hover:bg-slate-50'}`}
                           >
                              {val === 0 ? 'Skip' : formatIndian(val)}
                           </button>
                        ))}
                     </div>
                  </div>
               </div>
            </div>
            
            <div className="mt-12 pt-12 border-t-2 border-[#1E293B]/10 flex flex-col md:flex-row justify-between items-center gap-8">
               <div className="flex items-center gap-3">
                  <TrendingUp className="text-[#8B5CF6]" />
                  <span className="font-black uppercase tracking-widest text-sm">Potential Annual Savings: <span className="text-[#8B5CF6]">{formatIndian(taxAnalysis.savings)}</span></span>
               </div>
               <button 
                 onClick={() => navigate('/dashboard')}
                 className="candy-btn px-10 py-4 bg-[#1E293B] text-white font-black uppercase tracking-[0.2em] text-sm flex items-center gap-4 group"
               >
                  Update Dashboard Pulse <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
               </button>
            </div>
         </section>

      </main>

      {/* Confetti footer decoration */}
      <div className="h-60 relative pointer-events-none opacity-20">
         <div className="absolute top-10 left-10 w-20 h-20 bg-[#F472B6] rotate-12" />
         <div className="absolute top-40 left-[20%] w-12 h-12 bg-[#34D399] rounded-full" />
         <div className="absolute top-20 right-[15%] w-24 h-24 border-8 border-[#FBBF24] rounded-full" />
         <div className="absolute bottom-10 left-[40%] w-32 h-4 bg-[#8B5CF6] rounded-full rotate-[-5deg]" />
      </div>
    </div>
  );
}
