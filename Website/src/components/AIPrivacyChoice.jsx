// ============================================
// AI Privacy Choice Modal
// ============================================
// Allows users to decide how much financial data to share with Groq AI.
//
// TWO OPTIONS:
// 1. PRIVACY MODE (Recommended)
//    - AI sees: Score, projections, lifestyle (NOT income/corpus)
//    - Data stays in India, not sent to Groq
//    - Slightly less specific advice
//
// 2. FULL MODE
//    - AI sees: Everything (income, corpus, all numbers)
//    - Data sent to Groq (USA) for detailed analysis
//    - Most specific, personalized advice
//    - Groq does NOT store or use for training
//
// USAGE: Show this modal on first AI chat, store choice in user profile
// The choice determines which fields get sent in subsequent AI requests (see encryption.js)

import React, { useState } from 'react';
import { Lock, Zap, Info, Sparkles, Check, X, ArrowDown } from 'lucide-react';

export default function AIPrivacyChoice({ onSelect, firstName }) {
  const [hoveredOption, setHoveredOption] = useState(null);

  const privacyModeData = {
    groqSees: [
      'Retirement score (e.g. 20/100 — Critical)',
      'Monthly gap to close (e.g. Rs18K/month)',
      'Projected vs required corpus',
      'Years to retire & retirement age',
      'Lifestyle goal (Essential/Comfortable/Premium)',
      'Tax regime (Old/New)',
      'Sector (Private/Govt/Self-Employed)',
      'Equity allocation %',
    ],
    groqNeverSees: [
      'Your actual monthly income',
      'Your exact NPS corpus amount',
      'Your monthly contribution amount',
      'Your other savings amount',
    ],
    pros: [
      'Your raw financial figures never leave India',
      'Groq cannot associate income with your identity',
      'Full DPDP Act 2023 compliant — no cross-border sensitive data',
      'AI still answers 90% of questions accurately',
    ],
    cons: [
      'AI says "increase by Rs18K" not "increase from Rs3K to Rs21K"',
      'Slightly less specific contribution advice',
    ],
  };

  const fullModeData = {
    groqSees: [
      'Everything in Privacy Mode, PLUS:',
      'Your exact monthly income',
      'Your NPS corpus and contribution amounts',
      'Your other savings amount',
      'All computed projections with exact figures',
    ],
    pros: [
      'Most specific advice possible — exact rupee amounts',
      'AI can say "increase your Rs3,000 to Rs21,000"',
      'Better job change and tax advice with real numbers',
      'Groq does NOT store or train on your data',
      'Groq is SOC 2 Type II and GDPR compliant',
    ],
    cons: [
      'Your financial figures are sent to Groq servers (USA)',
      'Requires trust in Groq privacy policy',
      'Cross-border data transfer under DPDP Act 2023',
    ],
  };

  return (
    <div
      style={{
        minHeight: '100%',
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        padding: '24px 12px calc(24px + env(safe-area-inset-bottom))',
        background: '#FFFDF5',
      }}
    >
      <div
        style={{
          position: 'fixed',
          inset: 0,
          pointerEvents: 'none',
          backgroundImage: 'radial-gradient(#1E293B 1px, transparent 1px)',
          backgroundSize: '28px 28px',
          opacity: 0.04,
        }}
        aria-hidden="true"
      />

      <div style={{ maxWidth: 980, width: '100%', position: 'relative' }}>
        <div style={{ textAlign: 'center', marginBottom: 32 }}>
          <div
            style={{
              width: 72,
              height: 72,
              borderRadius: '50%',
              background: '#8B5CF6',
              border: '2px solid #1E293B',
              boxShadow: '4px 4px 0 #1E293B',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              margin: '0 auto 16px',
            }}
          >
            <Lock size={30} color="white" strokeWidth={2.5} />
          </div>
          <h1
            style={{
              fontFamily: 'Outfit',
              fontWeight: 800,
              fontSize: 'clamp(1.5rem, 4vw, 2rem)',
              color: '#1E293B',
              marginBottom: 8,
              lineHeight: 1.2,
            }}
          >
            Your data. Your choice.
          </h1>
          <p
            style={{
              fontFamily: 'Plus Jakarta Sans',
              color: '#64748B',
              fontSize: '1rem',
              lineHeight: 1.6,
              maxWidth: 620,
              margin: '0 auto',
            }}
          >
            Hey {firstName}! Before RetireSahi AI answers your questions, choose how much it knows about you.
            Groq (our AI provider) is US-based — here is exactly what each option means.
          </p>
        </div>

        <div
          style={{
            display: 'grid',
            gridTemplateColumns: 'repeat(auto-fit, minmax(min(300px, 100%), 1fr))',
            gap: 16,
            marginBottom: 24,
          }}
        >
          <div
            onClick={() => onSelect('privacy')}
            onMouseEnter={() => setHoveredOption('privacy')}
            onMouseLeave={() => setHoveredOption(null)}
            style={{
              background: 'white',
              border: `2px solid ${hoveredOption === 'privacy' ? '#8B5CF6' : '#1E293B'}`,
              borderRadius: 16,
              padding: 20,
              cursor: 'pointer',
              boxShadow: hoveredOption === 'privacy' ? '6px 6px 0 #8B5CF6' : '4px 4px 0 #1E293B',
              transform: hoveredOption === 'privacy' ? 'translateY(-2px)' : 'none',
              transition: 'all 300ms cubic-bezier(0.34, 1.56, 0.64, 1)',
            }}
          >
            <div
              style={{
                background: '#34D399',
                border: '1px solid #1E293B',
                borderRadius: 9999,
                padding: '2px 10px',
                fontSize: '0.6rem',
                fontWeight: 800,
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
                marginBottom: 10,
                boxShadow: '2px 2px 0 #1E293B',
                display: 'inline-flex',
                alignItems: 'center',
                gap: 4,
              }}
            >
              <Sparkles size={12} strokeWidth={2.5} /> Recommended
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
              <Lock size={20} color="#8B5CF6" strokeWidth={2.5} />
              <span style={{ fontFamily: 'Outfit', fontWeight: 800, fontSize: '1.1rem', color: '#1E293B' }}>
                Privacy Mode
              </span>
            </div>

            <p
              style={{
                fontSize: '0.8rem',
                color: '#64748B',
                fontFamily: 'Plus Jakarta Sans',
                lineHeight: 1.5,
                marginBottom: 12,
              }}
            >
              AI uses only your retirement score and projections. Your income and corpus stay on your device.
            </p>

            <div
              style={{
                background: '#F0FDF4',
                borderRadius: 8,
                padding: '10px 12px',
                marginBottom: 8,
                border: '1px solid #BBF7D0',
              }}
            >
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#16A34A',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 6,
                }}
              >
                Groq sees:
              </p>
              {privacyModeData.groqSees.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.75rem',
                    color: '#475569',
                    fontFamily: 'Plus Jakarta Sans',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 3,
                    alignItems: 'flex-start',
                  }}
                >
                  <Check size={14} color="#34D399" strokeWidth={3} style={{ flexShrink: 0, marginTop: 2 }} />
                  {item}
                </div>
              ))}
            </div>

            <div
              style={{
                background: '#FFF7ED',
                borderRadius: 8,
                padding: '10px 12px',
                marginBottom: 12,
                border: '1px solid #FED7AA',
              }}
            >
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#EA580C',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 6,
                }}
              >
                Groq never sees:
              </p>
              {privacyModeData.groqNeverSees.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.75rem',
                    color: '#475569',
                    fontFamily: 'Plus Jakarta Sans',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 3,
                    alignItems: 'flex-start',
                  }}
                >
                  <X size={14} color="#EF4444" strokeWidth={3} style={{ flexShrink: 0, marginTop: 2 }} />
                  {item}
                </div>
              ))}
            </div>

            <div style={{ marginBottom: 8 }}>
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#64748B',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 4,
                }}
              >
                Advantages:
              </p>
              {privacyModeData.pros.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.72rem',
                    color: '#475569',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 2,
                    alignItems: 'flex-start',
                  }}
                >
                  <span style={{ color: '#34D399', flexShrink: 0 }}>+</span>
                  {item}
                </div>
              ))}
            </div>

            <div style={{ marginBottom: 16 }}>
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#64748B',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 4,
                }}
              >
                Trade-offs:
              </p>
              {privacyModeData.cons.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.72rem',
                    color: '#94A3B8',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 2,
                    alignItems: 'flex-start',
                  }}
                >
                  <span style={{ flexShrink: 0 }}>—</span>
                  {item}
                </div>
              ))}
            </div>

            <button
              style={{
                width: '100%',
                height: 44,
                background: '#8B5CF6',
                color: 'white',
                border: '2px solid #1E293B',
                borderRadius: 9999,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: 800,
                fontSize: '0.8rem',
                textTransform: 'uppercase',
                letterSpacing: '0.06em',
                cursor: 'pointer',
                boxShadow: '3px 3px 0 #1E293B',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 6,
              }}
            >
              <Lock size={14} /> Choose Privacy Mode
            </button>
          </div>

          <div
            onClick={() => onSelect('full')}
            onMouseEnter={() => setHoveredOption('full')}
            onMouseLeave={() => setHoveredOption(null)}
            style={{
              background: 'white',
              border: `2px solid ${hoveredOption === 'full' ? '#F472B6' : '#1E293B'}`,
              borderRadius: 16,
              padding: 20,
              cursor: 'pointer',
              boxShadow: hoveredOption === 'full' ? '6px 6px 0 #F472B6' : '4px 4px 0 #1E293B',
              transform: hoveredOption === 'full' ? 'translateY(-2px)' : 'none',
              transition: 'all 300ms cubic-bezier(0.34, 1.56, 0.64, 1)',
            }}
          >
            <div
              style={{
                background: '#FBBF24',
                border: '1px solid #1E293B',
                borderRadius: 9999,
                padding: '2px 10px',
                fontSize: '0.6rem',
                fontWeight: 800,
                textTransform: 'uppercase',
                letterSpacing: '0.08em',
                marginBottom: 10,
                boxShadow: '2px 2px 0 #1E293B',
                display: 'inline-flex',
                alignItems: 'center',
                gap: 4,
              }}
            >
              <Zap size={12} strokeWidth={2.5} /> Most Personalized
            </div>

            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 12 }}>
              <Zap size={20} color="#F472B6" strokeWidth={2.5} />
              <span style={{ fontFamily: 'Outfit', fontWeight: 800, fontSize: '1.1rem', color: '#1E293B' }}>
                Full Mode
              </span>
            </div>

            <p
              style={{
                fontSize: '0.8rem',
                color: '#64748B',
                fontFamily: 'Plus Jakarta Sans',
                lineHeight: 1.5,
                marginBottom: 12,
              }}
            >
              AI uses your complete financial profile for the most specific, actionable advice possible.
            </p>

            <div
              style={{
                background: '#FFF7ED',
                borderRadius: 8,
                padding: '10px 12px',
                marginBottom: 12,
                border: '1px solid #FED7AA',
              }}
            >
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#EA580C',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 6,
                }}
              >
                Groq sees:
              </p>
              {fullModeData.groqSees.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.75rem',
                    color: '#475569',
                    fontFamily: 'Plus Jakarta Sans',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 3,
                    alignItems: 'flex-start',
                  }}
                >
                  {i === 0 ? (
                    <ArrowDown size={14} color="#8B5CF6" strokeWidth={3} style={{ flexShrink: 0, marginTop: 2 }} />
                  ) : (
                    <Check size={14} color="#FBBF24" strokeWidth={3} style={{ flexShrink: 0, marginTop: 2 }} />
                  )}
                  {item}
                </div>
              ))}
            </div>

            <div style={{ marginBottom: 8 }}>
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#64748B',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 4,
                }}
              >
                Advantages:
              </p>
              {fullModeData.pros.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.72rem',
                    color: '#475569',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 2,
                    alignItems: 'flex-start',
                  }}
                >
                  <span style={{ color: '#34D399', flexShrink: 0 }}>+</span>
                  {item}
                </div>
              ))}
            </div>

            <div style={{ marginBottom: 16 }}>
              <p
                style={{
                  fontSize: '0.65rem',
                  fontWeight: 700,
                  color: '#64748B',
                  textTransform: 'uppercase',
                  letterSpacing: '0.06em',
                  marginBottom: 4,
                }}
              >
                Trade-offs:
              </p>
              {fullModeData.cons.map((item, i) => (
                <div
                  key={i}
                  style={{
                    fontSize: '0.72rem',
                    color: '#94A3B8',
                    display: 'flex',
                    gap: 6,
                    marginBottom: 2,
                    alignItems: 'flex-start',
                  }}
                >
                  <span style={{ flexShrink: 0 }}>—</span>
                  {item}
                </div>
              ))}
            </div>

            <button
              style={{
                width: '100%',
                height: 44,
                background: '#F472B6',
                color: 'white',
                border: '2px solid #1E293B',
                borderRadius: 9999,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: 800,
                fontSize: '0.8rem',
                textTransform: 'uppercase',
                letterSpacing: '0.06em',
                cursor: 'pointer',
                boxShadow: '3px 3px 0 #1E293B',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                gap: 6,
              }}
            >
              <Zap size={14} /> Choose Full Mode
            </button>
          </div>
        </div>

        <div
          style={{
            background: '#F1F5F9',
            border: '2px solid #1E293B',
            borderRadius: 12,
            padding: '12px 16px',
            display: 'flex',
            gap: 10,
            alignItems: 'flex-start',
            boxShadow: '2px 2px 0 #1E293B',
          }}
        >
          <Info size={16} color="#64748B" strokeWidth={2.5} style={{ flexShrink: 0, marginTop: 1 }} />
          <p
            style={{
              fontSize: '0.78rem',
              color: '#64748B',
              fontFamily: 'Plus Jakarta Sans',
              lineHeight: 1.5,
              margin: 0,
            }}
          >
            <strong style={{ color: '#1E293B' }}>RetireSahi never sees your plaintext data.</strong>{' '}
            Your financial information is encrypted on your device before storage. Neither our team nor Firebase administrators
            can read your income, corpus, or savings — only you can. You can change this choice anytime in Settings → AI Preferences.{' '}
            <a href="/privacy" style={{ color: '#8B5CF6', fontWeight: 700 }} onClick={(e) => e.stopPropagation()}>
              Read our Privacy Policy →
            </a>
          </p>
        </div>
      </div>
    </div>
  );
}
