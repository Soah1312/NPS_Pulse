// ============================================
// Strategy Cards Generator
// ============================================
// Generates personalized tax and financial strategy cards for the Dashboard.
// Analyzes user's profile and suggests actionable improvements.
//
// STRATEGIES GENERATED:
// 1. Tax Regime Optimization - Old vs New regime analysis
// 2. 87A Rebate Opportunities - Rebate eligibility & optimization
// 3. Employer NPS Optimization - Maximize employer contribution
// 4. 80C Gap Closure - Reach maximum deduction ceiling
// 5. Additional Savings Opportunity - If projected gap exists
//
// USAGE:
// Cards are displayed on Dashboard page, user can click to simulate changes
// Simulations are powered by calculateRetirement() and computeTaxSavings()

import React, { useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowRight, Droplets, HeartPulse, Mail, ShieldCheck, TrendingUp } from 'lucide-react';
import { computeTaxSavings } from '../utils/math';

const formatIndian = (value) => {
  const amount = Math.max(0, Number(value) || 0);
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    maximumFractionDigits: 0,
  }).format(amount);
};

const clamp = (value, min, max) => Math.min(max, Math.max(min, value));

const toNumber = (value) => Number(value) || 0;

const buildTaxEngineInput = (userData = {}) => {
  const annualIncome = Math.max(0, toNumber(userData.monthlyIncome)) * 12;
  const basicSalaryPct = clamp(
    toNumber(userData.basicSalaryPct) || (userData.isGovtEmployee ? 0.5 : 0.4),
    0.2,
    0.8
  );
  const basicSalary = annualIncome * basicSalaryPct;
  const employerNpsCurrent = toNumber(userData.employerNPSContributionAnnual);
  const employerNpsFallback = userData.hasOptedForEmployerNPS ? basicSalary * 0.1 : 0;

  return {
    ...userData,
    workContext: userData.isGovtEmployee ? 'Government' : userData.workContext,
    basicSalaryPct,
    monthlyIncome: toNumber(userData.monthlyIncome),
    homeLoanInterest24b: toNumber(userData.homeLoanInterest),
    medicalInsurance80D: toNumber(userData.medicalInsurance_80D),
    extra80C: Math.min(
      150000,
      toNumber(userData.lifeInsurance_80C) + toNumber(userData.elss_ppf_80C)
    ),
    employerNPSContributionAnnual: employerNpsCurrent || employerNpsFallback,
    annualIncome,
    basicSalary,
  };
};

function buildStrategyCards(userData) {
  if (!userData) return [];

  const engineInput = buildTaxEngineInput(userData);
  const taxData = computeTaxSavings(engineInput);
  const annualIncome = Math.max(0, toNumber(userData.monthlyIncome)) * 12;
  const basicSalaryPct = clamp(
    toNumber(userData.basicSalaryPct) || (userData.isGovtEmployee ? 0.5 : 0.4),
    0.2,
    0.8
  );
  const basicSalary = annualIncome * basicSalaryPct;
  const employerNpsCurrent = toNumber(userData.employerNPSContributionAnnual) || (userData.hasOptedForEmployerNPS ? basicSalary * 0.1 : 0);
  const employerNpsRate = basicSalary > 0 ? employerNpsCurrent / basicSalary : 0;

  const old80c = Math.min(150000, toNumber(userData.lifeInsurance_80C) + toNumber(userData.elss_ppf_80C));
  const old80d = Math.min(50000, toNumber(userData.medicalInsurance_80D));
  const old24b = Math.min(200000, toNumber(userData.homeLoanInterest));
  const old80e = Math.max(0, toNumber(userData.educationLoanInterest_80E));
  const currentOldDeductions = old80c + old80d + old24b + old80e;

  const cards = [];

  if (userData.taxRegime === 'new' && annualIncome >= 1200000 && annualIncome <= 1300000) {
    const extraToZeroTax = Math.max(0, toNumber(taxData.newTaxDetails?.taxableIncome) - 1200000);

    cards.push({
      id: '87a-hail-mary',
      title: 'The 87A Hail Mary',
      eyebrow: 'New Regime Rebate Window',
      message: `Invest ${formatIndian(extraToZeroTax)} more to pay ZERO Tax`,
      potentialSavings: taxData.newTaxDetails?.taxPayable || 0,
      tone: 'rose',
      icon: ShieldCheck,
    });
  }

  if (employerNpsRate < 0.14) {
    const upgradedInput = {
      ...engineInput,
      employerNPSContributionAnnual: basicSalary * 0.14,
    };
    const upgradedTax = computeTaxSavings(upgradedInput);
    const currentTax = taxData.taxWithNPS;
    const upgradedCurrentTax = upgradedTax.taxWithNPS;

    cards.push({
      id: 'hr-power-play',
      title: 'The HR Power Play',
      eyebrow: 'Employer NPS Optimization',
      message: 'Optimize CTC to 14% NPS',
      potentialSavings: Math.max(0, currentTax - upgradedCurrentTax),
      tone: 'emerald',
      icon: Mail,
      actionLabel: 'Draft Email',
      actionPrompt: `Draft a concise HR email requesting an employer NPS contribution of 14% of basic salary. Current monthly income is ${formatIndian(toNumber(userData.monthlyIncome))}. Estimated tax savings from the change is ${formatIndian(Math.max(0, currentTax - upgradedCurrentTax))}. Keep it professional and ready to send.`,
    });
  }

  if (userData.taxRegime === 'old' && currentOldDeductions < (taxData.breakevenPoint || 0)) {
    const immediateSavings = Math.max(0, (taxData.oldTax || 0) - (taxData.newTax || 0));

    cards.push({
      id: 'breakeven-warning',
      title: 'The Breakeven Warning',
      eyebrow: 'Old Regime Underfunded',
      message: `Regime Mismatch: Switch to New Regime to save ${formatIndian(immediateSavings)} immediately`,
      potentialSavings: immediateSavings,
      tone: 'amber',
      icon: TrendingUp,
    });
  }

  if (toNumber(userData.medicalInsurance_80D) === 0) {
    cards.push({
      id: 'health-shield',
      title: 'The Health Shield',
      eyebrow: 'Family Protection Move',
      message: 'Protect your parents and save ₹7,800 in taxes',
      potentialSavings: 7800,
      tone: 'sky',
      icon: HeartPulse,
    });
  }

  if (!cards.length) {
    cards.push({
      id: 'neutral-position',
      title: 'Financial Position Check',
      eyebrow: 'No Immediate Tax Alarm',
      message: 'Your current profile does not trigger a high-priority action card.',
      potentialSavings: 0,
      tone: 'slate',
      icon: Droplets,
    });
  }

  return cards;
}

const toneStyles = {
  rose: {
    shell: 'bg-gradient-to-br from-white via-rose-50 to-white',
    ring: 'border-rose-200',
    badge: 'bg-rose-100 text-rose-700',
    icon: 'text-rose-600',
  },
  emerald: {
    shell: 'bg-gradient-to-br from-white via-emerald-50 to-white',
    ring: 'border-emerald-200',
    badge: 'bg-emerald-100 text-emerald-700',
    icon: 'text-emerald-600',
  },
  amber: {
    shell: 'bg-gradient-to-br from-white via-amber-50 to-white',
    ring: 'border-amber-200',
    badge: 'bg-amber-100 text-amber-700',
    icon: 'text-amber-600',
  },
  sky: {
    shell: 'bg-gradient-to-br from-white via-sky-50 to-white',
    ring: 'border-sky-200',
    badge: 'bg-sky-100 text-sky-700',
    icon: 'text-sky-600',
  },
  slate: {
    shell: 'bg-gradient-to-br from-white via-slate-50 to-white',
    ring: 'border-slate-200',
    badge: 'bg-slate-100 text-slate-700',
    icon: 'text-slate-600',
  },
};

const ActionCard = ({ card, onDraftEmail, navigate }) => {
  const Icon = card.icon;
  const styles = toneStyles[card.tone] || toneStyles.slate;
  const handleDraftEmail = () => {
    if (typeof onDraftEmail === 'function') {
      onDraftEmail(card);
      return;
    }

    if (card.actionPrompt && navigate) {
      navigate('/ai-copilot', { state: { initialPrompt: card.actionPrompt } });
    }
  };

  return (
    <article className={`relative overflow-hidden rounded-[28px] border-2 ${styles.ring} ${styles.shell} p-5 md:p-6 shadow-[4px_4px_0_0_#1E293B]`}>
      <div className="absolute right-0 top-0 h-28 w-28 translate-x-1/3 -translate-y-1/3 rounded-full bg-white/60" />
      <div className="relative z-10 flex h-full flex-col">
        <div className="flex items-start justify-between gap-4">
          <div className={`inline-flex items-center gap-2 rounded-full border border-transparent px-3 py-1 text-[10px] font-black uppercase tracking-[3px] ${styles.badge}`}>
            <Icon className={`h-4 w-4 ${styles.icon}`} />
            {card.eyebrow}
          </div>
          <div className="rounded-full border-2 border-[#1E293B] bg-white px-3 py-1 text-[10px] font-black uppercase tracking-[3px] text-[#1E293B]">
            Action Card
          </div>
        </div>

        <h3 className="mt-4 font-heading text-2xl font-black uppercase tracking-tight text-[#1E293B] leading-tight">
          {card.title}
        </h3>
        <p className="mt-3 text-sm font-bold leading-relaxed text-[#1E293B]/70">
          {card.message}
        </p>

        <div className="mt-5 rounded-[22px] border-2 border-[#1E293B] bg-white p-4">
          <div className="text-[10px] font-black uppercase tracking-[4px] text-[#1E293B]/45">Potential Savings</div>
          <div className="mt-2 font-heading text-3xl font-black text-[#10B981]">
            {formatIndian(card.potentialSavings)}
          </div>
        </div>

        {card.actionLabel && (
          <button
            type="button"
            onClick={handleDraftEmail}
            className="mt-5 inline-flex items-center justify-center gap-2 rounded-full border-2 border-[#1E293B] bg-[#1E293B] px-5 py-3 text-xs font-black uppercase tracking-[3px] text-white shadow-[3px_3px_0_0_#10B981] transition-all hover:-translate-y-1"
          >
            {card.actionLabel}
            <ArrowRight className="h-4 w-4" />
          </button>
        )}
      </div>
    </article>
  );
};

export default function StrategyCards({ userData, onDraftEmail, className = '' }) {
  const navigate = useNavigate();
  const cards = useMemo(() => buildStrategyCards(userData), [userData]);

  return (
    <section className={className}>
      <div className="mb-5 flex flex-col gap-2 md:flex-row md:items-end md:justify-between">
        <div>
          <div className="inline-flex items-center gap-2 rounded-full border-2 border-[#1E293B] bg-white px-3 py-1 text-[10px] font-black uppercase tracking-[4px] text-[#1E293B] shadow-[3px_3px_0_0_#1E293B]">
            Advisor Cards
          </div>
          <h2 className="mt-4 font-heading text-3xl font-black uppercase tracking-tight text-[#1E293B]">
            Personalized Action Cards
          </h2>
          <p className="mt-2 max-w-2xl text-sm font-bold leading-relaxed text-[#1E293B]/60">
            These cards turn your tax profile into direct actions with an estimated savings amount attached to each move.
          </p>
        </div>
      </div>

      <div className="grid grid-cols-1 gap-5 md:grid-cols-2 xl:grid-cols-4">
        {cards.map((card) => (
          <ActionCard key={card.id} card={card} onDraftEmail={onDraftEmail} navigate={navigate} />
        ))}
      </div>
    </section>
  );
}