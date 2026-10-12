// Testes das migrations (schema, triggers e RLS) num Postgres em WASM (PGlite),
// com stubs mínimos de auth/storage do Supabase. Não precisa de Docker.
// Rodar: cd supabase/tests && npm install && npm test
import { PGlite } from '@electric-sql/pglite';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const migDir = process.argv[2] ?? fileURLToPath(new URL('../migrations', import.meta.url));
const db = new PGlite();

// --- Stubs do ambiente Supabase -------------------------------------------
await db.exec(`
create role anon nologin;
create role authenticated nologin;
create role service_role nologin bypassrls;
create schema auth;
create table auth.users (id uuid primary key, raw_user_meta_data jsonb default '{}');
create function auth.uid() returns uuid language sql stable as
  $$ select nullif(current_setting('request.jwt.claim.sub', true), '')::uuid $$;
create schema storage;
create table storage.buckets (id text primary key, name text, public boolean,
  file_size_limit bigint, allowed_mime_types text[]);
create table storage.objects (id uuid primary key default gen_random_uuid(),
  bucket_id text references storage.buckets(id), name text, owner uuid);
alter table storage.objects enable row level security;
create function storage.foldername(name text) returns text[] language sql immutable as
  $$ select (string_to_array(name, '/'))[1:array_length(string_to_array(name, '/'),1)-1] $$;
grant usage on schema public, auth, storage to anon, authenticated, service_role;
grant execute on function auth.uid() to anon, authenticated;
grant all on all tables in schema storage to anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to anon, authenticated, service_role;
`);

for (const f of fs.readdirSync(migDir).filter((f) => f.endsWith('.sql')).sort()) {
  try {
    await db.exec(fs.readFileSync(path.join(migDir, f), 'utf8'));
    console.log('migration ok:', f);
  } catch (e) {
    console.error('MIGRATION FAILED', f, e.message);
    process.exit(1);
  }
}

const A = '11111111-1111-1111-1111-111111111111';
const B = '22222222-2222-2222-2222-222222222222';
const CAROL = 'aaaaaaaa-0000-0000-0000-000000000001';
const ENZO = 'aaaaaaaa-0000-0000-0000-000000000002';
const THEO = 'bbbbbbbb-0000-0000-0000-000000000001';
let pass = 0;
let fail = 0;

async function as(user, sql) {
  await db.exec('reset role; reset request.jwt.claim.sub;');
  if (user === 'anon') await db.exec('set role anon;');
  else if (user) await db.exec(`set role authenticated; set request.jwt.claim.sub = '${user}';`);
  try {
    return await db.query(sql);
  } finally {
    await db.exec('reset role; reset request.jwt.claim.sub;');
  }
}
async function ok(name, user, sql, check) {
  try {
    const r = await as(user, sql);
    if (check && !check(r.rows, r)) {
      throw new Error('check failed: ' + JSON.stringify(r.rows) + ' affected=' + r.affectedRows);
    }
    pass++;
    console.log('  ok  ', name);
  } catch (e) {
    fail++;
    console.log('  FAIL', name, '->', e.message);
  }
}
async function bad(name, user, sql, re) {
  try {
    await as(user, sql);
    fail++;
    console.log('  FAIL', name, '-> deveria falhar');
  } catch (e) {
    if (re && !re.test(e.message)) {
      fail++;
      console.log('  FAIL', name, '-> erro inesperado:', e.message);
    } else {
      pass++;
      console.log('  ok  ', name, `(${e.message.slice(0, 70)})`);
    }
  }
}
const n = (c) => (rows) => rows.length === c;
const affected = (c) => (_, r) => r.affectedRows === c;

await ok('signup cria perfis', null, `insert into auth.users (id, raw_user_meta_data) values ('${A}', '{"name":"Ana"}'), ('${B}', '{"full_name":"Bia"}')`);
await ok('perfil com nome do metadata', null, 'select name from public.profiles order by name', (r) => r[0].name === 'Ana' && r[1].name === 'Bia');

console.log('profiles');
await ok('A lê só o próprio perfil', A, 'select * from public.profiles', (r) => r.length === 1 && r[0].id === A);
await ok('A edita o próprio nome', A, `update public.profiles set name = 'Ana Souza' where id = '${A}'`, affected(1));
await bad('A não altera o próprio plano', A, `update public.profiles set plan = 'familia' where id = '${A}'`, /permission denied/);
await ok('A não edita perfil de B (0 linhas)', A, `update public.profiles set name = 'x' where id = '${B}'`, affected(0));
await bad('A não cria perfil', A, 'insert into public.profiles (id) values (gen_random_uuid())', /permission denied/);
await ok('anon não vê perfis', 'anon', 'select * from public.profiles', n(0));

console.log('group_members + limite free');
await ok('A (free) cria 1º membro', A, `insert into public.group_members (id, name) values ('${CAROL}', 'Carol')`);
await bad('A (free) não cria 2º membro', A, `insert into public.group_members (name) values ('Enzo')`, /apenas 1 membro/);
await bad('A não cria membro em nome de B', A, `insert into public.group_members (owner_id, name) values ('${B}', 'X')`, /row-level security/);
await ok('backend muda A para familia', null, `update public.profiles set plan = 'familia' where id = '${A}'`);
await ok('A (familia) cria 2º membro', A, `insert into public.group_members (id, name) values ('${ENZO}', 'Enzo')`);
await ok('B não vê membros de A', B, 'select * from public.group_members', n(0));
await ok('B cria membro próprio', B, `insert into public.group_members (id, name) values ('${THEO}', 'Theo')`);
await ok('B não edita membro de A', B, `update public.group_members set name = 'x' where owner_id = '${A}'`, affected(0));
await ok('B não move membro de A para si', B, `update public.group_members set owner_id = '${B}' where id = '${CAROL}'`, affected(0));

console.log('allergens');
await ok('anon lê catálogo (12)', 'anon', 'select * from public.allergens', n(12));
await bad('A não altera catálogo', A, `insert into public.allergens values ('mostarda', 'Mostarda')`, /permission denied/);

console.log('person_allergens');
await bad('sem consentimento não grava alergia', A, `insert into public.person_allergens values ('profile', '${A}', 'amendoim', 'grave')`, /row-level security/);
await ok('A registra consentimento', A, `update public.profiles set health_consent_at = now() where id = '${A}'`);
await ok('A grava alergia própria', A, `insert into public.person_allergens (person_type, person_id, allergen_code, severity) values ('profile', '${A}', 'amendoim', 'grave')`);
await ok('A grava alergia de membros próprios', A, `insert into public.person_allergens (person_type, person_id, allergen_code) values ('member', '${CAROL}', 'gluten'), ('member', '${ENZO}', 'lactose')`);
await bad('A não grava alergia no membro de B', A, `insert into public.person_allergens (person_type, person_id, allergen_code) values ('member', '${THEO}', 'ovo')`, /row-level security/);
await bad('A não grava alergia no perfil de B', A, `insert into public.person_allergens (person_type, person_id, allergen_code) values ('profile', '${B}', 'ovo')`, /row-level security/);
await bad('alergênico inexistente', A, `insert into public.person_allergens (person_type, person_id, allergen_code) values ('profile', '${A}', 'mostarda')`, /foreign key/);
await bad('backend: pessoa inexistente', null, `insert into public.person_allergens (person_type, person_id, allergen_code) values ('member', gen_random_uuid(), 'ovo')`, /não existe/);
await ok('A lê 3 alergias', A, 'select * from public.person_allergens', n(3));
await ok('B não vê alergias de A', B, 'select * from public.person_allergens', n(0));
await ok('B não apaga alergias de A', B, 'delete from public.person_allergens', affected(0));
await ok('A apaga membro Enzo', A, `delete from public.group_members where id = '${ENZO}'`, affected(1));
await ok('alergias do Enzo removidas', null, `select * from public.person_allergens where person_id = '${ENZO}'`, n(0));

console.log('products');
await ok('backend insere produtos', null, `insert into public.products (barcode, name, source, status, allergens_contains, allergens_traces) values
  ('7891000100103', 'Biscoito', 'own', 'verified', '{gluten,trigo}', '{amendoim}'),
  ('7891000100110', 'Pendente', 'own', 'pending', '{}', '{}')`);
await bad('alergênico desconhecido em produto', null, `insert into public.products (barcode, source, allergens_contains) values ('7891000100127', 'off', '{mostarda}')`, /desconhecido/);
await bad('barcode inválido', null, `insert into public.products (barcode, source) values ('abc', 'off')`, /check/);
await ok('A lê verificados e pendentes', A, 'select barcode, status from public.products order by barcode', (r) => r.length === 2 && r[0].status === 'verified' && r[1].status === 'pending');
await ok('anon não lê produtos', 'anon', 'select * from public.products', n(0));
await bad('A não insere produto', A, `insert into public.products (barcode, source) values ('7891000100134', 'own')`, /permission denied/);
await bad('A não edita produto', A, `update public.products set name = 'x'`, /permission denied/);

console.log('product_submissions');
await ok('A cria submissão pendente', A, `insert into public.product_submissions (barcode, ocr_text) values ('7891000100141', 'farinha de trigo')`);
await bad('A não cria submissão aprovada', A, `insert into public.product_submissions (barcode, status) values ('7891000100141', 'approved')`, /row-level security/);
await bad('A não muda status', A, `update public.product_submissions set status = 'approved'`, /permission denied/);
await ok('B não vê submissões de A', B, 'select * from public.product_submissions', n(0));

console.log('scans / reports');
await ok('A grava scan', A, `insert into public.scans (barcode, group_status) values ('7891000100103', 'nao_consumir')`);
await ok('B não vê scans de A', B, 'select * from public.scans', n(0));
await bad('A não grava scan para B', A, `insert into public.scans (user_id, barcode, group_status) values ('${B}', '7891000100103', 'seguro')`, /row-level security/);
await ok('ordem do enum = precedência', null, `select max(s)::text as m from unnest(array['seguro','atencao','inconclusivo']::public.verdict_status[]) s`, (r) => r[0].m === 'atencao');
await ok('A cria report', A, `insert into public.reports (barcode, message) values ('7891000100103', 'Agora contém leite')`);
await ok('B não vê reports de A', B, 'select * from public.reports', n(0));

console.log('storage');
await ok('buckets privados', null, 'select id from storage.buckets where public = false', n(2));
await ok('A envia avatar na própria pasta', A, `insert into storage.objects (bucket_id, name) values ('avatars', '${A}/avatar.jpg')`);
await bad('A não envia na pasta de B', A, `insert into storage.objects (bucket_id, name) values ('avatars', '${B}/avatar.jpg')`, /row-level security/);
await bad('A não envia na raiz', A, `insert into storage.objects (bucket_id, name) values ('avatars', 'avatar.jpg')`, /row-level security/);
await ok('B não vê avatar de A', B, 'select * from storage.objects', n(0));
await ok('A envia submissão', A, `insert into storage.objects (bucket_id, name) values ('submissions', '${A}/front.jpg')`);
await ok('A não apaga submissão (0 linhas)', A, `delete from storage.objects where bucket_id = 'submissions'`, affected(0));

console.log('rpc');
await bad('trigger não é chamável por authenticated', A, 'select public.handle_new_user()', /permission denied/);
await bad('owns_person não é chamável por anon', 'anon', `select public.owns_person('profile', gen_random_uuid())`, /permission denied/);

console.log('rpc: complete_onboarding');
await ok('novo usuário C', null, `insert into auth.users (id) values ('33333333-3333-3333-3333-333333333333')`);
const C = '33333333-3333-3333-3333-333333333333';
await bad('código inválido desfaz o consentimento', C, `select public.complete_onboarding('[{"allergen_code":"mostarda"}]')`, /foreign key/);
await ok('consentimento continua vazio', null, `select health_consent_at from public.profiles where id = '${C}'`, (r) => r[0].health_consent_at === null);
await ok('C conclui o onboarding', C, `select public.complete_onboarding('[{"allergen_code":"gluten"}]')`);
await ok('consentimento e alergia gravados', null, `select p.health_consent_at, pa.allergen_code from public.profiles p join public.person_allergens pa on pa.person_id = p.id where p.id = '${C}'`, (r) => r.length === 1 && r[0].health_consent_at !== null && r[0].allergen_code === 'gluten');
await bad('anon não chama complete_onboarding', 'anon', `select public.complete_onboarding('[]')`, /permission denied/);

console.log('rpc: set_person_allergens / save_group_member');
await ok('A substitui as próprias alergias', A, `select public.set_person_allergens('profile', '${A}', '[{"allergen_code":"amendoim","severity":"grave"},{"allergen_code":"ovo"}]')`);
await ok('alergias substituídas (2, ovo leve)', A, `select allergen_code, severity::text from public.person_allergens where person_id = '${A}' order by allergen_code`, (r) => r.length === 2 && r[0].allergen_code === 'amendoim' && r[0].severity === 'grave' && r[1].severity === 'leve');
await bad('código inválido desfaz tudo', A, `select public.set_person_allergens('profile', '${A}', '[{"allergen_code":"mostarda"}]')`, /foreign key/);
await ok('alergias anteriores intactas', A, `select * from public.person_allergens where person_id = '${A}'`, n(2));
await bad('A não altera alergias do perfil de B', A, `select public.set_person_allergens('profile', '${B}', '[]')`, /Pessoa não encontrada/);
await bad('A não altera alergias do membro de B', A, `select public.set_person_allergens('member', '${THEO}', '[]')`, /Pessoa não encontrada/);
await bad('B sem consentimento não grava alergia de membro', B, `select public.set_person_allergens('member', '${THEO}', '[{"allergen_code":"ovo"}]')`, /row-level security/);
await ok('A cria membro com alergias', A, `select public.save_group_member(null, 'Lia', '2018-05-01', 'feminino', '[{"allergen_code":"leite_aplv","severity":"grave"}]') as id`, (r) => typeof r[0].id === 'string');
await ok('membro e alergia gravados juntos', A, `select m.name, pa.allergen_code from public.group_members m join public.person_allergens pa on pa.person_id = m.id where m.name = 'Lia'`, (r) => r.length === 1 && r[0].allergen_code === 'leite_aplv');
await ok('A edita membro (troca alergias)', A, `select public.save_group_member('${CAROL}', 'Carol S.', null, null, '[{"allergen_code":"trigo"}]')`);
await ok('edição aplicada', A, `select m.name, array_agg(pa.allergen_code) as codes from public.group_members m join public.person_allergens pa on pa.person_id = m.id where m.id = '${CAROL}' group by m.name`, (r) => r[0].name === 'Carol S.' && r[0].codes.length === 1 && r[0].codes[0] === 'trigo');
await bad('A não edita membro de B', A, `select public.save_group_member('${THEO}', 'X', null, null, '[]')`, /Membro não encontrado/);
await bad('B (free, 1 membro) não cria 2º membro via RPC', B, `select public.save_group_member(null, 'Bebê', null, null, '[]')`, /apenas 1 membro/);
await ok('nenhum membro parcial criado para B', null, `select * from public.group_members where owner_id = '${B}'`, n(1));
await bad('anon não chama save_group_member', 'anon', `select public.save_group_member(null, 'X', null, null, '[]')`, /permission denied/);

console.log('rpc: scan_counts');
await ok('B grava 2 scans do mesmo produto', B, `insert into public.scans (barcode, group_status) values ('7891000100103', 'seguro'), ('7891000100103', 'seguro'), ('7891000100110', 'atencao')`);
await ok('B vê o total agregado (inclui scans de A)', B, `select barcode, scans from public.scan_counts(array['7891000100103','7891000100110','0000000000000']) order by barcode`, (r) => r.length === 2 && Number(r[0].scans) === 3 && Number(r[1].scans) === 1);
await ok('B continua sem ver os scans de A', B, `select * from public.scans where user_id = '${A}'`, n(0));
await bad('anon não chama scan_counts', 'anon', `select * from public.scan_counts(array['7891000100103'])`, /permission denied/);

console.log('cadastro colaborativo');
const NEW = '7891000100158';
const submit = (code, front, ingr, text = 'Farinha de trigo, açúcar.') =>
  `select public.submit_product('${code}', 'Biscoito Novo', 'Marca', '${front}', '${ingr}', '${text}') as id`;
await ok('B envia cadastro de produto novo', B, submit(NEW, `${B}/${NEW}/front.jpg`, `${B}/${NEW}/ingr.jpg`), (r) => typeof r[0].id === 'string');
await ok('produto criado como pendente e legível', B, `select status::text, ingredients_text, source::text from public.products where barcode = '${NEW}'`, (r) => r.length === 1 && r[0].status === 'pending' && r[0].source === 'own' && r[0].ingredients_text === 'Farinha de trigo, açúcar.');
await ok('B vê a própria submissão', B, `select status::text from public.product_submissions where barcode = '${NEW}'`, (r) => r.length === 1 && r[0].status === 'pending');
await bad('fotos fora da própria pasta são recusadas', B, submit(NEW, `${A}/x.jpg`, `${B}/y.jpg`), /Fotos inválidas/);
await bad('caminho com .. é recusado', B, submit(NEW, `${B}/../${A}/x.jpg`, `${B}/y.jpg`), /Fotos inválidas/);
await bad('texto vazio é recusado', B, submit(NEW, `${B}/a.jpg`, `${B}/b.jpg`, '  '), /ingredientes vazia/);
await bad('código inválido é recusado', B, submit('123', `${B}/a.jpg`, `${B}/b.jpg`), /Código de barras inválido/);
await ok('cadastro de produto verificado não o altera', B, submit('7891000100103', `${B}/v/a.jpg`, `${B}/v/b.jpg`, 'Texto falso'));
await ok('verificado continua igual', null, `select status::text, name from public.products where barcode = '7891000100103'`, (r) => r[0].status === 'verified' && r[0].name === 'Biscoito');
await bad('anon não envia cadastro', 'anon', submit(NEW, 'x/a.jpg', 'x/b.jpg'), /permission denied/);
await bad('app não lê a fila de revisão', B, `select * from public.pending_submissions_review`, /permission denied/);
await bad('anon não lê a fila de revisão', 'anon', `select * from public.pending_submissions_review`, /permission denied/);
await ok('painel lê a fila de revisão', null, `select barcode, product_status::text, pending_for_barcode from public.pending_submissions_review where barcode = '${NEW}'`, (r) => r.length === 1 && r[0].product_status === 'pending' && Number(r[0].pending_for_barcode) === 1);
await bad('app não aprova submissão', B, `select public.approve_submission(id) from public.product_submissions where barcode = '${NEW}'`, /permission denied/);
await ok('painel aprova com texto corrigido', null, `select public.approve_submission(id, 'Farinha de trigo, açúcar, sal.') from public.product_submissions where barcode = '${NEW}'`);
await ok('produto verificado com o texto da revisão', B, `select status::text, ingredients_text from public.products where barcode = '${NEW}'`, (r) => r[0].status === 'verified' && r[0].ingredients_text === 'Farinha de trigo, açúcar, sal.');
await ok('submissão marcada como aprovada e fora da fila', null, `select (select status::text from public.product_submissions where barcode = '${NEW}') as s, (select count(*) from public.pending_submissions_review where barcode = '${NEW}') as c`, (r) => r[0].s === 'approved' && Number(r[0].c) === 0);
await bad('aprovar de novo falha', null, `select public.approve_submission(id) from public.product_submissions where barcode = '${NEW}'`, /já foi revisada/);
await ok('painel rejeita a submissão do produto verificado', null, `select public.reject_submission(id) from public.product_submissions where barcode = '7891000100103'`);
await ok('limite de 30 envios em 24 h', null, `insert into public.product_submissions (barcode, user_id, front_image, ingredients_image, ocr_text) select '7891000100165', '${B}', 'a', 'b', 'x' from generate_series(1, 28)`);
await bad('31º envio é recusado', B, submit('7891000100172', `${B}/a.jpg`, `${B}/b.jpg`), /Muitos cadastros/);

console.log('assinatura');
await bad('app não lê eventos de assinatura', A, `select * from public.subscription_events`, /permission denied/);
await bad('anon não grava eventos de assinatura', 'anon', `insert into public.subscription_events (id, type) values ('e1', 'TEST')`, /permission denied/);
await ok('backend registra evento (idempotente por id)', null, `insert into public.subscription_events (id, type) values ('e1', 'INITIAL_PURCHASE') on conflict do nothing`);
await ok('backend muda o plano', null, `update public.profiles set plan = 'familia' where id = '${B}'`, affected(1));

console.log('exclusão de conta');
await ok('apagar usuário A', null, `delete from auth.users where id = '${A}'`);
await ok('nada de A sobra', null, `select (select count(*) from public.profiles where id = '${A}')
  + (select count(*) from public.group_members where owner_id = '${A}')
  + (select count(*) from public.person_allergens pa where pa.person_id not in (select id from public.profiles union select id from public.group_members))
  + (select count(*) from public.scans where user_id = '${A}')
  + (select count(*) from public.reports where user_id = '${A}')
  + (select count(*) from public.product_submissions where user_id = '${A}') as c`, (r) => Number(r[0].c) === 0);

console.log(`\n${pass} passaram, ${fail} falharam`);
process.exit(fail ? 1 : 0);
