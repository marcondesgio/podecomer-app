-- Cadastro colaborativo: envio pelo app, revisão no painel e aprovação.

-- ---------------------------------------------------------------------------
-- submit_product: chamado pelo app depois de enviar as fotos ao bucket
-- "submissions". Cria a submissão e, se o produto ainda não existir, um
-- products com status 'pending' (leitura com o selo "não verificado").
-- Nunca altera um produto existente: um verificado continua verificado e um
-- pendente de outra pessoa não é sobrescrito antes da revisão.
-- ---------------------------------------------------------------------------
create function public.submit_product(
  p_barcode text,
  p_name text,
  p_brand text,
  p_front_image text,
  p_ingredients_image text,
  p_ocr_text text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  uid uuid := auth.uid();
  folder text;
  recent integer;
  submission_id uuid;
begin
  if uid is null then
    raise exception 'Sem sessão.' using errcode = '42501';
  end if;
  folder := uid::text || '/';

  if p_barcode !~ '^[0-9]{8,14}$' then
    raise exception 'Código de barras inválido.' using errcode = '22023';
  end if;
  if char_length(coalesce(btrim(p_ocr_text), '')) not between 3 and 5000 then
    raise exception 'Lista de ingredientes vazia ou longa demais.' using errcode = '22023';
  end if;
  if char_length(coalesce(p_name, '')) > 120 or char_length(coalesce(p_brand, '')) > 80 then
    raise exception 'Nome ou marca longos demais.' using errcode = '22023';
  end if;
  -- As fotos precisam estar na pasta de quem envia.
  if p_front_image is null or p_ingredients_image is null
     or left(p_front_image, length(folder)) <> folder
     or left(p_ingredients_image, length(folder)) <> folder
     or p_front_image like '%..%' or p_ingredients_image like '%..%' then
    raise exception 'Fotos inválidas.' using errcode = '22023';
  end if;

  -- Limite contra abuso: 30 envios por usuário em 24 h.
  select count(*) into recent
  from public.product_submissions
  where user_id = uid and created_at > now() - interval '24 hours';
  if recent >= 30 then
    raise exception 'Muitos cadastros hoje. Tente amanhã.'
      using errcode = 'P0001', hint = 'submission_rate_limit';
  end if;

  insert into public.product_submissions
    (barcode, user_id, front_image, ingredients_image, ocr_text)
  values
    (p_barcode, uid, p_front_image, p_ingredients_image, btrim(p_ocr_text))
  returning id into submission_id;

  insert into public.products
    (barcode, name, brand, ingredients_text, source, status, image_urls)
  values (
    p_barcode,
    nullif(btrim(p_name), ''),
    nullif(btrim(p_brand), ''),
    btrim(p_ocr_text),
    'own',
    'pending',
    array[p_front_image, p_ingredients_image]
  )
  on conflict (barcode) do nothing;

  return submission_id;
end;
$$;

revoke execute on function public.submit_product(text, text, text, text, text, text)
  from public, anon;
grant execute on function public.submit_product(text, text, text, text, text, text)
  to authenticated;

-- ---------------------------------------------------------------------------
-- Fila de revisão para o painel (SQL editor / Table editor, como postgres).
-- security_invoker: quem consulta precisa de acesso às tabelas; e o app
-- (anon/authenticated) não tem acesso à view.
-- ---------------------------------------------------------------------------
create view public.pending_submissions_review
with (security_invoker = true)
as
select
  s.id as submission_id,
  s.created_at,
  s.barcode,
  p.name as product_name,
  p.brand as product_brand,
  p.status as product_status,
  s.ocr_text,
  s.front_image,
  s.ingredients_image,
  (
    select count(*)
    from public.product_submissions other
    where other.barcode = s.barcode and other.status = 'pending'
  ) as pending_for_barcode,
  s.user_id
from public.product_submissions s
left join public.products p on p.barcode = s.barcode
where s.status = 'pending'
order by s.created_at;

revoke all on public.pending_submissions_review from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Aprovação / rejeição (só no painel: sem execute para o app).
-- p_ingredients_text permite corrigir o OCR na revisão.
-- ---------------------------------------------------------------------------
create function public.approve_submission(
  p_id uuid,
  p_ingredients_text text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  sub public.product_submissions;
  final_text text;
begin
  select * into sub from public.product_submissions where id = p_id for update;
  if not found then
    raise exception 'Submissão % não encontrada.', p_id using errcode = 'P0002';
  end if;
  if sub.status <> 'pending' then
    raise exception 'Submissão % já foi revisada (%).', p_id, sub.status
      using errcode = '22023';
  end if;

  final_text := coalesce(nullif(btrim(p_ingredients_text), ''), sub.ocr_text);

  update public.product_submissions set status = 'approved' where id = p_id;

  insert into public.products
    (barcode, ingredients_text, source, status, image_urls)
  values (
    sub.barcode, final_text, 'own', 'verified',
    array[sub.front_image, sub.ingredients_image]
  )
  on conflict (barcode) do update
  set ingredients_text = excluded.ingredients_text,
      image_urls = excluded.image_urls,
      source = 'own',
      status = 'verified';
end;
$$;

create function public.reject_submission(p_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.product_submissions
  set status = 'rejected'
  where id = p_id and status = 'pending';

  if not found then
    raise exception 'Submissão % não está pendente.', p_id using errcode = '22023';
  end if;
end;
$$;

revoke execute on function public.approve_submission(uuid, text)
  from public, anon, authenticated;
revoke execute on function public.reject_submission(uuid)
  from public, anon, authenticated;
