// ============================================
// User Profile Context
// ============================================
// Global state container for user's financial profile.
// All retirement calculations depend on these values.
// Used across Dashboard, TaxShield, DreamPlanner, AICopilot pages.
//
// SENSITIVE DATA: firstName, income, corpus, savings amounts are encrypted before Firestore write.
// NON-SENSITIVE: score, lifestyle, age, tax regime are sent to Groq AI for advice.

import { createContext, useContext } from 'react';
import { createDefaultLifestyleConfig, normalizeLifestyleConfig } from '../constants/lifestyleConfig.js';
import { RETIREMENT_MODES, inferRetirementMode } from '../constants/investmentSchemes.js';

export const UserContext = createContext();

// Default empty state loaded before user data is fetched from Firestore
// Each field has a sensible default (strings are empty, numbers are 0 or preset values)
export const INITIAL_USER_DATA = {
  firstName: '',
  age: '',
  workContext: '',
  monthlyIncome: '',
  retirementMode: '',
  npsUsage: '',
  npsContribution: '',
  npsCorpus: '',
  npsEquity: 50,
  retireAge: 60,
  lifestyle: '',
  lifestyleConfig: createDefaultLifestyleConfig('comfortable'),
  customRetirementMonthlyAmount: 0,
  retirementGoalType: 'preset',
  addSavings: false,
  totalSavings: '',
  usesPPF: false,
  ppfMonthlyContribution: '',
  usesEPFVPF: false,
  epfVpfMonthlyContribution: '',
  usesMFSIP: false,
  mfSipMonthlyContribution: '',
  usesStocksETF: false,
  stocksEtfMonthlyContribution: '',
  usesFDRD: false,
  fdRdMonthlyContribution: '',
  usesOtherScheme: false,
  otherSchemeMonthlyContribution: '',
  customSchemeAssumptionsEnabled: false,
  ppfAssumedReturnPct: 7.1,
  epfVpfAssumedReturnPct: 8.25,
  mfSipAssumedReturnPct: 10.5,
  stocksEtfAssumedReturnPct: 11,
  fdRdAssumedReturnPct: 6.75,
  otherSchemeAssumedReturnPct: 8,
  taxRegime: 'new',
  homeLoanInterest: 0,
  lifeInsurance_80C: 0,
  elss_ppf_80C: 0,
  medicalInsurance_80D: 0,
  educationLoanInterest_80E: 0,
  houseRentAllowance_HRA: 0,
  actualRentPaid: 0,
  leaveTravelAllowance_LTA: 0,
  isGovtEmployee: false,
  basicSalaryPct: 0.4,
  hasOptedForEmployerNPS: false,
  employerNPSAmount: 0,
};

export const withInitialUserData = (userData) => {
  const merged = {
    ...INITIAL_USER_DATA,
    ...(userData || {}),
  };

  const fallbackLifestyle = merged.lifestyle?.trim()?.toLowerCase() || 'comfortable';
  const knownMode = Object.values(RETIREMENT_MODES).includes(merged.retirementMode)
    ? merged.retirementMode
    : inferRetirementMode(merged);
  const retirementGoalType = merged.retirementGoalType === 'custom' ? 'custom' : 'preset';
  const customRetirementMonthlyAmount = retirementGoalType === 'custom'
    ? Math.max(0, Number(merged.customRetirementMonthlyAmount) || 0)
    : 0;

  return {
    ...merged,
    retirementMode: knownMode,
    lifestyle: fallbackLifestyle,
    lifestyleConfig: normalizeLifestyleConfig(merged.lifestyleConfig, fallbackLifestyle),
    retirementGoalType,
    customRetirementMonthlyAmount,
  };
};

export const useUser = () => {
  const context = useContext(UserContext);
  if (!context) throw new Error('useUser must be used within a DashboardLayout');
  return context;
};
