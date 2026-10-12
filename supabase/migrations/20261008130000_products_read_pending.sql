-- Consulta de produto, etapa 3: cadastros da comunidade ainda não revisados
-- (status 'pending') também são lidos pelo app, com o selo "não verificado".
-- Produtos não têm dados pessoais nem de saúde; a escrita continua só via
-- service_role.

drop policy "products: autenticados leem verificados" on public.products;

create policy "products: autenticados leem verificados e pendentes"
  on public.products for select to authenticated
  using (status in ('verified', 'pending'));
