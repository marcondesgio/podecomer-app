-- Pode Comer? — buckets de storage.
-- Convenção de caminho em ambos os buckets: {user_id}/{arquivo}.
-- Ambos são privados: o app usa URLs assinadas.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', false, 2 * 1024 * 1024,
    array['image/jpeg', 'image/png', 'image/webp']),
  ('submissions', 'submissions', false, 5 * 1024 * 1024,
    array['image/jpeg', 'image/png', 'image/webp']);

-- ---------------------------------------------------------------------------
-- avatars: privado por usuário (leitura e escrita só na própria pasta).
-- ---------------------------------------------------------------------------

create policy "avatars: ler a própria pasta"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars: enviar para a própria pasta"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars: substituir na própria pasta"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "avatars: apagar da própria pasta"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

-- ---------------------------------------------------------------------------
-- submissions: fotos de embalagem/ingredientes e de reports.
-- O usuário envia e lê as próprias; a revisão usa service_role.
-- Sem update/delete pelo app, para preservar a evidência da submissão.
-- ---------------------------------------------------------------------------

create policy "submissions: ler a própria pasta"
  on storage.objects for select to authenticated
  using (
    bucket_id = 'submissions'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );

create policy "submissions: enviar para a própria pasta"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'submissions'
    and (storage.foldername(name))[1] = (select auth.uid())::text
  );
