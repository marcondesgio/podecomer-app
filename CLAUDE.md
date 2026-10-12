# Pode Comer?

App Flutter (Android e iOS) que lê o código de barras de um produto e devolve, em menos de 2 segundos, um veredito de alergênicos **para cada pessoa do grupo familiar** e para o grupo inteiro. Quando o produto não é seguro, sugere alternativas seguras para todos. Produtos não encontrados podem ser cadastrados pela câmera ao vivo (OCR no aparelho) e entram numa fila de revisão.

Contexto completo: `docs/estudo-de-caso.md` (regras de negócio, fluxo, prompts por etapa) e `docs/Pode Comer — Design System.pdf` (marca, cores, tipografia, componentes).

> O app é uma ferramenta de apoio. A leitura do rótulo físico continua sendo a referência final. Esse aviso aparece em toda tela de resultado.

## Os 4 status

| Status | Enum (`VerdictStatus`) | Quando | Cor + ícone |
| --- | --- | --- | --- |
| NÃO CONSUMIR | `doNotConsume` | Ingredientes ou "CONTÉM" citam um alergênico da pessoa; ou "pode conter" para quem tem gravidade **grave** | Vermelho, octógono ✕ |
| ATENÇÃO | `caution` | "Pode conter" / traços / ingrediente ambíguo | Âmbar, triângulo ! |
| INCONCLUSIVO | `inconclusive` | Produto não encontrado, sem lista de ingredientes ou erro de rede | Cinza-azulado, quadrado ? |
| SEGURO | `safe` | Lista de ingredientes completa e nenhum alergênico do perfil | Verde, círculo ✓ |

**Precedência: NÃO CONSUMIR > ATENÇÃO > INCONCLUSIVO > SEGURO.**

- O veredito do grupo é o **pior** status entre os membros selecionados (`VerdictStatus.worstOf`). Grupo vazio → INCONCLUSIVO.
- Na dúvida, o motor **nunca** devolve SEGURO. Falha de rede, dado faltando ou texto ilegível → INCONCLUSIVO.
- O motor é determinístico (sem IA decidindo veredito) e fica em Dart puro em `lib/core/engine` (sem importar Flutter).
- Status sempre aparece como **cor + forma/ícone + palavra**, nunca só cor (`StatusBadge`).
- As 4 cores de status são reservadas: nunca usar em decoração, botões de marca ou ilustração. Âmbar nunca leva texto branco.

## Motor de alergênicos (`lib/core/engine`)

`AllergenEngine(dictionary).evaluate(product, pessoasSelecionadas)` → `GroupVerdict` com um `PersonVerdict` por pessoa e motivos (`VerdictReason`) que citam o trecho exato do rótulo.

- **Dicionário:** `assets/engine/allergen_dictionary.json` (termos com acento; normalizados ao carregar). Cada alergênico tem `terms` (contém), `ambiguous` (ATENÇÃO) e `exclusions` (falsos positivos como "manteiga de cacau", "leite de coco", "noz-moscada", "trigo sarraceno"). Também guarda as frases de traço, negações ("sem", "não contém"), alegações de zero lactose, `known_words` (palavras reais que nunca são "corrigidas" como erro de OCR) e o mapa de tags do Open Food Facts.
- **Regras além do óbvio:**
  - Sem ingredientes → INCONCLUSIVO, mas o que estiver **declarado** continua sendo avaliado (pode virar NÃO CONSUMIR, nunca SEGURO).
  - Qualquer traço de glúten (incluindo "pode conter trigo/centeio/cevada/aveia") → NÃO CONSUMIR para glúten, como "contém glúten" (Anvisa).
  - Ingrediente ambíguo → ATENÇÃO, mesmo para alergia grave.
  - Declarar trigo implica glúten; leite implica lactose e vice-versa.
- **OCR:** tolera 0/o, 1/l/i, rn/m, m/n, palavra partida ("amen doim"), hífen na quebra de linha e uma edição em termos com 8+ letras. Na dúvida o erro deve tender ao mais severo: exclusões, negações e "zero lactose" só casam de forma exata.
- Ao ajustar o dicionário, adicionar teste de acerto **e** de falso positivo em `test/core/engine/allergen_engine_test.dart`.
- No app, use `allergenEngineProvider` (`lib/core/data`), que carrega o JSON dos assets.

## Consulta de produto (`lib/core/data/products`)

`ProductRepository.lookup(barcode)` → `ProductFound(ProductRecord)` | `ProductNotFound` | `ProductLookupFailed`. O `ProductRecord` guarda origem (`ProductOrigin`), data dos dados e o `Product` que o motor consome. Na UI, use `productLookupProvider(barcode)`; "tentar de novo" = `ref.invalidate(...)`.

- Ordem: base própria `verified` → Open Food Facts → base própria `pending` (selo "não verificado") → não encontrado. Uma só consulta ao Supabase traz verified ou pending.
- Se uma fonte falhar antes da resposta → `ProductLookupFailed` (INCONCLUSIVO + "Tentar de novo"). Nunca pular para uma fonte menos confiável por causa de erro.
- OFF: User-Agent `PodeComer/1.0 (contato@podecomerapp.com.br)`, timeout 5 s, cache local de 7 dias (`shared_preferences`) só para produtos encontrados. O campo `lang` é pedido além da lista original: ingredientes que não estão em português não contam como lista utilizável, porque o dicionário é em pt e geraria um falso SEGURO.
- Se o OFF não tiver ingredientes e houver um cadastro pendente com ingredientes, o pendente é usado.
- Testes: `MockClient` do `package:http/testing.dart` e `FakeOwnProducts` (`test/core/data/products/fakes.dart`); nenhum teste acessa a rede.

## Scanner, resultado e alternativas

- **Scanner** (`/scanner`, tela cheia aberta pelo botão central; a câmera só fica ligada nela): EAN-13, EAN-8 e UPC-A. UPC-A vira EAN-13 (zero à esquerda) e o **dígito verificador é conferido**: uma leitura errada traria outro produto. Debounce de 3 s para o mesmo código, vibração (`HapticFeedback`), lanterna e "Para quem?". A câmera fica atrás de `BarcodeCamera` (`barcodeCameraProvider`) para testes.
- **"Para quem?"**: `excludedPeopleProvider` guarda quem saiu (membros novos entram selecionados; nunca fica vazio). `selectedPeopleProvider` é derivado **sincronamente**. Um `FutureProvider` aqui passaria por "recarregando com a seleção antiga" e daria o veredito para as pessoas erradas. A tela de resultado não calcula veredito enquanto os dados recarregam.
- **Resultado**: veredito do grupo (cor + ícone + palavra), avatares com status, motivos por pessoa citando o rótulo, origem e data, "Isso está errado?" (`reports`), "Próximo produto". O scan é gravado uma vez por tela (`scans`), sem bloquear o veredito.
- **Alternativas** (só em ATENÇÃO / NÃO CONSUMIR): base própria (só `verified`) + OFF `/api/v2/search?categories_tags=<categoria mais específica>&countries_tags=en:brazil`. Cada candidato passa pelo `AllergenEngine`; só SEGURO para todos os selecionados (sem ingredientes = INCONCLUSIVO = fora). Ordenadas pela RPC `scan_counts` (só totais agregados). Até 5; plano grátis vê 1.
- **Meta de 2 s scan→veredito**: `ScanTrace` mede do código lido ao veredito na tela (`scanMetricsProvider`, log só em debug, só tempo e cache). Para caber na meta:
  - memória de 10 min no `ProductRepository` e cache do OFF (7 dias por produto, 1 dia por busca);
  - OFF consultado em paralelo se a base própria não responder em 300 ms;
  - consulta iniciada antes da transição de tela;
  - motor, repositório e grupo aquecidos ao abrir o scanner;
  - histórico e alternativas depois do veredito.
- Testes que usam `rootBundle` em sequência: o dicionário é carregado com `cache: false` (o cache do bundle guardaria um `Future` preso ao relógio falso do teste anterior).

## Cadastro colaborativo (`features/product_submission`)

- Fluxo: Passo 1 frente → Passo 2 ingredientes → OCR → revisão → envio → veredito com o selo "Baseado no seu cadastro · em revisão".
- **Fotos só pela câmera ao vivo** (pacote `camera`, atrás de `DocumentCamera`), nunca galeria. Captura automática quando a imagem fica nítida e parada (`AutoCaptureDetector`: variância do laplaciano + diferença entre quadros, ~0,6 s estável); botão manual sempre disponível. Os limites são ponto de partida: ajustar em aparelho real.
- **OCR no aparelho** (ML Kit, `IngredientsOcr`) só na foto dos ingredientes. O texto vai para um campo editável (`AllergenHighlightController`) que destaca, enquanto a pessoa digita, os termos que o motor reconhece: "contém" em vermelho, traços e ambíguos em âmbar, sempre sublinhados.
- **Envio** (`SubmissionRepository`): comprime (JPEG até 1600 px, qualidade 80, sem EXIF, em isolate) → bucket `submissions` em `{user_id}/{barcode}/…` → RPC `submit_product`. A RPC cria a submissão e, se o produto não existir, um `products` `pending`; nunca altera produto existente. Limite: 30 envios por usuário em 24 h. Se a RPC falhar, as fotos enviadas são apagadas.
- **Revisão no painel do Supabase:**
  - `select * from pending_submissions_review;` (o app não tem acesso);
  - `select approve_submission('<id>');` ou `select approve_submission('<id>', 'texto corrigido');` → produto `verified`;
  - `select reject_submission('<id>');`.
  Essas funções não são executáveis pelo app.

## Assinatura (RevenueCat)

- Entitlement **`familia`**; offering padrão com pacotes mensal e anual (7 dias grátis configurados nas lojas). `SubscriptionService` (`lib/core/data/subscription/`) esconde o `purchases_flutter`; os testes usam um fake.
- O cliente do RevenueCat usa o **id do Supabase** como App User ID (`subscriptionIdentityProvider`, observado pelo app): é por ele que o servidor sabe de quem é a assinatura.
- `profiles.plan` só muda no servidor:
  - `sync-subscription` (chamada pelo app logo após compra/restauração);
  - `revenuecat-webhook` (renovação, cancelamento, expiração, transferência; deploy com `--no-verify-jwt` e header Authorization secreto).
  - Os dois consultam o estado atual na API REST do RevenueCat (`supabase/functions/_shared/revenuecat.ts`, testado em `supabase/tests/revenuecat_test.mjs`).
- Paywall: preços e teste grátis vêm da loja; texto de cancelamento com preço, período e caminho da loja; Restaurar, Termos e Privacidade (`lib/core/data/links.dart`).

## Publicação

Passo a passo e checklist de privacidade (App Privacy / Data safety) em `docs/publicacao.md`.

- Bundle id / applicationId: `com.podecomer.app`.
- Android release: R8 (`isMinifyEnabled`, `isShrinkResources`, `proguard-rules.pro`) + `--obfuscate --split-debug-info`. Assinatura por `android/key.properties` (fora do Git; modelo em `key.properties.example`).
- Permissões Android: só `CAMERA` e `INTERNET`. `RECORD_AUDIO` e `WRITE_EXTERNAL_STORAGE` do plugin `camera` são removidas com `tools:node="remove"`: não reintroduzir.
- iOS: `PrivacyInfo.xcprivacy` no target Runner, igual ao App Privacy declarado.
- Ícone e splash: `flutter_launcher_icons.yaml` e `flutter_native_splash.yaml`. Os PNGs de `assets/branding/` são **provisórios** (`tool/generate_brand_assets.dart`).

## Conta, sessão e rotas

- **Estado compartilhado em `lib/core/data`:** `auth/` (AuthRepository + `authControllerProvider`), `profile/`, `group/`, `people.dart` (Sex, Plan, helpers) e `account_providers.dart` (`myProfileProvider`, `groupMembersProvider`, `avatarUrlProvider`). As telas ficam nas features.
- **Sessão → rotas:** `sessionStatusProvider` (`lib/core/router/session.dart`) resume o acesso e `sessionRedirect` (`routes.dart`, função pura e testada) decide:
  - deslogado → só boas-vindas, cadastro, login, recuperar senha;
  - sem e-mail verificado → **só** `/verify-email`;
  - link de recuperação → só `/reset-password`;
  - sem `health_consent_at` → só `/onboarding/allergies`;
  - pronto → app (barra inferior: Início · Escanear · Meu Grupo · Meu Perfil).
- O `GoRouter` é criado uma vez; mudanças de sessão só reavaliam o redirect via `refreshListenable`.
- **Gravações atômicas por RPC:** `complete_onboarding` (consentimento + alergias), `set_person_allergens`, `save_group_member` (membro + alergias). Nunca gravar alergias em duas chamadas soltas.
- **Plano:** free = titular + 1 membro (`Plan.memberLimit`). "Adicionar membro" acima do limite abre o paywall; se o servidor recusar (`FreeMemberLimitReached`), também. O plano vem do RevenueCat (ver "Assinatura").
- **Fotos:** bucket privado `avatars`, caminho `{user_id}/avatar_<timestamp>.jpg`, exibidas com URL assinada. `image_picker` só aqui.
- **Excluir conta:** Edge Function `supabase/functions/delete-account` (apaga arquivos dos buckets e o usuário do Auth; o banco cai em cascade).

### Configuração do Supabase (painel)

- Auth › URL Configuration › Redirect URLs: `com.podecomer.app://login-callback`.
- Auth › Providers: Email com "Confirm email" ligado; Google e Apple configurados.
- Auth › senha mínima: 8 caracteres (o app também valida).
- Deploy: `supabase functions deploy delete-account`.
- O deep link é tratado pelo `supabase_flutter`; o deep linking do Flutter está desligado (Android `flutter_deeplinking_enabled`, iOS `FlutterDeepLinkingEnabled`) para o go_router não recebê-lo.

## Privacidade: dados de saúde

**Nunca colocar dados de saúde em logs, analytics, crash reports, URLs ou query strings.** Dados de saúde incluem: alergias, gravidade, membros do grupo e suas alergias, vereditos por pessoa e o motivo deles, e o texto de OCR associado a uma pessoa.

- Não usar `print`/`debugPrint`/`log` com objetos de perfil, pessoa, alergia ou veredito (nem via `toString()`).
- Eventos de analytics carregam só dados não sensíveis (ex.: `scan_completed` sem status nem alergênicos).
- Rotas recebem apenas identificadores neutros (ex.: `/result/:barcode`); o resto vai por estado (Riverpod).
- Chaves do `.env` também nunca são logadas.
- Base legal: LGPD (dado sensível). Consentimento registrado em `profiles.health_consent_at`.

## Stack

Flutter stable (3.44 / Dart 3.12) · flutter_riverpod · go_router · supabase_flutter · mobile_scanner · camera · google_mlkit_text_recognition · http · freezed + json_serializable · purchases_flutter (RevenueCat) · image_picker · image (compressão JPEG) · url_launcher · shared_preferences · flutter_dotenv · intl / flutter_localizations. Dev: flutter_launcher_icons, flutter_native_splash.

- `image_picker` é **só** para foto de perfil. Fotos de produto vêm **só** da câmera ao vivo (`camera`), nunca da galeria.
- `freezed` está fixado em 3.x porque o 4.x exige Dart ≥ 3.13.

## Estrutura (feature-first)

```
lib/
  main.dart            # bootstrap: intl pt_BR, dotenv, Supabase, ProviderScope
  app.dart             # MaterialApp.router, temas, localização
  core/
    engine/            # motor de alergênicos — Dart puro, sem Flutter
    data/              # Env, clientes Supabase / Open Food Facts, modelos compartilhados
    theme/             # AppColors, AppTheme, AppSizes, StatusColors (ThemeExtension)
    router/            # AppRoutes + appRouterProvider (go_router)
  features/
    auth/ onboarding/ home/ scanner/ result/ product_submission/ profile/ group/ paywall/
      data/            # repositórios, DTOs, fontes remotas
      domain/          # modelos e regras da feature
      presentation/    # telas, widgets, providers de UI
  l10n/                # app_pt.arb (template) + código gerado
test/                  # espelha lib/
supabase/
  migrations/          # SQL versionado (Supabase CLI)
  tests/               # testes de schema/RLS em Node + PGlite
```

Uma feature não importa outra feature diretamente; o que é compartilhado sobe para `core/`.

## Banco (Supabase)

Migrations em `supabase/migrations/` (esquema → RLS → storage). Nunca editar uma migration já aplicada: criar uma nova.

- **RLS em todas as tabelas.** Cada usuário só lê e escreve os próprios perfis, membros, alergias, scans, submissões e reports. `products` é só leitura (`verified` e `pending`) para autenticados; o app só cria produtos `pending` pela RPC `submit_product`; o catálogo `allergens` é leitura pública.
- **Escritas administrativas só via `service_role`:** `profiles.plan` (webhook do RevenueCat), `products`, mudança de status de `product_submissions`. O app só pode editar as colunas `name, birth_date, sex, avatar_url, health_consent_at` de `profiles`.
- **Consentimento:** gravar em `person_allergens` exige `profiles.health_consent_at` preenchido.
- **`person_allergens` é polimórfica** (`person_type` profile|member + `person_id`, sem FK): triggers validam a pessoa e apagam as alergias quando o perfil/membro é removido.
- **Plano free:** no máximo 1 membro em `group_members` (trigger `enforce_free_member_limit`, erro com hint `free_member_limit`).
- **`verdict_status`** (enum do banco) usa valores em pt (`seguro`, `inconclusivo`, `atencao`, `nao_consumir`), declarados em ordem de gravidade, então `max()` dá o pior status. Mapear para `VerdictStatus` no Dart com `@JsonValue`.
- **Storage:** buckets privados `avatars` e `submissions`, caminho sempre `{user_id}/arquivo`; o app usa URLs assinadas.
- Funções `security definer` sempre com `set search_path = ''` e nomes qualificados.

## Convenções de código

- **Idioma:** identificadores em inglês; textos para o usuário em pt-BR, sempre via `AppLocalizations` (`lib/l10n/app_pt.arb`), nunca string literal em widget. Comentários e docs em português.
- **Estado:** Riverpod. Providers ficam junto da feature que os usa.
- **Modelos:** `@freezed` + `json_serializable`. Arquivos gerados (`*.freezed.dart`, `*.g.dart`) são versionados.
- **Navegação:** só por `AppRoutes` / `context.go`, nunca strings soltas.
- **Tema:** cores e medidas só via `Theme.of(context)`, `context.statusColors` e `AppSizes`; nada de `Color(0x…)` fora de `core/theme`.
- **Design System:** texto base 16, nada abaixo de 13; alvos de toque ≥ 48 px; botão primário 60 px; margem lateral 20 px; ações principais no terço inferior; contraste AA (4,5:1) em todo par de texto.
- **Fonte:** Nunito. Ainda não empacotada: adicionar os `.ttf` em `assets/fonts/` e declarar no `pubspec.yaml` (família `Nunito`).
- **Estilo:** `dart format`, `flutter analyze` sem avisos (regras em `analysis_options.yaml`), aspas simples, vírgulas finais.
- **Segredos:** em `.env` (não versionado), lidos por `Env`. Modelo em `.env.example`.

## Comandos

```bash
flutter pub get
cp .env.example .env                                    # e preencha
flutter gen-l10n                                        # após editar .arb
dart run build_runner build --delete-conflicting-outputs # após editar modelos freezed/json
flutter run
```

## Testes

```bash
flutter test                                  # todos
flutter test test/core/engine                 # só o motor
flutter test --coverage                       # gera coverage/lcov.info
flutter analyze && dart format --set-exit-if-changed lib test
cd supabase/tests && npm install && npm test  # migrations + RLS (PGlite) + lógica do RevenueCat (Node ≥ 23)
```

- Toda mudança em migration ou política RLS precisa de caso em `supabase/tests/rls_test.mjs`, cobrindo o acesso permitido **e** o negado (outro usuário, anon).

- Toda regra do motor tem teste unitário em `test/core/engine` (meta do MVP: ≥ 40 casos, incluindo família Ana/Carol/Enzo, falsos positivos como "manteiga de cacau" e "leite de coco", e OCR imperfeito).
- Rede (Supabase, Open Food Facts) sempre mockada nos testes.
- Fluxos de tela usam o app real (roteador + redirect) com repositórios falsos: `AppHarness` em `test/support/account_fakes.dart`.
- `test/core/theme/app_theme_test.dart` garante contraste AA dos pares de status nos temas claro e escuro.
- Só avançar de etapa (prompts em `docs/estudo-de-caso.md`) com `flutter analyze` limpo e todos os testes passando.
