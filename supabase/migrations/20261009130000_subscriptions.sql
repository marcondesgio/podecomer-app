-- Assinatura (RevenueCat): eventos do webhook já processados.
-- Serve para idempotência (o RevenueCat reenvia eventos) e auditoria.
-- Sem dados de saúde; acesso só pelo service_role (Edge Functions).
create table public.subscription_events (
  id text primary key,                 -- event.id do RevenueCat
  type text not null,
  app_user_id text,
  environment text,
  received_at timestamptz not null default now()
);

alter table public.subscription_events enable row level security;
revoke all on public.subscription_events from anon, authenticated;
