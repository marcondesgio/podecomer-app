-- Pode Comer? — Row Level Security.
-- Regra geral: cada usuário só enxerga e altera os próprios dados.
-- Escritas administrativas (products, plan, revisão de submissões) usam service_role,
-- que ignora RLS.

alter table public.profiles enable row level security;
alter table public.group_members enable row level security;
alter table public.allergens enable row level security;
alter table public.person_allergens enable row level security;
alter table public.products enable row level security;
alter table public.product_submissions enable row level security;
alter table public.scans enable row level security;
alter table public.reports enable row level security;

-- ---------------------------------------------------------------------------
-- profiles: perfil criado pelo trigger; o app só lê e edita campos permitidos.
-- ---------------------------------------------------------------------------

create policy "profiles: ler o próprio"
  on public.profiles for select to authenticated
  using (id = (select auth.uid()));

create policy "profiles: editar o próprio"
  on public.profiles for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

-- plan, id e datas de controle não são editáveis pelo app.
revoke insert, update, delete on public.profiles from anon, authenticated;
grant update (name, birth_date, sex, avatar_url, health_consent_at)
  on public.profiles to authenticated;

-- ---------------------------------------------------------------------------
-- group_members
-- ---------------------------------------------------------------------------

create policy "group_members: ler os próprios"
  on public.group_members for select to authenticated
  using (owner_id = (select auth.uid()));

create policy "group_members: criar os próprios"
  on public.group_members for insert to authenticated
  with check (owner_id = (select auth.uid()));

create policy "group_members: editar os próprios"
  on public.group_members for update to authenticated
  using (owner_id = (select auth.uid()))
  with check (owner_id = (select auth.uid()));

create policy "group_members: apagar os próprios"
  on public.group_members for delete to authenticated
  using (owner_id = (select auth.uid()));

-- ---------------------------------------------------------------------------
-- allergens: catálogo público de leitura (usado no onboarding antes do login).
-- ---------------------------------------------------------------------------

create policy "allergens: leitura pública"
  on public.allergens for select to anon, authenticated
  using (true);

revoke insert, update, delete on public.allergens from anon, authenticated;

-- ---------------------------------------------------------------------------
-- person_allergens: dono da pessoa (titular ou membro do seu grupo).
-- ---------------------------------------------------------------------------

create function public.owns_person(p_type public.person_type, p_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select case p_type
    when 'profile' then p_id = auth.uid()
    else exists (
      select 1 from public.group_members m
      where m.id = p_id and m.owner_id = auth.uid()
    )
  end;
$$;

create function public.has_health_consent()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid() and health_consent_at is not null
  );
$$;

revoke execute on function public.owns_person(public.person_type, uuid) from public, anon;
revoke execute on function public.has_health_consent() from public, anon;
grant execute on function public.owns_person(public.person_type, uuid) to authenticated;
grant execute on function public.has_health_consent() to authenticated;

create policy "person_allergens: ler das próprias pessoas"
  on public.person_allergens for select to authenticated
  using (public.owns_person(person_type, person_id));

-- Gravar dado de saúde exige consentimento LGPD registrado.
create policy "person_allergens: criar com consentimento"
  on public.person_allergens for insert to authenticated
  with check (
    public.owns_person(person_type, person_id)
    and (select public.has_health_consent())
  );

create policy "person_allergens: editar com consentimento"
  on public.person_allergens for update to authenticated
  using (public.owns_person(person_type, person_id))
  with check (
    public.owns_person(person_type, person_id)
    and (select public.has_health_consent())
  );

create policy "person_allergens: apagar das próprias pessoas"
  on public.person_allergens for delete to authenticated
  using (public.owns_person(person_type, person_id));

-- ---------------------------------------------------------------------------
-- products: autenticados leem só os verificados; escrita só via service_role.
-- ---------------------------------------------------------------------------

create policy "products: autenticados leem verificados"
  on public.products for select to authenticated
  using (status = 'verified');

revoke insert, update, delete on public.products from anon, authenticated;

-- ---------------------------------------------------------------------------
-- product_submissions: o usuário cria e lê as próprias; revisão via service_role.
-- ---------------------------------------------------------------------------

create policy "product_submissions: ler as próprias"
  on public.product_submissions for select to authenticated
  using (user_id = (select auth.uid()));

create policy "product_submissions: criar as próprias como pendentes"
  on public.product_submissions for insert to authenticated
  with check (user_id = (select auth.uid()) and status = 'pending');

-- Status só muda na revisão (service_role).
revoke update, delete on public.product_submissions from anon, authenticated;

-- ---------------------------------------------------------------------------
-- scans
-- ---------------------------------------------------------------------------

create policy "scans: ler os próprios"
  on public.scans for select to authenticated
  using (user_id = (select auth.uid()));

create policy "scans: criar os próprios"
  on public.scans for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "scans: apagar os próprios"
  on public.scans for delete to authenticated
  using (user_id = (select auth.uid()));

revoke update on public.scans from anon, authenticated;

-- ---------------------------------------------------------------------------
-- reports
-- ---------------------------------------------------------------------------

create policy "reports: ler os próprios"
  on public.reports for select to authenticated
  using (user_id = (select auth.uid()));

create policy "reports: criar os próprios"
  on public.reports for insert to authenticated
  with check (user_id = (select auth.uid()));

revoke update, delete on public.reports from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Funções de trigger não devem ser chamadas pela API (PostgREST /rpc).
-- ---------------------------------------------------------------------------

revoke execute on function public.handle_new_user() from public, anon, authenticated;
revoke execute on function public.enforce_free_member_limit() from public, anon, authenticated;
revoke execute on function public.validate_person_allergen() from public, anon, authenticated;
revoke execute on function public.delete_person_allergens() from public, anon, authenticated;
revoke execute on function public.validate_product_allergens() from public, anon, authenticated;
revoke execute on function public.set_updated_at() from public, anon, authenticated;
