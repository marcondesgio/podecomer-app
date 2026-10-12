// Regras do plano a partir do RevenueCat. Sem imports de Deno: testável no
// Node (supabase/tests/revenuecat_test.mjs).

export const FAMILY_ENTITLEMENT = 'familia';

export type Plan = 'free' | 'familia';

export interface RcEntitlement {
  expires_date: string | null;
  product_identifier?: string;
}

export interface RcSubscriber {
  entitlements?: Record<string, RcEntitlement>;
}

export interface RcEvent {
  id?: string;
  type?: string;
  environment?: string;
  app_user_id?: string;
  original_app_user_id?: string;
  aliases?: string[];
  transferred_from?: string[];
  transferred_to?: string[];
}

const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** O app identifica o cliente no RevenueCat pelo id do Supabase. */
export function isAppUserId(value: unknown): value is string {
  return typeof value === 'string' && UUID.test(value);
}

/** Ativo se nunca expira (vitalício) ou expira no futuro. */
export function hasFamilyEntitlement(
  subscriber: RcSubscriber,
  now: Date,
): boolean {
  const entitlement = subscriber.entitlements?.[FAMILY_ENTITLEMENT];
  if (!entitlement) return false;
  if (entitlement.expires_date === null) return true;
  return new Date(entitlement.expires_date).getTime() > now.getTime();
}

export function planFor(subscriber: RcSubscriber, now: Date): Plan {
  return hasFamilyEntitlement(subscriber, now) ? 'familia' : 'free';
}

/**
 * Usuários cujo plano pode ter mudado com o evento. Em TRANSFER, os dois
 * lados. IDs anônimos do RevenueCat ($RCAnonymousID:...) são ignorados.
 */
export function affectedUserIds(event: RcEvent): string[] {
  const ids = [
    event.app_user_id,
    event.original_app_user_id,
    ...(event.aliases ?? []),
    ...(event.transferred_from ?? []),
    ...(event.transferred_to ?? []),
  ];
  return [...new Set(ids.filter(isAppUserId))];
}

/** Compara o header Authorization com o segredo em tempo constante. */
export function isAuthorized(
  header: string | null,
  secret: string | undefined,
): boolean {
  if (!header || !secret) return false;
  const a = new TextEncoder().encode(header.replace(/^Bearer\s+/i, ''));
  const b = new TextEncoder().encode(secret);
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
  return diff === 0;
}

/**
 * Estado atual do cliente na API REST do RevenueCat. Usar o estado (e não o
 * tipo do evento) evita erro com eventos fora de ordem ou repetidos.
 */
export async function fetchSubscriber(
  appUserId: string,
  secretApiKey: string,
  fetchImpl: typeof fetch = fetch,
): Promise<RcSubscriber> {
  const response = await fetchImpl(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
    { headers: { Authorization: `Bearer ${secretApiKey}` } },
  );
  if (!response.ok) {
    throw new Error(`revenuecat_${response.status}`);
  }
  const body = await response.json();
  return body.subscriber ?? {};
}
