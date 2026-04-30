// ============================================
// Investment Schemes & Retirement Modes
// ============================================
// Configuration for all supported investment instruments.
// Users can combine NPS with PPF, MF SIPs, stocks, FDs, etc.
//
// RETIREMENT MODES:
// - NPS_ONLY: Only using NPS for retirement (typical government employee)
// - NON_NPS_ONLY: Not using NPS at all (freelancers, entrepreneurs)
// - HYBRID: Combination of NPS + other schemes (most common)
//
// RETURN ASSUMPTIONS:
// These are conservative, historical 10-year averages.
// User can override these if they have custom expectations.

export const RETIREMENT_MODES = {
  NPS_ONLY: 'nps_only',         // Single income stream: NPS annuity + lump sum
  NON_NPS_ONLY: 'non_nps_only', // Multiple streams: MF, stocks, FD, etc (no NPS)
  HYBRID: 'hybrid',              // NPS + other schemes combined
};

/**
 * Documents the assumption basis for return rates.
 * Helps users understand where these numbers come from.
 */
export const SCHEME_ASSUMPTION_BASIS = 'Policy baseline FY2026';

/**
 * Default conservative return for custom schemes.
 * User can override this when adding their own investment type.
 */
export const OTHER_SCHEME_DEFAULT_RETURN = 0.08; // 8% p.a.

/**
 * Min/max bounds for user-customizable return assumptions.
 * Prevents unrealistic expectations (negative returns or >18% SIPs).
 */
export const ASSUMED_RETURN_MIN_PCT = 3;   // 3% minimum
export const ASSUMED_RETURN_MAX_PCT = 18;  // 18% maximum

/**
 * All supported investment schemes (except NPS which is core).
 * User can toggle each on/off and enter monthly contribution amount.
 */
export const OTHER_SCHEME_CONFIGS = [
  {
    id: 'ppf',
    label: 'PPF',
    toggleField: 'usesPPF',                    // User enables/disables this scheme
    monthlyField: 'ppfMonthlyContribution',    // Monthly contribution amount
    assumptionField: 'ppfAssumedReturnPct',    // User's custom return %, if override enabled
    assumptionLabel: 'Govt rate assumption',   // Label for the override field
    annualReturn: 0.071,                       // 7.1% p.a. (government-declared rate)
  },
  {
    id: 'epf_vpf',
    label: 'EPF / VPF',
    toggleField: 'usesEPFVPF',
    monthlyField: 'epfVpfMonthlyContribution',
    assumptionField: 'epfVpfAssumedReturnPct',
    assumptionLabel: 'Declared EPF baseline',
    annualReturn: 0.0825,                      // 8.25% p.a. (typical EPF dividend)
  },
  {
    id: 'mf_sip',
    label: 'Mutual Funds (SIP)',
    toggleField: 'usesMFSIP',
    monthlyField: 'mfSipMonthlyContribution',
    assumptionField: 'mfSipAssumedReturnPct',
    assumptionLabel: 'Diversified equity SIP baseline',
    annualReturn: 0.105,                       // 10.5% p.a. (balanced equity funds)
  },
  {
    id: 'stocks_etf',
    label: 'Stocks / ETF',
    toggleField: 'usesStocksETF',
    monthlyField: 'stocksEtfMonthlyContribution',
    assumptionField: 'stocksEtfAssumedReturnPct',
    assumptionLabel: 'Long-run equity baseline',
    annualReturn: 0.11,                        // 11% p.a. (SENSEX/Nifty long-term)
  },
  {
    id: 'fd_rd',
    label: 'FD / RD',
    toggleField: 'usesFDRD',
    monthlyField: 'fdRdMonthlyContribution',
    assumptionField: 'fdRdAssumedReturnPct',
    assumptionLabel: 'Bank deposit baseline',
    annualReturn: 0.0675,                      // 6.75% p.a. (bank FD rates)
  },
  {
    id: 'other_custom',
    label: 'Other Scheme',
    toggleField: 'usesOtherScheme',
    monthlyField: 'otherSchemeMonthlyContribution',
    assumptionField: 'otherSchemeAssumedReturnPct',
    assumptionLabel: 'Conservative default assumption',
    annualReturn: OTHER_SCHEME_DEFAULT_RETURN, // 8% default
  },
];

/**
 * Format a return rate as a percentage string for display.
 * Example: 0.105 → "10.50%"
 */
export function formatAnnualReturnPct(rate) {
  return `${(Math.max(0, Number(rate) || 0) * 100).toFixed(2)}%`;
}

/**
 * Validate and normalize user-entered return percentage.
 * Clamps value between MIN and MAX bounds.
 * Falls back to scheme's default if invalid input.
 */
export function normalizeAssumedReturnPct(value, fallbackRate) {
  const parsed = Number(value);
  const fallbackPct = (Math.max(0, Number(fallbackRate) || 0) * 100);

  // If input is invalid/empty, use fallback
  if (!Number.isFinite(parsed) || parsed <= 0) {
    return Number(fallbackPct.toFixed(2));
  }

  // Clamp between MIN and MAX, return as percentage
  return Number(
    Math.max(ASSUMED_RETURN_MIN_PCT, Math.min(ASSUMED_RETURN_MAX_PCT, parsed)).toFixed(2)
  );
}

/**
 * Get the annual return rate for a scheme (as decimal, e.g., 0.105 = 10.5%).
 * If custom assumptions are enabled, uses user's override, otherwise uses default.
 */
export function getSchemeAnnualReturn(data = {}, scheme) {
  const useCustomAssumptions = Boolean(data?.customSchemeAssumptionsEnabled);
  if (!useCustomAssumptions || !scheme?.assumptionField) {
    return scheme?.annualReturn || OTHER_SCHEME_DEFAULT_RETURN;
  }

  const assumedPct = normalizeAssumedReturnPct(data?.[scheme.assumptionField], scheme.annualReturn);
  return assumedPct / 100;
}

/**
 * Get the annual return rate for a scheme as a percentage (e.g., 10.5 = 10.5%).
 * Convenience method for display/logging.
 */
export function getSchemeAssumedReturnPct(data = {}, scheme) {
  const annualRate = getSchemeAnnualReturn(data, scheme);
  return Number((annualRate * 100).toFixed(2));
}

function parseAmount(value) {
  return Math.max(0, Number(value) || 0);
}

export function getTotalOtherSchemeMonthlyContribution(data = {}) {
  return OTHER_SCHEME_CONFIGS.reduce((sum, scheme) => {
    const enabled = Boolean(data?.[scheme.toggleField]);
    if (!enabled) return sum;
    return sum + parseAmount(data?.[scheme.monthlyField]);
  }, 0);
}

export function getOtherSchemeAnnualReturn(data = {}) {
  const selected = OTHER_SCHEME_CONFIGS.filter((scheme) => data?.[scheme.toggleField]);
  if (selected.length === 0) {
    return data?.customSchemeAssumptionsEnabled
      ? getSchemeAnnualReturn(data, OTHER_SCHEME_CONFIGS[OTHER_SCHEME_CONFIGS.length - 1])
      : OTHER_SCHEME_DEFAULT_RETURN;
  }

  const totalContribution = selected.reduce(
    (sum, scheme) => sum + parseAmount(data?.[scheme.monthlyField]),
    0
  );

  if (totalContribution <= 0) {
    const equalWeight = 1 / selected.length;
    return selected.reduce((sum, scheme) => sum + (getSchemeAnnualReturn(data, scheme) * equalWeight), 0);
  }

  return selected.reduce((sum, scheme) => {
    const weight = parseAmount(data?.[scheme.monthlyField]) / totalContribution;
    return sum + (getSchemeAnnualReturn(data, scheme) * weight);
  }, 0);
}

export function inferRetirementMode(data = {}) {
  const npsCorpus = parseAmount(data?.npsCorpus);
  const npsContrib = parseAmount(data?.npsContribution);
  const hasNpsUsage = data?.npsUsage && data?.npsUsage !== 'none';
  const hasNps = hasNpsUsage || npsCorpus > 0 || npsContrib > 0;

  const hasOtherSavings = parseAmount(data?.totalSavings) > 0;
  const hasSchemes = getTotalOtherSchemeMonthlyContribution(data) > 0;
  const hasOther = hasOtherSavings || hasSchemes;

  if (hasNps && hasOther) return RETIREMENT_MODES.HYBRID;
  if (hasNps) return RETIREMENT_MODES.NPS_ONLY;
  return RETIREMENT_MODES.NON_NPS_ONLY;
}
