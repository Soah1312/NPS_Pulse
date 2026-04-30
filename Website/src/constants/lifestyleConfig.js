// ============================================
// Lifestyle Configuration
// ============================================
// Defines spending categories and preset lifestyle tiers for retirement.
//
// LIFESTYLE TIERS:
// - essential (40%): Minimal spending, only necessary items
// - comfortable (60%): Moderate spending, balanced lifestyle
// - premium (80%): High spending, luxury goods/experiences
//
// SPENDING CATEGORIES:
// Users' retirement spending is broken into 6 categories:
// Housing, Food, Healthcare, Travel, Family, Emergency Buffer
// Each category has a default share (e.g., housing 35%, food 20%)
// These can be customized for more granular control
//
// VERSION: Track config schema changes (helps with migrations)

export const LIFESTYLE_CONFIG_VERSION = 1;

/**
 * Preset lifestyle modes
 * User selects one of these presets or enters custom spending amount
 */
export const LIFESTYLE_MODES = {
  PRESET: 'preset',    // Use a standard tier (essential/comfortable/premium)
  CUSTOM: 'custom',    // User specifies exact monthly retirement spending
};

/**
 * Spending multipliers for each lifestyle tier.
 * Based on current monthly income.
 *
 * Example: If monthly income is ₹100K
 * - essential lifestyle → ₹40K/month in retirement
 * - comfortable lifestyle → ₹60K/month in retirement
 * - premium lifestyle → ₹80K/month in retirement
 */
export const LIFESTYLE_MULTIPLIERS = {
  essential: 0.40,   // 40% of current income
  comfortable: 0.60, // 60% of current income
  premium: 0.80,     // 80% of current income
};

/**
 * Breakdown of spending across categories for each lifestyle.
 * Numbers show the percentage of retirement budget allocated to each category.
 *
 * Example: Comfortable lifestyle, housing gets 35%, food gets 20%, etc.
 * Users can adjust these ratios for their specific situation.
 */
export const LIFESTYLE_CATEGORY_BLUEPRINT = [
  // Housing: Rent/EMI, utilities, maintenance, property tax
  { id: 'housing', name: 'Housing & Utilities', defaultShare: 35, color: '#8B5CF6', tooltipKey: 'categoryHousing' },
  
  // Food: Groceries, dining out, kitchen costs
  { id: 'food', name: 'Food & Dining', defaultShare: 20, color: '#F472B6', tooltipKey: 'categoryFood' },
  
  // Healthcare: Medicines, doctors, insurance, treatments
  { id: 'healthcare', name: 'Healthcare', defaultShare: 15, color: '#EF4444', tooltipKey: 'categoryHealthcare' },
  
  // Travel: Holidays, local transport, vehicle maintenance
  { id: 'travel', name: 'Travel & Leisure', defaultShare: 15, color: '#FBBF24', tooltipKey: 'categoryTravel' },
  
  // Family: Gifts, events, support for dependents, misc
  { id: 'family', name: 'Family & Misc', defaultShare: 10, color: '#34D399', tooltipKey: 'categoryFamily' },
  
  // Emergency: Buffer for unexpected costs
  { id: 'buffer', name: 'Emergency Buffer', defaultShare: 5, color: '#3B82F6', tooltipKey: 'categoryEmergency' },
];

// Helper constants for validation
const PRESET_KEYS = Object.keys(LIFESTYLE_MULTIPLIERS); // ['essential', 'comfortable', 'premium']
const CATEGORY_IDS = LIFESTYLE_CATEGORY_BLUEPRINT.map((item) => item.id);

/**
 * Clamp a value between min and max bounds.
 * Ensures numbers stay within valid ranges.
 */
function clamp(value, min, max) {
  if (!Number.isFinite(value)) return min;
  return Math.max(min, Math.min(max, value));
}

/**
 * Round a number to 1 decimal place.
 * Used for percentage calculations to avoid floating point errors.
 */
function roundOne(value) {
  return Math.round(value * 10) / 10;
}

/**
 * Validate and normalize a lifestyle preset string.
 * Returns 'comfortable' if input is invalid.
 */
export function normalizeLifestylePreset(value, fallback = 'comfortable') {
  const normalized = String(value || '').trim().toLowerCase();
  if (PRESET_KEYS.includes(normalized)) return normalized;
  return PRESET_KEYS.includes(fallback) ? fallback : 'comfortable';
}

/**
 * Validate lifestyle mode (preset vs custom).
 * Defaults to 'preset' if invalid.
 */
export function normalizeLifestyleMode(value) {
  return value === LIFESTYLE_MODES.CUSTOM ? LIFESTYLE_MODES.CUSTOM : LIFESTYLE_MODES.PRESET;
}

/**
 * Normalize and balance spending category percentages.
 * Ensures all categories add up to exactly 100%.
 *
 * Process:
 * 1. Validate each category's percentage (0-100%)
 * 2. Total them up
 * 3. Redistribute to make sum exactly 100%
 * 4. Round to prevent floating-point drift
 */
export function normalizeCategoryMix(rawMix = {}) {
  // Step 1: Start with input values, or use defaults if missing
  const seed = CATEGORY_IDS.reduce((acc, id, index) => {
    const fallbackShare = LIFESTYLE_CATEGORY_BLUEPRINT[index].defaultShare;
    const rawValue = Number(rawMix?.[id]);
    acc[id] = Number.isFinite(rawValue) ? clamp(rawValue, 0, 100) : fallbackShare;
    return acc;
  }, {});

  // Step 2: Calculate total
  const total = Object.values(seed).reduce((sum, value) => sum + value, 0);
  
  // If total is zero or negative, reset to defaults
  if (total <= 0) {
    return CATEGORY_IDS.reduce((acc, id, index) => {
      acc[id] = LIFESTYLE_CATEGORY_BLUEPRINT[index].defaultShare;
      return acc;
    }, {});
  }

  // Step 3: Normalize each category to be a proportion of 100%
  const normalized = CATEGORY_IDS.reduce((acc, id) => {
    acc[id] = roundOne((seed[id] / total) * 100);
    return acc;
  }, {});

  // Step 4: Handle floating-point rounding drift
  const normalizedTotal = Object.values(normalized).reduce((sum, value) => sum + value, 0);
  const drift = roundOne(100 - normalizedTotal);
  
  // If drift exists, add it to the first category
  if (Math.abs(drift) > 0) {
    normalized[CATEGORY_IDS[0]] = roundOne(normalized[CATEGORY_IDS[0]] + drift);
  }

  return normalized;
}

/**
 * Create default lifestyle configuration with all fields.
 * Used when creating a new user profile.
 */
export function createDefaultLifestyleConfig(lifestyle = 'comfortable') {
  return {
    version: LIFESTYLE_CONFIG_VERSION,
    mode: LIFESTYLE_MODES.PRESET,                    // Start with preset tier
    preset: normalizeLifestylePreset(lifestyle),     // Which tier (essential/comfortable/premium)
    customMonthlySpend: 0,                            // Custom amount (only if mode=CUSTOM)
    categories: normalizeCategoryMix(),               // Default spending breakdown
  };
}

/**
 * Validate and normalize existing lifestyle configuration.
 * Fills in missing fields and validates everything.
 * Used when loading user profile from database.
 */
export function normalizeLifestyleConfig(config, fallbackLifestyle = 'comfortable') {
  const defaults = createDefaultLifestyleConfig(fallbackLifestyle);

  if (!config || typeof config !== 'object') {
    return defaults;
  }

  return {
    version: LIFESTYLE_CONFIG_VERSION,
    mode: normalizeLifestyleMode(config.mode),
    preset: normalizeLifestylePreset(config.preset, defaults.preset),
    customMonthlySpend: Math.max(0, Number(config.customMonthlySpend) || 0),
    categories: normalizeCategoryMix(config.categories),
  };
}
