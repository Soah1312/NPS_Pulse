# NPS Pulse

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=flat&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat&logo=supabase&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?style=flat)

> **Your retirement, simplified.** A premium NPS planning app built for every Indian professional who will, someday, retire.

---

## Overview

Most Indians treat retirement planning like a math problem — staring at abstract numbers like "₹5 Crores" with no idea if that's enough or how to get there. NPS Pulse is built to fix that.

We bridge what behavioral economists call the **Future-Self Gap** — the disconnect between who you are today and who you'll be at 60. Instead of asking you to think in crores, NPS Pulse asks you a simpler question: *what does your retirement actually look like?* Do you want to travel internationally twice a year? Live in a comfortable home with premium healthcare? Never worry about medical bills? You pick the life. We calculate the number.

Built specifically for Indian NPS (National Pension System) subscribers — government employees, private sector workers, and self-employed individuals alike — NPS Pulse combines a Retirement Readiness Score, tax optimization tools, and an AI-powered pension co-pilot into one clean, modern app. It's not a calculator. It's a decision support system for the most important financial journey of your life.

---

## Screenshots

<!-- Screenshots coming soon -->
> Add screenshots to the `/screenshots` folder

---

## Features

| Feature | Status |
|---|---|
| Email / Password Authentication | ✅ Built |
| 6-step Conversational Onboarding | ✅ Built |
| Lifestyle Tier Selection (Essential / Comfortable / Lavish) | ✅ Built |
| Customizable Lifestyle Plan (per line item editing) | ✅ Built |
| Retirement Readiness Score (0–100) with animated arc gauge | ✅ Built |
| Projected vs Required Corpus Calculation | ✅ Built |
| Inflation-adjusted Retirement Need | ✅ Built |
| Dashboard with Dream Lifestyle Summary | ✅ Built |
| "Where You Stand Today" Progress Section | ✅ Built |
| Tax Shield Banner & Regime Setup | ✅ Built |
| Tax Shield Diagnostic (80CCD optimization) | 📋 Planned |
| RAG-Powered AI Pension Co-Pilot (Gemini) | 📋 Planned |
| Monte Carlo Stress Tester | 📋 Planned |
| Dream Planner Editor Screen | 📋 Planned |
| Profile Editing & Data Updates | 📋 Planned |
| Google OAuth Sign-In | 📋 Planned |
| FastAPI Backend Integration | 📋 Planned |
| Social Benchmarking (Sector Rankings) | 📋 Planned |

---

## Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Frontend | Flutter (Dart) | Cross-platform mobile app (Android + iOS) |
| State Management | Riverpod | Reactive state across the app |
| Navigation | GoRouter | Declarative routing with auth guards |
| Backend / Database | Supabase (PostgreSQL) | Auth, data persistence, Row Level Security |
| Vector Search | Supabase pgvector | RAG embeddings for AI assistant (planned) |
| AI / LLM | Gemini 1.5 Pro API | RAG-powered pension co-pilot (planned) |
| Backend API | FastAPI (Python) | Calculation engine + RAG pipeline (planned) |
| Local Storage | shared_preferences | Session persistence |

---

## Getting Started

### Prerequisites

- Flutter 3.x ([Install Flutter](https://flutter.dev/docs/get-started/install))
- Dart 3.x (bundled with Flutter)
- Android Studio or VS Code with Flutter extension
- A [Supabase](https://supabase.com) account (free tier is sufficient)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/nps_pulse.git
   cd nps_pulse
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**

   Create a `.env` file in the project root:
   ```
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   GEMINI_API_KEY=your_gemini_api_key
   API_BASE_URL=http://localhost:8000
   ```

   > Never commit your `.env` file. It is already in `.gitignore`.

4. **Set up Supabase database**

   Run the following SQL in your Supabase SQL Editor:

   ```sql
   -- Profiles table
   create table profiles (
     id uuid references auth.users on delete cascade primary key,
     first_name text,
     last_name text,
     age integer,
     gender text,
     sector text,
     employer_name text,
     monthly_salary numeric,
     target_retirement_age integer,
     tax_regime text default '',
     created_at timestamp with time zone default now()
   );

   -- NPS Data table
   create table nps_data (
     id uuid default gen_random_uuid() primary key,
     user_id uuid references auth.users on delete cascade,
     current_corpus numeric default 0,
     monthly_employee_contribution numeric default 0,
     monthly_employer_contribution numeric default 0,
     fund_choice text default 'auto',
     equity_allocation numeric,
     last_updated timestamp with time zone default now()
   );

   -- Lifestyle goals table
   create table lifestyle_goals (
     id uuid default gen_random_uuid() primary key,
     user_id uuid references auth.users on delete cascade,
     tier_name text,
     monthly_amount numeric,
     line_items jsonb,
     created_at timestamp with time zone default now()
   );

   -- Enable Row Level Security
   alter table profiles enable row level security;
   alter table nps_data enable row level security;
   alter table lifestyle_goals enable row level security;

   -- RLS Policies
   create policy "Users can manage own profile"
     on profiles for all using (auth.uid() = id);

   create policy "Users can manage own nps data"
     on nps_data for all using (auth.uid() = user_id);

   create policy "Users can manage own lifestyle goals"
     on lifestyle_goals for all using (auth.uid() = user_id);
   ```

5. **Generate code (Freezed + Riverpod)**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

6. **Run the app**
   ```bash
   # On Chrome (development)
   flutter run -d chrome --web-port 3000

   # On connected Android device
   flutter run

   # On Android emulator
   flutter emulators --launch <emulator_id>
   flutter run
   ```

---

## Environment Variables

| Variable | Description | Required |
|---|---|---|
| `SUPABASE_URL` | Your Supabase project URL | ✅ |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous key | ✅ |
| `GEMINI_API_KEY` | Gemini API key for AI assistant | 📋 Planned |
| `API_BASE_URL` | FastAPI backend base URL | 📋 Planned |

---

## Project Structure

```
lib/
├── main.dart                      # App entry point
├── app.dart                       # Root widget, router init
├── core/
│   ├── theme/                     # Design system (colors, typography, spacing)
│   ├── router/                    # GoRouter routes and auth guards
│   ├── network/                   # Dio HTTP client and API endpoints
│   ├── utils/                     # Currency formatter, validators, date utils
│   └── constants/                 # Tax slabs, NPS rules, inflation rates
├── features/
│   ├── auth/                      # Login and signup screens
│   ├── onboarding/                # 6-step conversational onboarding
│   ├── dashboard/                 # Main dashboard and readiness score
│   ├── dream_planner/             # Lifestyle goal selection and editing
│   ├── tax_shield/                # Tax diagnostic and optimization
│   ├── monte_carlo/               # Probabilistic retirement simulation
│   └── ai_assistant/              # RAG-powered pension chatbot
└── shared/
    ├── widgets/                   # Reusable UI components
    ├── models/                    # Data models (Freezed)
    └── providers/                 # Global Riverpod providers
```

---

## How the Readiness Score Works

The Readiness Score is a single 0–100 number that tells you how well-funded your retirement is projected to be. Here's how it's calculated in plain English:

1. **Project your future corpus** — We take your current NPS corpus and grow it at an assumed annual return (8.5%–10% depending on your sector and age). We then add the future value of your ongoing monthly contributions compounded over your remaining working years.

2. **Calculate what you actually need** — We take your chosen retirement lifestyle (e.g. Comfortable = ₹1,20,000/month today) and inflate it to what it will cost at your retirement age using a 6% annual inflation rate. We then multiply by 25 years of retirement life to get your required corpus.

3. **Divide and score** — We divide your projected corpus by your required corpus to get a ratio, then map it to a 0–100 score:

| Score | Label | Meaning |
|---|---|---|
| 86–100 | Excellent 🟢 | You're on track or ahead of target |
| 71–85 | Good 🟢 | Minor adjustments will get you there |
| 51–70 | On Track 🔵 | You're heading in the right direction |
| 31–50 | At Risk 🟠 | Significant gap — action needed soon |
| 0–30 | Critical 🔴 | Major gap — start optimizing now |

The score updates live as you adjust your contributions using the Power Slider on the dashboard.

---

## Roadmap

| Phase | Feature | Timeline |
|---|---|---|
| **Phase 1** — Core | Onboarding, Dashboard, Readiness Score, Auth | ✅ Current |
| **Phase 2** — Intelligence | Tax Shield Diagnostic, AI Co-Pilot, Dream Planner Editor | 🚧 Next |
| **Phase 3** — Advanced | Monte Carlo Simulator, FastAPI Backend, Profile Editing | 📋 Q2 2025 |
| **Phase 4** — Social | Google OAuth, Social Benchmarking, Sector Rankings | 📋 Q3 2025 |

---

## Contributing

Contributions are welcome. Here's how to get started:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Commit your changes: `git commit -m 'Add: your feature description'`
4. Push to the branch: `git push origin feature/your-feature-name`
5. Open a Pull Request

Please read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a PR.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## Acknowledgements

- [PFRDA](https://www.pfrda.org.in) for NPS guidelines and circulars that power the AI assistant's knowledge base
- [Supabase](https://supabase.com) for making backend infrastructure accessible to solo builders
- [Flutter](https://flutter.dev) team for the cross-platform framework
- [Google Gemini](https://deepmind.google/technologies/gemini/) for the AI backbone of the pension co-pilot

---

<p align="center">Built with ❤️ for every Indian professional planning their tomorrow</p>
