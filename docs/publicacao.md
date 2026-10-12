# Publicação — Pode Comer?

Bundle id / applicationId: **`com.podecomer.app`** · Deep link: `com.podecomer.app://login-callback`

## 1. Antes da primeira build de loja

- [ ] Trocar o ícone e o splash **provisórios** pelo logo oficial: substituir os PNGs de `assets/branding/` (mesmos nomes e tamanhos) e rodar:
  ```bash
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```
- [ ] Publicar as páginas `https://podecomerapp.com.br/privacidade` e `/termos` (o app e o paywall já apontam para elas: `lib/core/data/links.dart`).
- [ ] Publicar uma página de **exclusão de conta** na web (exigência do Google Play), ex.: `https://podecomerapp.com.br/excluir-conta`, explicando o caminho no app (Meu Perfil › Excluir conta) e um e-mail de contato para pedidos.
- [ ] Supabase: adicionar `com.podecomer.app://login-callback` em Auth › URL Configuration › Redirect URLs (substitui o antigo `br.com.podecomerapp://…`).
- [ ] Google e Apple Sign-In configurados no Supabase com o novo bundle id.

## 2. RevenueCat e assinatura Família

**Lojas**
- [ ] App Store Connect: assinaturas `familia_mensal` (R$ 9,90) e `familia_anual` (R$ 79,90) no mesmo grupo, cada uma com **oferta introdutória gratuita de 1 semana**.
- [ ] Google Play Console: assinatura com base plans mensal e anual, cada um com **oferta de teste grátis de 7 dias**.

**RevenueCat**
- [ ] Entitlement **`familia`** com os dois produtos.
- [ ] Offering padrão (*current*) com os pacotes **Monthly** (`$rc_monthly`) e **Annual** (`$rc_annual`).
- [ ] Chaves públicas no `.env`: `REVENUECAT_API_KEY_ANDROID`, `REVENUECAT_API_KEY_IOS`.
- [ ] Integrations › Webhooks: URL `https://<projeto>.supabase.co/functions/v1/revenuecat-webhook` e header **Authorization** com um segredo forte.

**Supabase (Edge Functions)**
```bash
supabase secrets set REVENUECAT_WEBHOOK_AUTH=<mesmo segredo do header> REVENUECAT_SECRET_API_KEY=<sk_... do RevenueCat>
```
```bash
supabase functions deploy revenuecat-webhook --no-verify-jwt
```
```bash
supabase functions deploy sync-subscription
```
```bash
supabase functions deploy delete-account
```

Como o plano é sincronizado:
- O app identifica o cliente do RevenueCat pelo id do Supabase.
- Após compra ou restauração, chama `sync-subscription`, que lê o RevenueCat e grava `profiles.plan` na hora.
- O webhook mantém o plano certo nas renovações, cancelamentos, expirações e transferências.
- Os dois consultam o **estado atual** na API do RevenueCat, então eventos repetidos ou fora de ordem não causam erro. Eventos já processados ficam em `subscription_events`.
- Ao voltar para o plano gratuito, os membros existentes continuam; só não é possível adicionar novos acima do limite.

Testes: sandbox (iOS) e testadores de licença (Android). Confira em RevenueCat › Customers que o *App User ID* é o UUID do Supabase.

## 3. Android — build de release assinada

1. Gerar a chave de upload (uma vez; guarde a senha e um backup do arquivo fora do repositório):
   ```bash
   keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
2. Copiar `android/key.properties.example` para `android/key.properties` e preencher. Arquivo e chave estão no `.gitignore`.
3. Build (R8 com minificação e encolhimento de recursos no Java/Kotlin; Dart ofuscado):
   ```bash
   flutter build appbundle --release --obfuscate --split-debug-info=build/symbols/android
   ```
4. Guardar `build/symbols/android` de cada versão: sem esses arquivos, os stack traces ofuscados não podem ser lidos.
5. Usar o Play App Signing (recomendado): a chave acima é só a de upload.

Sem `android/key.properties`, o release é assinado com a chave de debug (o build avisa) e a Play Store recusa.

Permissões finais do Android: `CAMERA` e `INTERNET`. `RECORD_AUDIO` e `WRITE_EXTERNAL_STORAGE`, que o plugin `camera` declara, são removidas no manifest.

## 4. iOS — build de release

- [ ] No Xcode, Runner › Signing & Capabilities: time, bundle `com.podecomer.app`, capability **Sign in with Apple** e **In-App Purchase**.
- [ ] `PrivacyInfo.xcprivacy` já está no target Runner (confira em Build Phases › Copy Bundle Resources).
- [ ] Build:
  ```bash
  flutter build ipa --release --obfuscate --split-debug-info=build/symbols/ios
  ```
- `ITSAppUsesNonExemptEncryption = false` no Info.plist: o app usa só HTTPS padrão.
- Textos de permissão (pt-BR) no Info.plist:
  - **Câmera:** "A câmera lê o código de barras e fotografa a embalagem e a lista de ingredientes dos produtos que você cadastra."
  - **Fotos:** "Usamos a galeria apenas para você escolher a sua foto de perfil."

## 5. Apple — App Privacy (App Store Connect)

**Rastreamento: não.** Nenhum dado é usado para rastrear o usuário entre apps ou sites de terceiros. Sem anúncios e sem analytics de terceiros.

| Categoria Apple | Tipo | O que é no app | Vinculado à pessoa | Finalidade |
| --- | --- | --- | --- | --- |
| Health & Fitness | **Health** | Alergias e gravidade do titular e dos membros do grupo | Sim | Funcionalidade do app |
| Contact Info | **Email Address** | Login e recuperação de senha | Sim | Funcionalidade do app |
| Contact Info | **Name** | Nome do titular e dos membros | Sim | Funcionalidade do app |
| User Content | **Photos or Videos** | Foto de perfil; fotos da embalagem no cadastro de produto | Sim | Funcionalidade do app |
| User Content | **Other User Content** | Texto de ingredientes enviado; "Isso está errado?" | Sim | Funcionalidade do app |
| Search History | **Search History** | Histórico de produtos escaneados | Sim | Funcionalidade do app |
| Identifiers | **User ID** | Id da conta (Supabase), também usado no RevenueCat | Sim | Funcionalidade do app |
| Purchases | **Purchase History** | Status da assinatura Família | Sim | Funcionalidade do app |
| Other Data | **Other Data Types** | Data de nascimento e sexo (opcionais) | Sim | Funcionalidade do app |

O mesmo conteúdo está em `ios/Runner/PrivacyInfo.xcprivacy`; mantenha os dois iguais.

Outros itens da revisão da Apple:
- [ ] Exclusão de conta dentro do app: Meu Perfil › Excluir conta (feito).
- [ ] Sign in with Apple oferecido junto com Google (feito).
- [ ] Paywall com preço, período, renovação automática, como cancelar, Termos e Privacidade (feito; os links precisam estar publicados).
- [ ] Conta de demonstração para o revisor (e-mail confirmado, com grupo e alergias) nas notas da revisão.
- [ ] Classificação etária: marcar "Informações médicas/tratamento: pouco frequente". Na descrição, deixar claro que é uma ferramenta de apoio e que o rótulo físico é a referência final.

## 6. Google Play — Data safety

**Coleta e compartilhamento**
- Dados criptografados em trânsito: **sim** (HTTPS).
- A pessoa pode pedir a exclusão: **sim**, dentro do app e pela URL de exclusão de conta.
- Compartilhamento com terceiros: **não**. Supabase e RevenueCat são prestadores de serviço, o que não conta como compartilhamento. O OCR do ML Kit roda no aparelho. O Open Food Facts recebe só o código de barras, sem dados pessoais.

| Categoria Google | Tipo | Coletado | Obrigatório ou opcional | Finalidade |
| --- | --- | --- | --- | --- |
| Saúde e condicionamento físico | **Informações de saúde** (alergias e gravidade) | Sim | Obrigatório (núcleo do app; com consentimento explícito) | Funcionalidade do app |
| Informações pessoais | **Endereço de e-mail** | Sim | Obrigatório | Funcionalidade do app; gerenciamento da conta |
| Informações pessoais | **Nome** | Sim | Obrigatório | Funcionalidade do app; gerenciamento da conta |
| Informações pessoais | **IDs do usuário** | Sim | Obrigatório | Funcionalidade do app; gerenciamento da conta |
| Informações pessoais | **Outras informações** (data de nascimento, sexo) | Sim | Opcional | Funcionalidade do app |
| Fotos e vídeos | **Fotos** | Sim | Opcional | Funcionalidade do app |
| Atividade no app | **Histórico de pesquisa no app** (produtos escaneados) | Sim | Obrigatório | Funcionalidade do app |
| Atividade no app | **Outro conteúdo gerado pelo usuário** (ingredientes, relatos) | Sim | Opcional | Funcionalidade do app |
| Informações financeiras | **Histórico de compras** (assinatura) | Sim | Opcional | Funcionalidade do app |

- [ ] Confirmar na documentação de privacidade do RevenueCat se o SDK coleta algum identificador de dispositivo na versão usada; se sim, declarar em "IDs do dispositivo ou outros IDs".
- [ ] Questionário "Apps de saúde" do Play Console: o app não é um dispositivo médico e não diagnostica nem trata doenças.
- [ ] Permissão de câmera justificada na ficha: leitura de código de barras e fotos de rótulos.

## 7. Conferência final

- [ ] `flutter analyze` sem avisos e `flutter test` passando.
- [ ] `cd supabase/tests && npm test` passando.
- [ ] Teste em aparelho real de:
  - [ ] scanner;
  - [ ] cadastro com captura automática e OCR;
  - [ ] compra em sandbox;
  - [ ] link de confirmação de e-mail;
  - [ ] exclusão de conta.
- [ ] Tempo scan→veredito abaixo de 2 s em aparelho intermediário (log `pode_comer.perf` em debug).
