-- ============================================================
-- NPS Pulse — Supabase Database Setup (RECOVERY VERSION)
-- Run this in the Supabase SQL Editor (Dashboard → SQL Editor)
-- ============================================================

-- Drop existing tables if they exist to start fresh
drop table if exists public.lifestyle_goals;
drop table if exists public.nps_data;
drop table if exists public.profiles;

-- 1. PROFILES TABLE
create table if not exists public.profiles (
  id uuid references auth.users(id) on delete cascade primary key,
  name text not null,
  age integer not null,
  gender text default 'male',
  sector text,
  employer_name text,
  monthly_salary numeric default 0,
  target_retirement_age integer default 60,
  tax_regime text default '', -- Removed strict check for onboarding
  created_at timestamptz default now()
);

-- 2. NPS DATA TABLE
create table if not exists public.nps_data (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null unique,
  current_corpus numeric not null default 0,
  monthly_employee_contribution numeric not null default 0,
  monthly_employer_contribution numeric not null default 0,
  fund_choice text default 'auto',
  last_updated timestamptz default now()
);

-- 3. LIFESTYLE GOALS TABLE
create table if not exists public.lifestyle_goals (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  category text not null, -- Removed strict check for flexibility
  monthly_amount_today numeric not null default 0,
  unique (user_id, category)
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================================

alter table public.profiles enable row level security;
alter table public.nps_data enable row level security;
alter table public.lifestyle_goals enable row level security;

-- Profiles Policies
create policy "Public can insert profiles" on public.profiles for insert with check (auth.uid() = id);
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id);
create policy "Users can update own profile" on public.profiles for update using (auth.uid() = id);

-- NPS Data Policies
create policy "Users can insert own nps_data" on public.nps_data for insert with check (auth.uid() = user_id);
create policy "Users can view own nps_data" on public.nps_data for select using (auth.uid() = user_id);
create policy "Users can update own nps_data" on public.nps_data for update using (auth.uid() = user_id);

-- Lifestyle Goals Policies
create policy "Users can insert own lifestyle_goals" on public.lifestyle_goals for insert with check (auth.uid() = user_id);
create policy "Users can view own lifestyle_goals" on public.lifestyle_goals for select using (auth.uid() = user_id);
create policy "Users can update own lifestyle_goals" on public.lifestyle_goals for update using (auth.uid() = user_id);
create policy "Users can delete own lifestyle_goals" on public.lifestyle_goals for delete using (auth.uid() = user_id);
