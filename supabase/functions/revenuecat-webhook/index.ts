// Webhook do RevenueCat → profiles.plan.
//
// Deploy SEM verificação de JWT (o RevenueCat não envia JWT do Supabase):
//   supabase functions deploy revenuecat-webhook --no-verify-jwt
// No RevenueCat (Integrations › Webhooks), configure o header
// Authorization com o mesmo valor do segredo REVENUECAT_WEBHOOK_AUTH.
//
// Segredos: REVENUECAT_WEBHOOK_AUTH, REVENUECAT_SECRET_API_KEY.
// Não registrar dados do usuário em log.
import { createClient } from 'jsr:@supabase/supabase-js@2';

import {
  affectedUserIds,
  fetchSubscriber,
  isAuthorized,
  planFor,
  type RcEvent,
} from '../_shared/revenuecat.ts';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  if (
    !isAuthorized(
      req.headers.get('Authorization'),
      Deno.env.get('REVENUECAT_WEBHOOK_AUTH'),
    )
  ) {
    return json({ error: 'unauthorized' }, 401);
  }

  let event: RcEvent;
  try {
    event = (await req.json()).event ?? {};
  } catch (_) {
    return json({ error: 'bad_request' }, 400);
  }

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  // Idempotência: evento já processado → 200 sem refazer.
  if (event.id) {
    const { data: seen } = await admin
      .from('subscription_events')
      .select('id')
      .eq('id', event.id)
      .maybeSingle();
    if (seen) return json({ duplicate: true }, 200);
  }

  try {
    const now = new Date();
    for (const userId of affectedUserIds(event)) {
      const subscriber = await fetchSubscriber(
        userId,
        Deno.env.get('REVENUECAT_SECRET_API_KEY')!,
      );
      const { error } = await admin
        .from('profiles')
        .update({ plan: planFor(subscriber, now) })
        .eq('id', userId);
      if (error) throw error;
    }

    if (event.id) {
      await admin.from('subscription_events').insert({
        id: event.id,
        type: event.type ?? 'UNKNOWN',
        app_user_id: event.app_user_id ?? null,
        environment: event.environment ?? null,
      });
    }
  } catch (_) {
    // 5xx: o RevenueCat tenta de novo mais tarde.
    return json({ error: 'sync_failed' }, 500);
  }

  return json({ ok: true }, 200);
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
