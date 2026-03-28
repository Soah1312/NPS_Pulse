import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { LogOut, Loader2, Zap } from 'lucide-react';
import { auth, db } from '../lib/firebase';
import { doc, getDoc } from 'firebase/firestore';
import { signOut } from 'firebase/auth';

const COLORS = {
  emerald: '#34D399',
  violet: '#8B5CF6'
};

const MemphisDotGrid = () => (
  <div 
    className="absolute inset-0 z-0 pointer-events-none"
    style={{
      backgroundImage: 'radial-gradient(#1E293B 1px, transparent 1px)',
      backgroundSize: '28px 28px',
      opacity: 0.06
    }}
  />
);

const FinalScoreArc = ({ score = 0 }) => {
  const [offset, setOffset] = useState(283);
  useEffect(() => {
    const timeout = setTimeout(() => { setOffset(283 - (283 * (score / 100))); }, 300);
    return () => clearTimeout(timeout);
  }, [score]);

  return (
    <div className="relative w-full aspect-square max-w-[320px] mx-auto flex items-center justify-center">
      <div className="absolute inset-0 bg-[#34D399] rounded-full mix-blend-multiply opacity-50 -translate-x-4 translate-y-4" />
      <div className="relative z-10 w-full h-full bg-white border-4 border-[#1E293B] rounded-full p-8 flex flex-col items-center justify-center" style={{ boxShadow: '4px 4px 0px 0px #1E293B' }}>
        <svg viewBox="0 0 100 100" className="w-full h-full absolute inset-0 -rotate-90 p-4 pb-0 overflow-visible">
           <circle cx="50" cy="50" r="45" fill="none" stroke="#F1F5F9" strokeWidth="8" strokeDasharray="283" strokeLinecap="round" />
           <circle 
            cx="50" cy="50" r="45" fill="none" stroke={COLORS.emerald} strokeWidth="8" 
            strokeDasharray="283" strokeDashoffset={offset} strokeLinecap="round"
            style={{ transition: 'stroke-dashoffset 1.5s cubic-bezier(0.34, 1.56, 0.64, 1)' }}
          />
        </svg>
        <div className="text-center relative z-20 mt-4">
          <div className="font-heading font-extrabold text-[#1E293B] text-7xl leading-none" style={{ fontFamily: '"Outfit", sans-serif' }}>{score}</div>
          <div className="font-bold text-[#34D399] uppercase tracking-widest text-sm mt-2">On Track</div>
        </div>
      </div>
    </div>
  );
};

export default function Dashboard() {
  const navigate = useNavigate();
  const [userData, setUserData] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    document.title = "NPS Pulse | Dashboard";
    
    // Check auth and fetch data
    const unsubscribe = auth.onAuthStateChanged(async (user) => {
      if (user) {
        try {
          const docRef = doc(db, 'users', user.uid);
          const docSnap = await getDoc(docRef);
          
          if (docSnap.exists()) {
            setUserData(docSnap.data());
          } else {
            // User authenticated but no onboarding data
            navigate('/onboarding');
          }
        } catch (err) {
          console.error("Error fetching user data:", err);
        } finally {
          setLoading(false);
        }
      } else {
        // Not logged in
        navigate('/');
      }
    });

    return () => unsubscribe();
  }, [navigate]);

  const handleLogout = async () => {
    await signOut(auth);
    navigate('/');
  };

  const formatCurrency = (val) => {
    if (val >= 10000000) return `₹${(val / 10000000).toFixed(1)} Cr`;
    if (val >= 100000) return `₹${(val / 100000).toFixed(1)} L`;
    return `₹${Math.round(val || 0).toLocaleString('en-IN')}`;
  };

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-[#FFFDF5]">
        <Loader2 className="w-12 h-12 animate-spin text-[#8B5CF6]" />
      </div>
    );
  }

  return (
    <div className="min-h-screen relative flex flex-col items-center px-4 py-12 overflow-hidden bg-[#FFFDF5] text-[#1E293B]" style={{ fontFamily: '"Plus Jakarta Sans", sans-serif' }}>
      <MemphisDotGrid />
      
      {/* Top Bar */}
      <div className="w-full max-w-6xl flex justify-between items-center z-10 mb-12">
        <div className="font-black text-2xl flex items-center gap-2" style={{ fontFamily: '"Outfit", sans-serif' }}>
          <div className="w-8 h-8 rounded-full bg-[#8B5CF6] border-2 border-[#1E293B] flex items-center justify-center">
            <div className="w-3 h-3 bg-white rounded-full" />
          </div>
          NPS Pulse
        </div>
        
        <div className="flex items-center gap-4">
          <div className="flex items-center gap-3 bg-white border-2 border-[#1E293B] rounded-full py-1.5 px-3 md:pr-4" style={{ boxShadow: '2px 2px 0px 0px #1E293B' }}>
            {auth.currentUser?.photoURL ? (
              <img src={auth.currentUser.photoURL} alt="Profile" className="w-8 h-8 rounded-full border-2 border-[#1E293B]" />
            ) : (
              <div className="w-8 h-8 rounded-full bg-[#34D399] border-2 border-[#1E293B] flex items-center justify-center font-bold text-white">
                {(auth.currentUser?.displayName || auth.currentUser?.email || 'U')[0].toUpperCase()}
              </div>
            )}
            <span className="font-bold hidden md:block text-sm">
              {auth.currentUser?.displayName || auth.currentUser?.email?.split('@')[0]}
            </span>
          </div>
          <button 
            onClick={handleLogout}
            className="w-12 h-12 bg-white border-2 border-[#1E293B] rounded-full flex items-center justify-center hover:bg-[#F472B6] hover:text-white transition-colors cursor-pointer"
            style={{ boxShadow: '2px 2px 0px 0px #1E293B' }}
          >
            <LogOut className="w-5 h-5" />
          </button>
        </div>
      </div>

      <div className="z-10 w-full max-w-4xl flex flex-col lg:flex-row gap-12 items-center justify-center">
        <div className="w-full lg:w-1/2 flex justify-center">
           <FinalScoreArc score={userData?.score || 0} />
        </div>

        <div className="w-full lg:w-1/2 flex flex-col gap-6">
           <div className="bg-white border-2 border-[#1E293B] rounded-3xl p-6 md:p-8" style={{ boxShadow: '4px 4px 0px 0px #1E293B' }}>
             <div className="font-bold uppercase tracking-widest text-[#1E293B]/60 text-xs md:text-sm mb-4">Your Base Plan Outlook</div>
             
             <div className="grid grid-cols-2 gap-4 mb-6">
               <div>
                 <div className="text-xs md:text-sm font-bold opacity-60 uppercase mb-1">Projected Value</div>
                 <div className="font-bold text-2xl md:text-3xl" style={{ fontFamily: '"Outfit", sans-serif' }}>
                   {formatCurrency(userData?.projectedValue)}
                 </div>
               </div>
               <div>
                 <div className="text-xs md:text-sm font-bold opacity-60 uppercase mb-1">Required Corpus</div>
                 <div className="font-bold text-2xl md:text-3xl" style={{ fontFamily: '"Outfit", sans-serif' }}>
                   {formatCurrency(userData?.requiredCorpus)}
                 </div>
               </div>
             </div>
             
             <div className="h-px w-full bg-[#1E293B]/10 mb-6" />
             
             <div className="bg-[#FFFDF5] border-2 border-[#FBBF24] rounded-2xl p-5 shadow-[4px_4px_0_0_#FBBF24]">
               <div className="font-bold uppercase tracking-widest text-[#FBBF24] text-xs md:text-sm mb-2 flex items-center gap-2">
                 <Zap className="w-4 h-4" /> Current Gap Insight
               </div>
               <div className="font-bold text-base md:text-lg leading-snug">
                 {userData?.monthlyGap > 0 ? (
                   <>Increase your monthly contribution by <span className="text-[#8B5CF6] font-black">{formatCurrency(userData.monthlyGap)}</span> to cover the gap entirely.</>
                 ) : (
                   <><span className="text-[#34D399] font-black">You are fully on track!</span> Your current plan exceeds your retirement requirements.</>
                 )}
               </div>
             </div>
           </div>
           
           {/* Temporary button until layered dashboard design is fully implemented */}
           <button 
             onClick={() => navigate('/onboarding')}
             className="w-full py-4 bg-white border-2 border-[#1E293B] rounded-xl font-bold uppercase tracking-widest hover:bg-[#F1F5F9] cursor-pointer"
             style={{ boxShadow: '4px 4px 0px 0px #1E293B' }}
           >
             Retake Questionnaire
           </button>
        </div>
      </div>
    </div>
  );
}
