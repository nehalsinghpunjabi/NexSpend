-- Day 2: authenticated users' expense records.
create table if not exists public.expenses (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  amount numeric(14, 2) not null check (amount > 0),
  merchant text not null check (char_length(trim(merchant)) > 0),
  category text not null,
  payment_method text not null,
  expense_date timestamptz not null,
  notes text,
  currency text not null default 'INR' check (char_length(currency) = 3),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists expenses_user_date_idx
on public.expenses (user_id, expense_date desc);

alter table public.expenses enable row level security;

create policy "Users can read their own expenses"
on public.expenses for select using (auth.uid() = user_id);

create policy "Users can insert their own expenses"
on public.expenses for insert with check (auth.uid() = user_id);

create policy "Users can update their own expenses"
on public.expenses for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

create policy "Users can delete their own expenses"
on public.expenses for delete using (auth.uid() = user_id);

create or replace function public.set_expenses_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists expenses_set_updated_at on public.expenses;
create trigger expenses_set_updated_at
before update on public.expenses
for each row execute procedure public.set_expenses_updated_at();
