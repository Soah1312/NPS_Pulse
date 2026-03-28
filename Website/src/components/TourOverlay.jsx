import React, { useState, useEffect, useRef, useCallback } from 'react';
import { ChevronLeft, ChevronRight, X, Sparkles } from 'lucide-react';

/**
 * TourOverlay — full-screen spotlight guided tour.
 *
 * Props:
 *   steps       — array of { targetId, title, description }
 *   onComplete  — called when user finishes last step
 *   onSkip      — called when user skips
 */
export default function TourOverlay({ steps, onComplete, onSkip }) {
  const [currentStep, setCurrentStep] = useState(0);
  const [targetRect, setTargetRect] = useState(null);
  const cardRef = useRef(null);
  const prefersReduced = useRef(
    typeof window !== 'undefined' &&
      window.matchMedia('(prefers-reduced-motion: reduce)').matches
  );

  const step = steps[currentStep];

  // ─── Measure target element ──────────────────────────────────────
  const measure = useCallback(() => {
    if (!step) return;
    const el = document.getElementById(step.targetId);
    if (!el) return;
    const r = el.getBoundingClientRect();
    const pad = 12;
    setTargetRect({
      x: r.x - pad + window.scrollX,
      y: r.y - pad + window.scrollY,
      w: r.width + pad * 2,
      h: r.height + pad * 2,
      elRect: r,
    });

    // Scroll into view
    if (prefersReduced.current) {
      el.scrollIntoView({ block: 'center', behavior: 'instant' });
    } else {
      el.scrollIntoView({ block: 'center', behavior: 'smooth' });
    }
  }, [step]);

  useEffect(() => {
    // small delay to let any animations settle before measuring
    const t = setTimeout(measure, 250);
    return () => clearTimeout(t);
  }, [currentStep, measure]);

  // Re-measure on resize
  useEffect(() => {
    const handleResize = () => measure();
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, [measure]);

  // ─── Keyboard handling ───────────────────────────────────────────
  useEffect(() => {
    const handler = (e) => {
      if (e.key === 'Escape') {
        e.preventDefault();
        onSkip();
      } else if (e.key === 'ArrowRight') {
        e.preventDefault();
        goNext();
      } else if (e.key === 'ArrowLeft') {
        e.preventDefault();
        goPrev();
      }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  });

  // ─── Focus trap ──────────────────────────────────────────────────
  useEffect(() => {
    if (!cardRef.current) return;
    const focusable = cardRef.current.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    if (focusable.length) focusable[0].focus();

    const trap = (e) => {
      if (e.key !== 'Tab') return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      if (e.shiftKey) {
        if (document.activeElement === first) {
          e.preventDefault();
          last.focus();
        }
      } else {
        if (document.activeElement === last) {
          e.preventDefault();
          first.focus();
        }
      }
    };
    window.addEventListener('keydown', trap);
    return () => window.removeEventListener('keydown', trap);
  }, [currentStep]);

  // ─── Navigation ──────────────────────────────────────────────────
  const goNext = () => {
    if (currentStep < steps.length - 1) {
      setCurrentStep((s) => s + 1);
    } else {
      onComplete();
    }
  };
  const goPrev = () => {
    if (currentStep > 0) setCurrentStep((s) => s - 1);
  };

  // ─── Card positioning ────────────────────────────────────────────
  const getCardStyle = () => {
    if (!targetRect) return { top: '50%', left: '50%', transform: 'translate(-50%, -50%)' };
    const { elRect } = targetRect;
    const cardW = 380;
    const cardH = 220;
    const gap = 24;

    let top, left;

    // Prefer below the element
    if (elRect.bottom + gap + cardH < window.innerHeight) {
      top = elRect.bottom + gap + window.scrollY;
    } else {
      // Place above
      top = elRect.top - cardH - gap + window.scrollY;
    }

    // Horizontal centering clamped to viewport
    left = elRect.left + elRect.width / 2 - cardW / 2 + window.scrollX;
    left = Math.max(16, Math.min(left, window.innerWidth - cardW - 16));
    top = Math.max(16, top);

    return { top, left, width: cardW };
  };

  if (!step) return null;

  const cardStyle = getCardStyle();

  return (
    <div className="tour-overlay-root" style={{ position: 'fixed', inset: 0, zIndex: 9999 }}>
      {/* ── Dark overlay with SVG cutout ── */}
      <svg
        aria-hidden="true"
        style={{ position: 'absolute', inset: 0, width: '100%', height: '100%', pointerEvents: 'none' }}
        xmlns="http://www.w3.org/2000/svg"
      >
        <defs>
          <mask id="tour-spotlight-mask">
            <rect x="0" y="0" width="100%" height="100%" fill="white" />
            {targetRect && (
              <rect
                x={targetRect.x - window.scrollX}
                y={targetRect.y - window.scrollY}
                width={targetRect.w}
                height={targetRect.h}
                rx="16"
                fill="black"
              />
            )}
          </mask>
        </defs>
        <rect
          x="0" y="0" width="100%" height="100%"
          fill="rgba(30, 41, 59, 0.65)"
          mask="url(#tour-spotlight-mask)"
          style={{ backdropFilter: 'blur(2px)' }}
        />
      </svg>

      {/* ── Click-to-skip backdrop ── */}
      <div
        style={{ position: 'absolute', inset: 0 }}
        onClick={onSkip}
        aria-label="Skip tour"
      />

      {/* ── Pulse ring around target ── */}
      {targetRect && (
        <div
          className="tour-pulse-ring"
          style={{
            position: 'absolute',
            top: targetRect.y - window.scrollY,
            left: targetRect.x - window.scrollX,
            width: targetRect.w,
            height: targetRect.h,
            borderRadius: 16,
            border: '3px solid #8B5CF6',
            pointerEvents: 'none',
          }}
        />
      )}

      {/* ── Tour Card ── */}
      <div
        ref={cardRef}
        role="dialog"
        aria-modal="true"
        aria-label={`Tour step ${currentStep + 1} of ${steps.length}`}
        className="tour-card"
        style={{
          position: 'absolute',
          ...cardStyle,
        }}
        onClick={(e) => e.stopPropagation()}
      >
        {/* Step indicator strip */}
        <div className="flex gap-1.5 mb-4">
          {steps.map((_, i) => (
            <div
              key={i}
              className="h-1 rounded-full flex-1 transition-all duration-300"
              style={{
                backgroundColor: i <= currentStep ? '#8B5CF6' : 'rgba(255,255,255,0.15)',
              }}
            />
          ))}
        </div>

        <div className="flex items-center gap-2 mb-2">
          <Sparkles className="w-4 h-4 text-[#FBBF24]" fill="currentColor" />
          <span className="text-[9px] font-black uppercase tracking-[3px] text-white/40">
            Step {currentStep + 1} of {steps.length}
          </span>
        </div>

        <h3
          className="font-heading font-extrabold text-xl text-white mb-2 leading-tight"
          style={{ fontFamily: "'Outfit', sans-serif" }}
        >
          {step.title}
        </h3>

        <p
          aria-live="polite"
          className="text-[12px] font-bold text-white/70 leading-relaxed mb-6"
        >
          {step.description}
        </p>

        <div className="flex items-center justify-between">
          <button
            onClick={onSkip}
            className="text-[10px] font-black uppercase tracking-widest text-white/30 hover:text-white/70 transition-colors px-2 py-1"
          >
            Skip tour
          </button>
          <div className="flex gap-2">
            {currentStep > 0 && (
              <button
                onClick={goPrev}
                className="w-10 h-10 rounded-full border-2 border-white/20 flex items-center justify-center text-white/60 hover:text-white hover:border-white/40 transition-all"
              >
                <ChevronLeft className="w-5 h-5" />
              </button>
            )}
            <button
              onClick={goNext}
              className="px-6 h-10 bg-[#8B5CF6] text-white rounded-full border-2 border-white/20 font-black uppercase tracking-widest text-[10px] flex items-center gap-2 hover:bg-[#7C3AED] transition-colors shadow-[3px_3px_0_0_rgba(0,0,0,0.3)]"
            >
              {currentStep < steps.length - 1 ? (
                <>Next <ChevronRight className="w-4 h-4" /></>
              ) : (
                <>Finish <span>🎉</span></>
              )}
            </button>
          </div>
        </div>
      </div>

      <style>{`
        .tour-card {
          background: #1E293B;
          border: 2px solid #8B5CF6;
          border-radius: 20px;
          padding: 24px;
          box-shadow: 8px 8px 0 0 rgba(139, 92, 246, 0.3);
          animation: tourCardIn 0.35s cubic-bezier(0.34, 1.56, 0.64, 1) forwards;
          z-index: 10;
        }
        @keyframes tourCardIn {
          from { opacity: 0; transform: translateY(12px) scale(0.97); }
          to   { opacity: 1; transform: translateY(0) scale(1); }
        }

        .tour-pulse-ring {
          animation: tourPulse 2s ease-in-out infinite;
          z-index: 5;
        }
        @keyframes tourPulse {
          0%, 100% { box-shadow: 0 0 0 0 rgba(139, 92, 246, 0.5); }
          50%      { box-shadow: 0 0 0 8px rgba(139, 92, 246, 0); }
        }

        @media (prefers-reduced-motion: reduce) {
          .tour-card {
            animation: none !important;
            opacity: 1;
          }
          .tour-pulse-ring {
            animation: none !important;
            box-shadow: none;
          }
        }
      `}</style>
    </div>
  );
}
