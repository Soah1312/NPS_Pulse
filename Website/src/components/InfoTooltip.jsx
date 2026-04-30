// ============================================
// Info Tooltip Component
// ============================================
// A small ℹ️ icon button that shows a help tooltip on hover or focus.
// Used throughout the app to explain complex concepts without cluttering the UI.
//
// KEY FEATURES:
// - Smart positioning: Opens above or below depending on available space
// - Mobile friendly: Tooltip width scales on small screens
// - Accessible: Keyboard focus support, ARIA labels, prefers-reduced-motion
// - Animated: Smooth fade-in with accessible reduced-motion support
//
// USAGE:
// <InfoTooltip text="Your NPS contribution toward retirement savings" size={16} />

import React, { useState, useRef, useEffect, useCallback } from 'react';
import { Info } from 'lucide-react';

/**
 * InfoTooltip — a small ℹ️ button that shows a help bubble on hover/focus.
 *
 * Props:
 *   text       — string to display in the tooltip
 *   size       — icon pixel size (default 14)
 *   className  — extra CSS classes for the wrapper span
 */
export default function InfoTooltip({ text, size = 14, className = '' }) {
  const [visible, setVisible] = useState(false);
  const [pos, setPos] = useState({ top: true, left: false }); // which direction to open
  const btnRef = useRef(null);
  const tipRef = useRef(null);

  // Recalculate best position when visible changes
  // Avoids tooltip going off-screen on small devices
  const recalc = useCallback(() => {
    if (!btnRef.current) return;
    const rect = btnRef.current.getBoundingClientRect();
    const tipW = Math.min(280, Math.max(220, window.innerWidth - 24)); // keep tooltip inside small screens
    const tipH = 120; // approximate max tooltip height
    const pad = 12;

    setPos({
      top: rect.top > tipH + pad, // enough room above?
      left: rect.right + tipW + pad > window.innerWidth, // would overflow right?
    });
  }, []);

  useEffect(() => {
    if (visible) recalc();
  }, [visible, recalc]);

  const show = () => { setVisible(true); };
  const hide = () => { setVisible(false); };

  return (
    <span className={`inline-flex items-center relative ${className}`}>
      <button
        ref={btnRef}
        type="button"
        aria-label="More information"
        onMouseEnter={show}
        onMouseLeave={hide}
        onFocus={show}     // Keyboard users can tab to this button
        onBlur={hide}      // Hide when focus leaves
        className="p-0.5 rounded-full text-[#1E293B]/30 hover:text-[#8B5CF6] focus:text-[#8B5CF6] focus:outline-none focus-visible:ring-2 focus-visible:ring-[#8B5CF6]/40 transition-colors cursor-help"
      >
        <Info style={{ width: size, height: size }} strokeWidth={2.5} />
      </button>

      {visible && (
        <div
          ref={tipRef}
          role="tooltip"
          className={`
            info-tooltip-bubble
            absolute z-[200] w-[calc(100vw-1.5rem)] max-w-[240px] md:w-[280px] md:max-w-none
            bg-[#1E293B] text-white text-[11px] font-bold leading-relaxed tracking-wide
            rounded-xl p-4
            border-2 border-[#8B5CF6]
            shadow-[4px_4px_0_0_#8B5CF6]
            pointer-events-none select-none
            ${pos.top ? 'bottom-full mb-2' : 'top-full mt-2'}
            ${pos.left ? 'right-0' : 'left-0'}
          `}
        >
          {text}
          {/* Arrow nub pointing to the button */}
          <div
            className={`
              absolute w-3 h-3 bg-[#1E293B] border-[#8B5CF6] rotate-45
              ${pos.top
                ? 'bottom-[-7px] border-r-2 border-b-2'
                : 'top-[-7px] border-l-2 border-t-2'}
              ${pos.left ? 'right-4' : 'left-4'}
            `}
          />
        </div>
      )}

      <style>{`
        .info-tooltip-bubble {
          animation: tooltipIn 0.15s ease-out forwards;
        }
        @keyframes tooltipIn {
          from { opacity: 0; transform: scale(0.95) translateY(${pos?.top ? '4px' : '-4px'}); }
          to   { opacity: 1; transform: scale(1) translateY(0); }
        }
        @media (prefers-reduced-motion: reduce) {
          .info-tooltip-bubble {
            animation: none !important;
            opacity: 1;
          }
        }
      `}</style>
    </span>
  );
}
