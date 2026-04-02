// ============================================
// RetireSahi — Math Engine v2.0
// All formulas verified against PFRDA rules
// and FY 2025-26 tax compliance
// ============================================

// ── SCHEME RETURNS (10-year averages) ───────
export const SCHEME_E_RETURN = 0.1269   // Equity
export const SCHEME_C_RETURN = 0.0887   // Corporate Bonds
export const SCHEME_G_RETURN = 0.0874   // Govt Securities

// ── FIXED ASSUMPTIONS ───────────────────────
export const INFLATION_RATE  = 0.06     // 6% p.a.
export const SWR             = 0.035    // 3.5% Safe Withdrawal Rate (India-adjusted)
export const ANNUITY_RATE    = 0.06     // 6% p.a. (conservative annuity estimate)
export const ANNUITY_SPLIT   = 0.40     // 40% must be annuitized (PFRDA mandate)
export const ANNUITY_PCT    = 0.40     // Alias for compatibility
export const LUMP_SUM_SPLIT  = 0.60     // 60% available as lump sum
export const LUMP_SUM_PCT  = 0.60     // Alias for compatibility
export const MIN_MODEL_MONTHLY_INCOME = 10000 // Keep readiness realistic for legacy low-income edge cases

// ── COLORS ─────────────────────────────────
export const COLORS = {
  bg: '#FFFDF5',
  fg: '#1E293B',
  violet: '#8B5CF6',
  pink: '#F472B6',
  amber: '#FBBF24',
  emerald: '#34D399',
  slate: '#1E293B',
  red: '#EF4444',
  orange: '#F97316',
  blue: '#3B82F6'
}

// ── LIFESTYLE MULTIPLIERS ───────────────────
export const LIFESTYLE_MULTIPLIERS = {
  essential:   0.40,
  comfortable: 0.60,
  premium:     0.80,
}

// ── PFRDA EQUITY CAP BY AGE ─────────────────
export function getMaxEquityPct(age) {
  if (age < 50) return 75
  if (age >= 60) return 50
  return 75 - (age - 50) * 2.5
}

// ── BLENDED RETURN ──────────────────────────
// Based on user's equity allocation
// Remaining split equally between C and G
export function computeBlendedReturn(equityPct, age) {
  const cappedEquity = Math.min(equityPct, getMaxEquityPct(age)) / 100
  const remaining = 1 - cappedEquity
  return (
    cappedEquity * SCHEME_E_RETURN +
    (remaining / 2) * SCHEME_C_RETURN +
    (remaining / 2) * SCHEME_G_RETURN
  )
}

// ── TAX REGIME SLABS (AY 2025-26) ───────────
export const NEW_REGIME_SLABS = [
  { limit: 400000,  rate: 0.00 },
  { limit: 800000,  rate: 0.05 },
  { limit: 1200000, rate: 0.10 },
  { limit: 1600000, rate: 0.15 },
  { limit: 2000000, rate: 0.20 },
  { limit: 2400000, rate: 0.25 },
  { limit: Infinity, rate: 0.30 },
]

export const OLD_REGIME_SLABS = [
  { limit: 250000,  rate: 0.00 },
  { limit: 500000,  rate: 0.05 },
  { limit: 1000000, rate: 0.20 },
  { limit: Infinity, rate: 0.30 },
]

// ── INDIAN NUMBER FORMATTER ─────────────────
export function formatIndian(num) {
  if (!num || isNaN(num)) return '₹0'
  if (num >= 10000000) return `₹${(num / 10000000).toFixed(1)} Cr`
  if (num >= 100000)   return `₹${(num / 100000).toFixed(1)} L`
  if (num >= 1000)     return `₹${(num / 1000).toFixed(0)}K`
  return `₹${Math.round(num)}`
}

// ── SCORE BAND ──────────────────────────────
export function getScoreBand(score) {
  if (score <= 30) return { label: 'Critical',  color: '#EF4444' }
  if (score <= 50) return { label: 'At Risk',   color: '#F97316' }
  if (score <= 70) return { label: 'On Track',  color: '#3B82F6' }
  if (score <= 85) return { label: 'Good',      color: '#8B5CF6' }
  return              { label: 'Excellent',  color: '#34D399' }
}

// ── SCORE INFO (alias for compatibility) ────
export const getScoreInfo = getScoreBand

// ── STEP-UP FV ──────────────────────────────
// FV of contributions growing 10% per year (step-up)
export function computeStepUpFV(monthlyPmt, annualReturn, years) {
  const r = annualReturn / 12
  let fv = 0
  for (let k = 0; k < years; k++) {
    const pmt = monthlyPmt * Math.pow(1.10, k)
    const monthsRemaining = (years - k) * 12
    fv += pmt * (Math.pow(1 + r, monthsRemaining) - 1) / r
  }
  return fv
}

// ── MILESTONE AGE ───────────────────────────
// Binary search for the age at which corpus hits a milestone
export function getMilestoneAge(milestone, currentAge, corpus, monthlyPmt, annualReturn) {
  const r = annualReturn / 12
  if (corpus >= milestone) return { age: currentAge, achieved: true }
  let lo = 0, hi = 600
  while (lo < hi) {
    const mid = Math.floor((lo + hi) / 2)
    const fv = corpus * Math.pow(1 + r, mid) +
               monthlyPmt * (Math.pow(1 + r, mid) - 1) / r
    if (fv >= milestone) hi = mid
    else lo = mid + 1
  }
  return { age: Math.round(currentAge + lo / 12), achieved: false }
}

// ── CORE RETIREMENT CALCULATOR ──────────────
// Single source of truth — used by onboarding,
// dashboard, simulator, and what-if scenarios
export function calculateRetirement(data) {
  const age         = parseInt(data.age) || 25
  const retireAge   = parseInt(data.retireAge) || 60
  const years       = Math.max(1, retireAge - age)
  const n           = years * 12   // total months

  const monthlyIncome      = Math.max(0, parseFloat(data.monthlyIncome) || 0)
  const monthlyContribRaw  = Math.max(0, parseFloat(data.npsContribution) || 0)
  const monthlyContrib     = Math.min(Math.max(0, monthlyContribRaw), Math.max(0, monthlyIncome))
  const npsCorpus          = Math.max(0, parseFloat(data.npsCorpus) || 0)
  const otherSavings       = data.addSavings ? Math.max(0, parseFloat(data.totalSavings) || 0) : 0
  const totalCorpus        = npsCorpus + otherSavings
  const equityPct          = parseFloat(data.npsEquity) || 50
  const lifestyle          = (data.lifestyle || 'comfortable').toLowerCase()

  // Blended annual return
  const annualReturn = computeBlendedReturn(equityPct, age)
  const r = annualReturn / 12   // monthly rate

  // ── PROJECTED VALUE ──
  // FV of existing corpus
  const fvCorpus = totalCorpus * Math.pow(1 + r, n)
  // FV of monthly contributions (ordinary annuity)
  const fvContributions = monthlyContrib > 0
    ? monthlyContrib * (Math.pow(1 + r, n) - 1) / r
    : 0
  const projectedValue = fvCorpus + fvContributions

  // ── REQUIRED CORPUS ──
  const lifestyleMultiplier = LIFESTYLE_MULTIPLIERS[lifestyle] || 0.60
  const modeledMonthlyIncome = Math.max(monthlyIncome, MIN_MODEL_MONTHLY_INCOME)
  // Inflation-adjusted monthly spend at retirement
  const monthlySpendAtRetirement =
    modeledMonthlyIncome * lifestyleMultiplier * Math.pow(1 + INFLATION_RATE, years)
  // Required corpus using SWR (on lump sum portion only)
  // Since 40% is annuitized, we need the lump sum (60%) to cover
  // (monthly spend - annuity income) via SWR
  // But we solve for total corpus first, then split
  const annualSpend = monthlySpendAtRetirement * 12
  const requiredCorpus = annualSpend > 0 ? annualSpend / SWR : 0

  // ── SCORE ──
  const readinessRatio = requiredCorpus > 0 ? (projectedValue / requiredCorpus) : 0
  const uncappedScore = Number.isFinite(readinessRatio) ? readinessRatio * 100 : 0
  const score = Math.max(0, Math.min(100, Math.floor(uncappedScore)))

  // ── GAP & MONTHLY CLOSER ──
  const gap = Math.max(0, requiredCorpus - projectedValue)
  const monthlyGap = gap > 0 && r > 0
    ? (gap * r) / (Math.pow(1 + r, n) - 1)
    : 0

  // ── ANNUITY SPLIT ──
  const annuityCorpus        = projectedValue * ANNUITY_SPLIT
  const lumpSumCorpus        = projectedValue * LUMP_SUM_SPLIT
  const monthlyAnnuityIncome = (annuityCorpus * ANNUITY_RATE) / 12

  // ── BLENDED RETURN (for display) ──
  const blendedReturn = annualReturn

  return {
    // Inputs (pass-through for convenience)
    age, retireAge, years, monthlyIncome,
    monthlyContrib, totalCorpus, equityPct, lifestyle,

    // Core outputs
    projectedValue,
    requiredCorpus,
    score,
    gap,
    monthlyGap,
    monthlySpendAtRetirement,
    readinessRatio,
    uncappedScore,

    // Annuity
    annuityCorpus,
    lumpSumCorpus,
    monthlyAnnuityIncome,

    // Meta
    blendedReturn,
    annualReturn,
    lifestyleMultiplier,
    n, r,
  }
}

// ── WHAT-IF SCENARIOS ───────────────────────
export function computeWhatIfScenarios(userData) {
  const base = calculateRetirement(userData)

  const scenarios = [
    {
      id: 'contribute_more',
      title: 'Contribute ₹2,000 more/month',
      description: 'Increase focus on short-term delta',
      score: calculateRetirement({
        ...userData,
        npsContribution: (parseFloat(userData.npsContribution) || 0) + 2000
      }).score
    },
    {
      id: 'step_up',
      title: 'Enable 10% annual step-up',
      description: 'Grow with your salary hikes',
      score: (() => {
        const d = calculateRetirement(userData)
        const fvStepUp = computeStepUpFV(
          parseFloat(userData.npsContribution) || 0,
          d.annualReturn,
          d.years
        )
        const fvCorpus = d.totalCorpus * Math.pow(1 + d.r, d.n)
        const pv = fvCorpus + fvStepUp
        return Math.min(100, Math.round((pv / d.requiredCorpus) * 100))
      })()
    },
    {
      id: 'retire_later',
      title: 'Retire 2 years later',
      description: 'Power of compounding time',
      score: calculateRetirement({
        ...userData,
        retireAge: (parseInt(userData.retireAge) || 60) + 2
      }).score
    },
    {
      id: 'lifestyle_switch',
      title: (userData.lifestyle || 'comfortable') === 'premium'
        ? 'Switch to Comfortable lifestyle'
        : (userData.lifestyle || 'comfortable') === 'essential'
        ? 'Switch to Comfortable lifestyle'
        : 'Switch to Essential lifestyle',
      description: 'Adjust standard of living',
      score: calculateRetirement({
        ...userData,
        lifestyle: (userData.lifestyle || 'comfortable') === 'comfortable'
          ? 'essential' : 'comfortable'
      }).score
    },
    {
      id: 'lump_sum',
      title: 'Add ₹1L lump sum today',
      description: 'Immediate corpus injection',
      score: calculateRetirement({
        ...userData,
        npsCorpus: (parseFloat(userData.npsCorpus) || 0) + 100000
      }).score
    },
    {
      id: 'max_equity',
      title: `Max equity to ${getMaxEquityPct(parseInt(userData.age) || 30)}%`,
      description: 'Optimize for higher risk/reward',
      score: calculateRetirement({
        ...userData,
        npsEquity: getMaxEquityPct(parseInt(userData.age) || 30)
      }).score
    },
  ]

  return scenarios.map(s => ({
    ...s,
    delta: s.score - base.score
  }))
}

// ── TAX CALCULATOR ──────────────────────────
export function computeTax(annualIncome, regime = 'new', deductions = 0) {
  const stdDeduction  = regime === 'new' ? 75000 : 50000
  const rebateLimit   = regime === 'new' ? 1200000 : 500000
  const slabs         = regime === 'new' ? NEW_REGIME_SLABS : OLD_REGIME_SLABS
  const taxableIncome = Math.max(0, annualIncome - stdDeduction - deductions)

  let tax = 0
  let prev = 0
  for (const slab of slabs) {
    if (taxableIncome <= prev) break
    const taxable = Math.min(taxableIncome, slab.limit) - prev
    tax += taxable * slab.rate
    prev = slab.limit
  }

  // 87A rebate — zero tax if taxable income within limit
  if (taxableIncome <= rebateLimit) tax = 0

  // 4% health & education cess
  return Math.round(tax * 1.04)
}

export function computeTaxSavings(userData) {
  const annualIncome   = (parseFloat(userData.monthlyIncome) || 0) * 12
  const annualContrib  = (parseFloat(userData.npsContribution) || 0) * 12
  const regime         = userData.taxRegime || 'new'
  const basicSalaryPct = userData.workContext === 'Government' ? 0.50 : 0.40
  const basicSalary    = annualIncome * basicSalaryPct
  const govtMultiplier = userData.workContext === 'Government' ? 0.14 : 0.10

  // 80CCD(1) — old regime only
  const ccd1Limit    = Math.min(basicSalary * govtMultiplier, 150000)
  const ccd1Used     = regime === 'old' ? Math.min(annualContrib, ccd1Limit) : 0
  const ccd1Missed   = regime === 'old' ? ccd1Limit - ccd1Used : 0

  // 80CCD(1B) — old regime only, extra ₹50k
  const ccd1bLimit   = 50000
  const ccd1bUsed    = regime === 'old'
    ? Math.min(Math.max(0, annualContrib - ccd1Limit), ccd1bLimit) : 0
  const ccd1bMissed  = regime === 'old' ? ccd1bLimit - ccd1bUsed : 0

  // 80CCD(2) — both regimes, employer contribution
  const ccd2Limit    = basicSalary * govtMultiplier
  // we don't know employer contribution so show as potential
  const ccd2Potential = ccd2Limit

  // Total deductions
  const totalDeductions = ccd1Used + ccd1bUsed

  // Tax comparison
  const taxWithNPS    = computeTax(annualIncome, regime, totalDeductions)
  const taxWithoutNPS = computeTax(annualIncome, regime, 0)
  const taxSaved      = taxWithoutNPS - taxWithNPS
  const potentialSaving = computeTax(annualIncome, regime, 0) -
    computeTax(annualIncome, regime, ccd1Limit + ccd1bLimit)

  return {
    annualIncome, basicSalary, regime,
    ccd1: { limit: ccd1Limit, used: ccd1Used, missed: ccd1Missed },
    ccd1b: { limit: ccd1bLimit, used: ccd1bUsed, missed: ccd1bMissed },
    ccd2: { potential: ccd2Potential },
    taxSaved,
    potentialSaving,
    taxWithNPS,
    taxWithoutNPS,
  }
}
