// Sincroniza o plano de quem chama logo após compra ou restauração, sem
// esperar o webhook. Chamada pelo app com o JWT do usuário (verify_jwt
// ligado por padrão). Só atualiza o próprio perfil.
//
// Segredo: REVENUECAT_SECRET_API_KEY.
import { createClient } from 'jsr:@supabase/supabase-js@2';

import { fetchSubscriber, planFor } from '../_shared/revenuecat.ts';

Deno.serve(async (req) => {
  if (req.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);

  const token = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return json({ error: 'unauthorized' }, 401);

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );
  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return json({ error: 'unauthorized' }, 401);

  try {
    const subscriber = await fetchSubscriber(
      data.user.id,
      Deno.env.get('REVENUECAT_SECRET_API_KEY')!,
    );
    const plan = planFor(subscriber, new Date());
    const { error: updateError } = await admin
      .from('profiles')
      .update({ plan })
      .eq('id', data.user.id);
    if (updateError) throw updateError;
    return json({ plan }, 200);
  } catch (_) {
    return json({ error: 'sync_failed' }, 502);
  }
});

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
