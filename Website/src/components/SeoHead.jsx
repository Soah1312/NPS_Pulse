// ============================================
// SEO Meta Tags Manager
// ============================================
// Automatically sets meta tags and OpenGraph data for each page.
// This improves search engine rankings and social media sharing.
//
// WHAT IT DOES:
// - Updates page title dynamically (browser tab name)
// - Sets meta description (shown in Google search results)
// - Configures OpenGraph tags (rich previews on Facebook, Twitter)
// - Adds JSON-LD structured data (helps Google understand page content)
// - Sets canonical URLs (tells search engines the official page location)
//
// USAGE: Place <SeoHead /> once in App.jsx wrapper — it auto-updates on route change

import { Helmet } from 'react-helmet-async';
import { useLocation } from 'react-router-dom';
import { BRAND_NAME, getSeoForPath } from '../constants/seo';

/**
 * Manages SEO meta tags for each page in the application.
 * Uses react-helmet-async to safely inject tags into the document head.
 * Pulls configuration from seo.js constants based on current route.
 */
export default function SeoHead() {
  // Get current page path (e.g., /dashboard, /learn, /)
  const location = useLocation();
  // Fetch SEO config for this page (title, description, image, etc.)
  const seo = getSeoForPath(location.pathname);

  return (
    <Helmet prioritizeSeoTags>
      {/* HTML language attribute for accessibility */}
      <html lang="en" />
      
      {/* Basic meta tags for search engines */}
      <title>{seo.title}</title>
      <meta name="description" content={seo.description} />
      <meta name="robots" content={seo.robots} /> {/* index=searchable, follow=allow link crawling */}
      <link rel="canonical" href={seo.canonical} /> {/* Tells Google this is the official URL */}

      {/* OpenGraph tags for social media sharing (Facebook, LinkedIn, etc) */}
      <meta property="og:site_name" content={BRAND_NAME} />
      <meta property="og:locale" content="en_IN" /> {/* English, India */}
      <meta property="og:type" content={seo.ogType} /> {/* website | article | etc */}
      <meta property="og:title" content={seo.ogTitle || seo.title} /> {/* Title when shared */}
      <meta property="og:description" content={seo.ogDescription || seo.description} />
      <meta property="og:url" content={seo.canonical} /> {/* URL when shared */}
      <meta property="og:image" content={seo.image} /> {/* Preview image when shared */}

      {/* Twitter card tags for Twitter/X sharing */}
      <meta name="twitter:card" content={seo.twitterCard} /> {/* summary_large_image | summary */}
      <meta name="twitter:title" content={seo.twitterTitle || seo.title} />
      <meta name="twitter:description" content={seo.twitterDescription || seo.description} />
      <meta name="twitter:image" content={seo.image} />

      {/* JSON-LD structured data (helps Google understand page content) */}
      {/* Examples: Organization, Article, BreadcrumbList, etc */}
      {(seo.structuredData || []).map((item, index) => (
        <script key={`ld-json-${location.pathname}-${index}`} type="application/ld+json">
          {JSON.stringify(item)}
        </script>
      ))}
    </Helmet>
  );
}