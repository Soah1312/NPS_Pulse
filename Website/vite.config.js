// ============================================
// Vite Configuration
// ============================================
// Configures the build and development environment for the RetireSahi web application.
//
// KEY FEATURES:
// - React Fast Refresh for hot module reloading during development
// - Tailwind CSS integration for utility-first styling
// - Code splitting: Breaks large JavaScript bundles into smaller chunks
//   This improves initial load time by only downloading necessary code
//
// CHUNK STRATEGY:
// - router: React Router DOM (routing & navigation)
// - markdown: Markdown rendering libraries for AI responses
// - firebase: Firebase SDK (auth & database)
// - icons: Lucide React icon library
// - analytics: Vercel analytics tracking
// - vendor: All other node_modules dependencies

import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import tailwindcss from '@tailwindcss/vite'

export default defineConfig({
  // Enable React Fast Refresh for instant component updates without full page reload
  // Enable Tailwind CSS compilation directly in Vite (faster than PostCSS)
  plugins: [
    react(),
    tailwindcss(),
  ],
  
  build: {
    rollupOptions: {
      output: {
        // Manual code chunking strategy optimizes initial load and caching
        manualChunks(id) {
          // Only chunk code from node_modules (not your source code)
          if (!id.includes('node_modules')) return;

          // Create separate chunk for routing library (needed on every page)
          if (id.includes('react-router-dom')) return 'router';
          
          // Create separate chunk for markdown rendering (only used on AI copilot page)
          if (id.includes('react-markdown') || id.includes('remark-gfm')) return 'markdown';
          
          // Create separate chunk for Firebase (needed for auth but lazy-loaded)
          if (id.includes('firebase')) return 'firebase';
          
          // Create separate chunk for icons (small but used everywhere)
          if (id.includes('lucide-react')) return 'icons';
          
          // Create separate chunk for analytics (loaded only in production)
          if (id.includes('@vercel/analytics')) return 'analytics';

          // All other third-party packages go into a "vendor" chunk
          return 'vendor';
        },
      },
    },
  },
})
