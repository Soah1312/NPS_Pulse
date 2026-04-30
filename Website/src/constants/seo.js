// ============================================
// SEO Configuration Constants
// ============================================
// Centralized SEO metadata for all pages.
// Each route has its own title, description, image, and structured data.
//
// WHAT THIS CONTROLS:
// - Browser tab titles
// - Google search result snippets (title + description)
// - Social media preview cards (OpenGraph + Twitter)
// - JSON-LD structured data for Google Rich Results
//
// USAGE: SeoHead component pulls from here and injects into HTML head

const SITE_URL = (import.meta.env.VITE_SITE_URL || 'https://retiresahi.vercel.app').replace(/\/$/, '');
const BRAND_NAME = 'RetireSahi';
const DEFAULT_IMAGE = `${SITE_URL}/favicon.svg`;

/**
 * JSON-LD schema for Organization
 * Tells Google who this organization is
 */
const ORGANIZATION_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'Organization',
  name: BRAND_NAME,
  url: SITE_URL,
  logo: DEFAULT_IMAGE,
};

/**
 * JSON-LD schema for Website
 * Marks this as a website and enables search box features
 */
const WEBSITE_SCHEMA = {
  '@context': 'https://schema.org',
  '@type': 'WebSite',
  name: BRAND_NAME,
  url: SITE_URL,
  inLanguage: 'en-IN',
};

/**
 * Default SEO settings for pages without custom settings
 * Used as fallback for unlisted routes
 */
export const DEFAULT_SEO = {
  title: `${BRAND_NAME} | Retirement Planning & NPS Insights`,
  description:
    'RetireSahi helps you understand retirement readiness, NPS strategy, and tax-saving opportunities with practical guidance for Indian investors.',
  robots: 'index,follow',           // Allow Google to index and follow links
  canonicalPath: '/',               // Canonical URL for this page
  ogType: 'website',                // OpenGraph type for social sharing
  twitterCard: 'summary_large_image', // Twitter card format
  image: DEFAULT_IMAGE,             // Social media preview image
  structuredData: [ORGANIZATION_SCHEMA, WEBSITE_SCHEMA],
};

/**
 * Per-route SEO configuration
 * Maps URL paths to their SEO metadata
 */
export const ROUTE_SEO = {
  // Landing page — public, indexed, aim for Google search visibility
  '/': {
    title: `${BRAND_NAME} | Know Exactly Where Your Retirement Stands`,
    description:
      'Measure retirement readiness, understand your NPS trajectory, and plan tax-smart contributions with RetireSahi.',
    canonicalPath: '/',
    ogType: 'website',
    structuredData: [ORGANIZATION_SCHEMA, WEBSITE_SCHEMA],
  },
  
  // Learning hub — public educational content, indexed for SEO
  '/learn': {
    title: `Learn Retirement Planning | ${BRAND_NAME}`,
    description:
      'Explore practical guides on retirement planning, NPS optimization, and long-term wealth strategy tailored for India.',
    canonicalPath: '/learn',
    ogType: 'article',
    structuredData: [
      {
        '@context': 'https://schema.org',
        '@type': 'CollectionPage',
        name: 'Retirement Learning Hub',
        url: `${SITE_URL}/learn`,
        inLanguage: 'en-IN',
        isPartOf: {
          '@type': 'WebSite',
          name: BRAND_NAME,
          url: SITE_URL,
        },
      },
    ],
  },
  
  // Methodology page — public, explains calculation approach
  '/methodology': {
    title: `Methodology | ${BRAND_NAME}`,
    description:
      'Review the assumptions, formulas, and calculation approach behind RetireSahi retirement projections and scoring.',
    canonicalPath: '/methodology',
    ogType: 'article',
    structuredData: [
      {
        '@context': 'https://schema.org',
        '@type': 'TechArticle',
        headline: 'RetireSahi Methodology',
        url: `${SITE_URL}/methodology`,
        author: {
          '@type': 'Organization',
          name: BRAND_NAME,
        },
        publisher: {
          '@type': 'Organization',
          name: BRAND_NAME,
          logo: {
            '@type': 'ImageObject',
            url: DEFAULT_IMAGE,
          },
        },
      },
    ],
  },
  
  // Onboarding — private, not indexed (user-specific data)
  '/onboarding': {
    title: `Onboarding | ${BRAND_NAME}`,
    description: 'Secure onboarding area for your retirement profile setup.',
    canonicalPath: '/onboarding',
    robots: 'noindex,nofollow',  // Hide from search engines
  },
  
  // Dashboard — private, not indexed (personal financial data)
  '/dashboard': {
    title: `Dashboard | ${BRAND_NAME}`,
    description: 'Private retirement dashboard with personalized insights.',
    canonicalPath: '/dashboard',
    robots: 'noindex,nofollow',  // Hide from search engines
  },
  '/tax-shield': {
    title: `Tax Shield | ${BRAND_NAME}`,
    description: 'Private tax optimization dashboard for your profile.',
    canonicalPath: '/tax-shield',
    robots: 'noindex,nofollow',
  },
  '/dream-planner': {
    title: `Dream Planner | ${BRAND_NAME}`,
    description: 'Private lifestyle and retirement target planning tools.',
    canonicalPath: '/dream-planner',
    robots: 'noindex,nofollow',
  },
  '/ai-copilot': {
    title: `AI Copilot | ${BRAND_NAME}`,
    description: 'Private AI retirement copilot for personalized guidance.',
    canonicalPath: '/ai-copilot',
    robots: 'noindex,nofollow',
  },
  '/settings': {
    title: `Settings | ${BRAND_NAME}`,
    description: 'Private account and preferences settings.',
    canonicalPath: '/settings',
    robots: 'noindex,nofollow',
  },
};

function normalizePathname(pathname) {
  if (!pathname) return '/';
  if (pathname === '/') return '/';
  return pathname.endsWith('/') ? pathname.slice(0, -1) : pathname;
}

export function getSeoForPath(pathname) {
  const normalizedPath = normalizePathname(pathname);
  const routeSeo = ROUTE_SEO[normalizedPath] || DEFAULT_SEO;
  const canonicalPath = routeSeo.canonicalPath || normalizedPath;

  return {
    ...DEFAULT_SEO,
    ...routeSeo,
    canonical: `${SITE_URL}${canonicalPath}`,
    image: routeSeo.image || DEFAULT_IMAGE,
  };
}

export { SITE_URL, BRAND_NAME, DEFAULT_IMAGE };