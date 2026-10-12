// Exclui a conta de quem chama: arquivos nos buckets e o usuário do Auth.
// Apagar auth.users dispara o cascade em profiles, group_members,
// person_allergens, scans, reports e product_submissions.
//
// Chamada pelo app com o JWT do usuário (verify_jwt ligado por padrão).
// Não registrar dados do usuário em log.
import { createClient, type SupabaseClient } from 'jsr:@supabase/supabase-js@2';

const BUCKETS = ['avatars', 'submissions'];

Deno.serve(async (req) => {
  if (req.method !== 'POST') {
    return json({ error: 'method_not_allowed' }, 405);
  }

  const token = req.headers.get('Authorization')?.replace(/^Bearer\s+/i, '');
  if (!token) return json({ error: 'unauthorized' }, 401);

  const admin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    { auth: { persistSession: false, autoRefreshToken: false } },
  );

  const { data, error } = await admin.auth.getUser(token);
  if (error || !data.user) return json({ error: 'unauthorized' }, 401);
  const userId = data.user.id;

  try {
    for (const bucket of BUCKETS) {
      const paths = await listFolder(admin, bucket, userId);
      for (let i = 0; i < paths.length; i += 100) {
        const { error: removeError } = await admin.storage
          .from(bucket)
          .remove(paths.slice(i, i + 100));
        if (removeError) throw removeError;
      }
    }

    const { error: deleteError } = await admin.auth.admin.deleteUser(userId);
    if (deleteError) throw deleteError;
  } catch (_) {
    return json({ error: 'delete_failed' }, 500);
  }

  return json({ deleted: true }, 200);
});

/** Lista todos os arquivos de {prefix}/, incluindo subpastas. */
async function listFolder(
  client: SupabaseClient,
  bucket: string,
  prefix: string,
): Promise<string[]> {
  const files: string[] = [];
  const pageSize = 1000;
  for (let offset = 0; ; offset += pageSize) {
    const { data, error } = await client.storage
      .from(bucket)
      .list(prefix, { limit: pageSize, offset });
    if (error) throw error;
    for (const item of data) {
      const path = `${prefix}/${item.name}`;
      // Pastas vêm sem id.
      if (item.id === null) {
        files.push(...(await listFolder(client, bucket, path)));
      } else {
        files.push(path);
      }
    }
    if (data.length < pageSize) return files;
  }
}

function json(body: unknown, status: number): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
