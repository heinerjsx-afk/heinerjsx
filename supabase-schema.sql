-- HNR Store: persistent product catalog with Supabase Auth + Row Level Security.
-- Run this file in Supabase SQL Editor. It does NOT insert the example "Gorra FR".
create extension if not exists pgcrypto;

create table if not exists public.hnr_admins (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);

create table if not exists public.hnr_products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(trim(name)) between 2 and 120),
  category text not null check (char_length(trim(category)) between 2 and 60),
  price_cop integer not null check (price_cop > 0),
  stock integer not null default 0 check (stock >= 0),
  description text not null default '' check (char_length(description) <= 500),
  tag text not null default 'NUEVO' check (char_length(tag) <= 40),
  kind text not null default 'cap' check (kind in ('sweater','tee','cap','cap2','shoe','perfume','bag','headphones','case','charger','powerbank','chain')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists hnr_products_active_idx on public.hnr_products(active);
alter table public.hnr_admins enable row level security;
alter table public.hnr_products enable row level security;

drop policy if exists "HNR admins can read own admin record" on public.hnr_admins;
create policy "HNR admins can read own admin record"
  on public.hnr_admins for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Public can read active HNR products" on public.hnr_products;
create policy "Public can read active HNR products"
  on public.hnr_products for select to anon, authenticated
  using (active = true);

drop policy if exists "HNR admins can read all products" on public.hnr_products;
create policy "HNR admins can read all products"
  on public.hnr_products for select to authenticated
  using (exists (select 1 from public.hnr_admins a where a.user_id = (select auth.uid())));

drop policy if exists "HNR admins can insert products" on public.hnr_products;
create policy "HNR admins can insert products"
  on public.hnr_products for insert to authenticated
  with check (exists (select 1 from public.hnr_admins a where a.user_id = (select auth.uid())));

drop policy if exists "HNR admins can update products" on public.hnr_products;
create policy "HNR admins can update products"
  on public.hnr_products for update to authenticated
  using (exists (select 1 from public.hnr_admins a where a.user_id = (select auth.uid())))
  with check (exists (select 1 from public.hnr_admins a where a.user_id = (select auth.uid())));

drop policy if exists "HNR admins can delete products" on public.hnr_products;
create policy "HNR admins can delete products"
  on public.hnr_products for delete to authenticated
  using (exists (select 1 from public.hnr_admins a where a.user_id = (select auth.uid())));

revoke all on public.hnr_admins from anon, authenticated;
grant select on public.hnr_admins to authenticated;
revoke all on public.hnr_products from anon, authenticated;
grant select on public.hnr_products to anon, authenticated;
grant insert, update, delete on public.hnr_products to authenticated;

-- After creating your account in Supabase Authentication > Users, add your own user ID:
-- insert into public.hnr_admins (user_id) values ('YOUR-AUTH-USER-UUID');
-- Do not add public signup or put a service/secret key in browser code.
