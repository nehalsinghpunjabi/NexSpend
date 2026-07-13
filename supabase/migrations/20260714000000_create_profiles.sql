-- Day 1 authenticated-user profile foundation.
-- Safe to apply to a project where Auth users already exist.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  persona text check (persona in ('Student', 'Salaried', 'Self-employed', 'Retired')),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Users can read their own profile" on public.profiles;
create policy "Users can read their own profile"
on public.profiles for select using (auth.uid() = id);

drop policy if exists "Users can create their own profile" on public.profiles;
create policy "Users can create their own profile"
on public.profiles for insert with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
on public.profiles for update using (auth.uid() = id) with check (auth.uid() = id);

create or replace function public.create_profile_for_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id) values (new.id)
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute procedure public.create_profile_for_new_user();

-- Backfill profiles for users authenticated before this migration.
insert into public.profiles (id)
select id from auth.users
on conflict (id) do nothing;
