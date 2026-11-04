-- SALVATION STORE INVENTORY — Supabase database setup
-- Run this entire file in Supabase Dashboard > SQL Editor > New query > Run.
-- This is intentionally a no-login/public-link setup. Anyone with the site link
-- can modify stock. Never put the service_role key in website code.

create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) > 0),
  price numeric(12,2) not null default 0 check (price >= 0),
  unit text not null check (length(trim(unit)) > 0),
  quantity integer not null default 0 check (quantity >= 0),
  low_stock_threshold integer not null default 5 check (low_stock_threshold >= 0),
  created_at timestamptz not null default now()
);

create unique index if not exists products_name_unique
on public.products (lower(name));

create table if not exists public.transactions (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  type text not null check (type in ('sale','restock')),
  quantity integer not null check (quantity > 0),
  note text,
  created_at timestamptz not null default now()
);

create index if not exists transactions_created_at_idx on public.transactions(created_at desc);
create index if not exists transactions_product_id_idx on public.transactions(product_id);

alter table public.products enable row level security;
alter table public.transactions enable row level security;

-- Public access: required because you requested no login.
drop policy if exists "Public can read products" on public.products;
create policy "Public can read products" on public.products for select to anon, authenticated using (true);
drop policy if exists "Public can add products" on public.products;
create policy "Public can add products" on public.products for insert to anon, authenticated with check (true);
drop policy if exists "Public can edit products" on public.products;
create policy "Public can edit products" on public.products for update to anon, authenticated using (true) with check (true);
drop policy if exists "Public can read transactions" on public.transactions;
create policy "Public can read transactions" on public.transactions for select to anon, authenticated using (true);

-- Sales and restocks run as one database transaction, so simultaneous users
-- cannot sell the same last units and cause stock to go negative.
create or replace function public.record_sale(p_product_id uuid, p_quantity integer, p_note text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  current_product public.products%rowtype;
begin
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero.';
  end if;

  select * into current_product
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception 'Product not found.';
  end if;

  if current_product.quantity < p_quantity then
    raise exception 'Not enough stock. Current stock is % %.',
      current_product.quantity, current_product.unit;
  end if;

  update public.products
  set quantity = quantity - p_quantity
  where id = p_product_id;

  insert into public.transactions(product_id, type, quantity, note)
  values (p_product_id, 'sale', p_quantity, nullif(trim(p_note), ''));

  return jsonb_build_object('success', true, 'remaining', current_product.quantity - p_quantity);
end;
$$;

create or replace function public.record_restock(p_product_id uuid, p_quantity integer, p_note text default null)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  current_product public.products%rowtype;
begin
  if p_quantity is null or p_quantity <= 0 then
    raise exception 'Quantity must be greater than zero.';
  end if;

  select * into current_product
  from public.products
  where id = p_product_id
  for update;

  if not found then
    raise exception 'Product not found.';
  end if;

  update public.products
  set quantity = quantity + p_quantity
  where id = p_product_id;

  insert into public.transactions(product_id, type, quantity, note)
  values (p_product_id, 'restock', p_quantity, nullif(trim(p_note), ''));

  return jsonb_build_object('success', true, 'new_quantity', current_product.quantity + p_quantity);
end;
$$;

revoke all on function public.record_sale(uuid, integer, text) from public;
revoke all on function public.record_restock(uuid, integer, text) from public;
grant execute on function public.record_sale(uuid, integer, text) to anon, authenticated;
grant execute on function public.record_restock(uuid, integer, text) to anon, authenticated;

grant select, insert, update on public.products to anon, authenticated;
grant select on public.transactions to anon, authenticated;

-- Enable Supabase Realtime for both tables. Safe to run if already added.
do $$
begin
  alter publication supabase_realtime add table public.products;
exception when duplicate_object then null;
end $$;
do $$
begin
  alter publication supabase_realtime add table public.transactions;
exception when duplicate_object then null;
end $$;
