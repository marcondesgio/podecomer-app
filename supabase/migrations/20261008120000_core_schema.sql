-- Pode Comer? — esquema principal.
-- Dados de saúde (alergias, gravidade, vereditos) ficam só aqui, protegidos por RLS
-- (ver 20261008120100_rls.sql). Nunca replicá-los em logs ou analytics.

-- ---------------------------------------------------------------------------
-- Tipos
-- ---------------------------------------------------------------------------

create type public.sex_type as enum ('masculino', 'feminino', 'nao_informar');
create type public.plan_type as enum ('free', 'familia');
create type public.person_type as enum ('profile', 'member');
create type public.allergy_severity as enum ('leve', 'grave');
create type public.product_source as enum ('own', 'off');
create type public.product_status as enum ('verified', 'pending');
create type public.submission_status as enum ('pending', 'approved', 'rejected');
-- Mesma precedência do VerdictStatus (lib/core/engine/verdict_status.dart):
-- nao_consumir > atencao > inconclusivo > seguro.
create type public.verdict_status as enum ('seguro', 'inconclusivo', 'atencao', 'nao_consumir');

-- ---------------------------------------------------------------------------
-- Utilitários
-- ---------------------------------------------------------------------------

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- profiles: 1:1 com auth.users
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default '' check (char_length(name) <= 80),
  birth_date date check (birth_date between '1900-01-01' and current_date),
  sex public.sex_type,
  avatar_url text,
  -- Alterado só pelo backend (webhook do RevenueCat), nunca pelo app.
  plan public.plan_type not null default 'free',
  -- Consentimento LGPD para dados sensíveis de saúde.
  health_consent_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Cria o perfil quando a conta é criada no Supabase Auth.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, name)
  values (
    new.id,
    left(coalesce(new.raw_user_meta_data ->> 'name', new.raw_user_meta_data ->> 'full_name', ''), 80)
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- group_members: pessoas do grupo familiar do titular
-- ---------------------------------------------------------------------------

create table public.group_members (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  name text not null check (char_length(name) between 1 and 80),
  birth_date date check (birth_date between '1900-01-01' and current_date),
  sex public.sex_type,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index group_members_owner_id_idx on public.group_members (owner_id);

create trigger group_members_set_updated_at
  before update on public.group_members
  for each row execute function public.set_updated_at();

-- Plano free: no máximo 1 membro além do titular.
create function public.enforce_free_member_limit()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  owner_plan public.plan_type;
  member_count integer;
begin
  -- Trava o perfil para serializar inserções concorrentes do mesmo titular.
  select plan into owner_plan
  from public.profiles
  where id = new.owner_id
  for update;

  if owner_plan = 'free' then
    select count(*) into member_count
    from public.group_members
    where owner_id = new.owner_id;

    if member_count >= 1 then
      raise exception 'O plano gratuito permite apenas 1 membro no grupo.'
        using errcode = 'P0001', hint = 'free_member_limit';
    end if;
  end if;

  return new;
end;
$$;

create trigger group_members_free_limit
  before insert on public.group_members
  for each row execute function public.enforce_free_member_limit();

-- ---------------------------------------------------------------------------
-- allergens: catálogo fixo (códigos usados pelo motor e pelos produtos)
-- ---------------------------------------------------------------------------

create table public.allergens (
  code text primary key check (code ~ '^[a-z_]+$'),
  name_pt text not null
);

insert into public.allergens (code, name_pt) values
  ('amendoim', 'Amendoim'),
  ('leite_aplv', 'Leite (APLV)'),
  ('lactose', 'Lactose'),
  ('gluten', 'Glúten'),
  ('trigo', 'Trigo'),
  ('ovo', 'Ovo'),
  ('soja', 'Soja'),
  ('peixe', 'Peixe'),
  ('crustaceos', 'Crustáceos'),
  ('castanhas', 'Castanhas e nozes'),
  ('gergelim', 'Gergelim'),
  ('sulfitos', 'Sulfitos');

-- ---------------------------------------------------------------------------
-- person_allergens: alergias do titular (profile) ou de um membro (member)
-- ---------------------------------------------------------------------------

create table public.person_allergens (
  person_type public.person_type not null,
  person_id uuid not null,
  allergen_code text not null references public.allergens (code) on update cascade,
  severity public.allergy_severity not null default 'leve',
  created_at timestamptz not null default now(),
  primary key (person_type, person_id, allergen_code)
);

create index person_allergens_person_idx on public.person_allergens (person_id);

-- person_id é polimórfico (sem FK): valida a existência e limpa órfãos por trigger.
create function public.validate_person_allergen()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.person_type = 'profile' then
    if not exists (select 1 from public.profiles where id = new.person_id) then
      raise exception 'Perfil % não existe.', new.person_id using errcode = '23503';
    end if;
  else
    if not exists (select 1 from public.group_members where id = new.person_id) then
      raise exception 'Membro % não existe.', new.person_id using errcode = '23503';
    end if;
  end if;
  return new;
end;
$$;

create trigger person_allergens_validate
  before insert or update on public.person_allergens
  for each row execute function public.validate_person_allergen();

create function public.delete_person_allergens()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.person_allergens
  where person_id = old.id
    and person_type = case tg_table_name
      when 'profiles' then 'profile'::public.person_type
      else 'member'::public.person_type
    end;
  return old;
end;
$$;

create trigger profiles_delete_allergens
  after delete on public.profiles
  for each row execute function public.delete_person_allergens();

create trigger group_members_delete_allergens
  after delete on public.group_members
  for each row execute function public.delete_person_allergens();

-- ---------------------------------------------------------------------------
-- products: base própria (own) e cache do Open Food Facts (off)
-- ---------------------------------------------------------------------------

create table public.products (
  barcode text primary key check (barcode ~ '^[0-9]{8,14}$'),
  name text,
  brand text,
  category text,
  ingredients_text text,
  allergens_contains text[] not null default '{}',
  allergens_traces text[] not null default '{}',
  source public.product_source not null,
  status public.product_status not null default 'pending',
  image_urls text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index products_category_status_idx on public.products (category, status);

create trigger products_set_updated_at
  before update on public.products
  for each row execute function public.set_updated_at();

-- Arrays não aceitam FK: garante que só códigos do catálogo entram.
create function public.validate_product_allergens()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  unknown text;
begin
  select code into unknown
  from unnest(new.allergens_contains || new.allergens_traces) as code
  where code not in (select a.code from public.allergens a)
  limit 1;

  if unknown is not null then
    raise exception 'Alergênico desconhecido: %', unknown using errcode = '23503';
  end if;
  return new;
end;
$$;

create trigger products_validate_allergens
  before insert or update of allergens_contains, allergens_traces on public.products
  for each row execute function public.validate_product_allergens();

-- ---------------------------------------------------------------------------
-- product_submissions: cadastro colaborativo pela câmera
-- ---------------------------------------------------------------------------

create table public.product_submissions (
  id uuid primary key default gen_random_uuid(),
  barcode text not null check (barcode ~ '^[0-9]{8,14}$'),
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  -- Caminhos no bucket "submissions" ({user_id}/...).
  front_image text,
  ingredients_image text,
  ocr_text text,
  status public.submission_status not null default 'pending',
  created_at timestamptz not null default now()
);

create index product_submissions_user_id_idx on public.product_submissions (user_id);
create index product_submissions_pending_idx on public.product_submissions (created_at)
  where status = 'pending';

-- ---------------------------------------------------------------------------
-- scans: histórico do usuário (Home mostra os últimos 10)
-- ---------------------------------------------------------------------------

create table public.scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  barcode text not null check (barcode ~ '^[0-9]{8,14}$'),
  group_status public.verdict_status not null,
  created_at timestamptz not null default now()
);

create index scans_user_recent_idx on public.scans (user_id, created_at desc);
create index scans_barcode_idx on public.scans (barcode); -- popularidade para alternativas

-- ---------------------------------------------------------------------------
-- reports: "Isso está errado?"
-- ---------------------------------------------------------------------------

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  barcode text not null check (barcode ~ '^[0-9]{8,14}$'),
  message text not null check (char_length(message) between 1 and 2000),
  -- Caminho no bucket "submissions" ({user_id}/reports/...).
  image_url text,
  created_at timestamptz not null default now()
);

create index reports_user_id_idx on public.reports (user_id);
