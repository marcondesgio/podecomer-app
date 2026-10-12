// Regras do plano a partir do RevenueCat (supabase/functions/_shared).
// Rodar: node --test revenuecat_test.mjs (Node ≥ 23, executa .ts direto).
import assert from 'node:assert/strict';
import { test } from 'node:test';

import {
  affectedUserIds,
  fetchSubscriber,
  hasFamilyEntitlement,
  isAuthorized,
  planFor,
} from '../functions/_shared/revenuecat.ts';

const NOW = new Date('2026-10-09T12:00:00Z');
const USER = '11111111-1111-1111-1111-111111111111';
const OTHER = '22222222-2222-2222-2222-222222222222';

test('entitlement "familia" com validade futura → familia', () => {
  const s = { entitlements: { familia: { expires_date: '2026-11-09T12:00:00Z' } } };
  assert.equal(planFor(s, NOW), 'familia');
});

test('teste grátis em andamento conta como ativo', () => {
  const s = { entitlements: { familia: { expires_date: '2026-10-12T00:00:00Z', period_type: 'trial' } } };
  assert.equal(hasFamilyEntitlement(s, NOW), true);
});

test('expirado → free', () => {
  const s = { entitlements: { familia: { expires_date: '2026-10-01T00:00:00Z' } } };
  assert.equal(planFor(s, NOW), 'free');
});

test('sem validade (vitalício) → familia', () => {
  assert.equal(planFor({ entitlements: { familia: { expires_date: null } } }, NOW), 'familia');
});

test('outro entitlement ou nenhum → free', () => {
  assert.equal(planFor({ entitlements: { premium: { expires_date: null } } }, NOW), 'free');
  assert.equal(planFor({}, NOW), 'free');
});

test('usuários afetados: só UUIDs, sem repetir, incluindo transferência', () => {
  const ids = affectedUserIds({
    app_user_id: USER,
    original_app_user_id: '$RCAnonymousID:abc',
    aliases: [USER, '$RCAnonymousID:abc'],
    transferred_from: [OTHER],
    transferred_to: [USER],
  });
  assert.deepEqual(ids.sort(), [USER, OTHER].sort());
});

test('evento de teste do painel (id não-UUID) não afeta ninguém', () => {
  assert.deepEqual(affectedUserIds({ app_user_id: 'test_user' }), []);
});

test('autorização do webhook', () => {
  assert.equal(isAuthorized('segredo-123', 'segredo-123'), true);
  assert.equal(isAuthorized('Bearer segredo-123', 'segredo-123'), true);
  assert.equal(isAuthorized('segredo-124', 'segredo-123'), false);
  assert.equal(isAuthorized(null, 'segredo-123'), false);
  assert.equal(isAuthorized('qualquer', undefined), false);
});

test('busca o cliente na API REST com a chave secreta', async () => {
  let called;
  const fakeFetch = async (url, init) => {
    called = { url, auth: init.headers.Authorization };
    return new Response(JSON.stringify({ subscriber: { entitlements: {} } }));
  };
  const subscriber = await fetchSubscriber(USER, 'sk_x', fakeFetch);
  assert.deepEqual(subscriber, { entitlements: {} });
  assert.equal(called.url, `https://api.revenuecat.com/v1/subscribers/${USER}`);
  assert.equal(called.auth, 'Bearer sk_x');
});

test('erro da API vira exceção (o webhook responde 5xx e o RevenueCat reenvia)', async () => {
  const fakeFetch = async () => new Response('{}', { status: 503 });
  await assert.rejects(fetchSubscriber(USER, 'sk_x', fakeFetch), /revenuecat_503/);
});
