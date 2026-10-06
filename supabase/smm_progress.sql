-- Small Moments Method: cloud progress storage
-- Run this once in the Supabase SQL Editor for the project used by the app.

create table if not exists public.smm_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  language text not null default 'en',
  current_day integer not null default 1,
  done jsonb not null default '{}'::jsonb,
  notes jsonb not null default '{}'::jsonb,
  moods jsonb not null default '{}'::jsonb,
  final_notes text not null default '',
  updated_at timestamptz not null default now()
);

alter table public.smm_progress enable row level security;

revoke all on table public.smm_progress from anon;
grant select, insert, update, delete on table public.smm_progress to authenticated;

drop policy if exists "Users can read their own Small Moments progress" on public.smm_progress;
create policy "Users can read their own Small Moments progress"
on public.smm_progress for select
to authenticated
using ((select auth.uid()) = user_id);

drop policy if exists "Users can create their own Small Moments progress" on public.smm_progress;
create policy "Users can create their own Small Moments progress"
on public.smm_progress for insert
to authenticated
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can update their own Small Moments progress" on public.smm_progress;
create policy "Users can update their own Small Moments progress"
on public.smm_progress for update
to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

drop policy if exists "Users can delete their own Small Moments progress" on public.smm_progress;
create policy "Users can delete their own Small Moments progress"
on public.smm_progress for delete
to authenticated
using ((select auth.uid()) = user_id);

create index if not exists smm_progress_user_id_idx on public.smm_progress(user_id);


-- Anonymous tester feedback collected after Day 7.
-- Feedback is write-only from the public app; review it in the Supabase dashboard.
create table if not exists public.smm_feedback (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  language text not null default 'en',
  days_completed text not null,
  helpful_step text not null,
  helpful_explanation text not null default '',
  least_helpful_step text not null,
  least_helpful_explanation text not null default '',
  issue text not null default '',
  continue_choice text not null,
  price text not null default '',
  missing text not null default '',
  email text null,
  quote_permission text not null
);

alter table public.smm_feedback enable row level security;

revoke all on table public.smm_feedback from anon, authenticated;
grant insert on table public.smm_feedback to anon, authenticated;

drop policy if exists "Public can submit Small Moments feedback" on public.smm_feedback;
create policy "Public can submit Small Moments feedback"
on public.smm_feedback
for insert
to anon, authenticated
with check (true);


-- Add explanation fields to an existing feedback table.
alter table public.smm_feedback
  add column if not exists helpful_explanation text not null default '',
  add column if not exists least_helpful_explanation text not null default '';
