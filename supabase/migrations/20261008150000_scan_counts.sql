-- Popularidade de produtos para ordenar alternativas seguras.
-- scans é privado por RLS; esta função expõe só o total por código de barras,
-- sem usuário nem status (nada de dado pessoal ou de saúde).
create function public.scan_counts(p_barcodes text[])
returns table (barcode text, scans bigint)
language sql
stable
security definer
set search_path = ''
as $$
  select s.barcode, count(*)::bigint
  from public.scans s
  where s.barcode = any (p_barcodes[1:100])
  group by s.barcode;
$$;

revoke execute on function public.scan_counts(text[]) from public, anon;
grant execute on function public.scan_counts(text[]) to authenticated;
