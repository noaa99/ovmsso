-- OVMS practice apps: progress tracking schema.
-- Paste this whole file into the Supabase SQL editor and run it once.

-- ---------------------------------------------------------------- roster
-- Who is allowed to sign up. Nobody outside this table can create an account,
-- so the practice pages can stay public without strangers filling the tables.
create table public.roster (
  email        text primary key,
  display_name text not null,
  added_at     timestamptz not null default now()
);
alter table public.roster enable row level security;
-- No policies on purpose: only the SQL editor (service role) can read or write it.

-- -------------------------------------------------------------- profiles
create table public.profiles (
  id           uuid primary key references auth.users on delete cascade,
  display_name text not null,
  is_coach     boolean not null default false,
  created_at   timestamptz not null default now()
);
alter table public.profiles enable row level security;

-- -------------------------------------------------------------- attempts
-- One row per answered question. No update or delete policy exists, so a
-- student cannot erase or rewrite a wrong answer after the fact.
create table public.attempts (
  id          bigint generated always as identity primary key,
  user_id     uuid not null default auth.uid() references auth.users on delete cascade,
  event       text not null check (event in ('circuit-lab','water-quality')),
  question_id text not null,
  topic       text not null,
  diff        smallint,
  qtype       text,
  correct     boolean not null,
  given       text,
  seconds     integer,
  created_at  timestamptz not null default now()
);
create index attempts_user_time_idx on public.attempts (user_id, created_at desc);
create index attempts_question_idx   on public.attempts (event, question_id);
alter table public.attempts enable row level security;

-- ------------------------------------------------------------ coach check
-- security definer so the policies below can read profiles without
-- re-entering row level security and recursing.
create or replace function public.is_coach()
returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select is_coach from public.profiles where id = auth.uid()), false);
$$;

-- ---------------------------------------------------------------- policies
create policy "insert own attempts" on public.attempts
  for insert to authenticated with check (user_id = auth.uid());

create policy "read own attempts, coach reads all" on public.attempts
  for select to authenticated using (user_id = auth.uid() or public.is_coach());

create policy "read own profile, coach reads all" on public.profiles
  for select to authenticated using (id = auth.uid() or public.is_coach());

create policy "update own profile" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());

-- ------------------------------------------------------- signup gatekeeper
-- Rejects any signup whose email is not on the roster, and copies the
-- roster's display name into the new profile.
create or replace function public.handle_new_user()
returns trigger
language plpgsql security definer set search_path = public as $$
declare r public.roster%rowtype;
begin
  select * into r from public.roster where lower(email) = lower(new.email);
  if not found then
    raise exception 'This email is not on the team roster. Ask your coach to add it.';
  end if;
  insert into public.profiles (id, display_name) values (new.id, r.display_name);
  return new;
end; $$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- --------------------------------------------------------- coach dashboard
-- A per-student rollup the coach page reads. It inherits the attempts
-- policies, so a student sees only their own row.
create view public.student_progress
with (security_invoker = true) as
select
  p.id,
  p.display_name,
  a.event,
  count(*)                                              as answered,
  count(*) filter (where a.correct)                     as correct,
  round(100.0 * count(*) filter (where a.correct) / nullif(count(*),0)) as pct,
  max(a.created_at)                                     as last_seen
from public.profiles p
join public.attempts a on a.user_id = p.id
group by p.id, p.display_name, a.event;
