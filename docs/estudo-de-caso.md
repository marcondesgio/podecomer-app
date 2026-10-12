# App de Alergênicos — Estudo de Caso, MVP e Prompts

Oct 8, 2026 · @Giovanna

## Resumo executivo

A recomendação é lançar em até 10 semanas um MVP em Flutter + Supabase, gratuito para 1 perfil e com assinatura **Família** (grupo ilimitado) a partir de R$ 9,90/mês, custando menos de R$ 1.500 até a publicação nas duas lojas.

**Problema.** Famílias com múltiplas alergias gastam horas lendo rótulos. No caso da Ana, cada produto precisa ser checado contra três restrições diferentes: amendoim (Ana), glúten (Carol) e lactose (Enzo). Um erro tem custo de saúde, não só de tempo.

**Solução.** Escanear o código de barras com a câmera e receber, em menos de 2 segundos, um veredito **por pessoa do grupo**: SEGURO, ATENÇÃO, NÃO CONSUMIR ou INCONCLUSIVO. Quando o produto não é seguro, o app sugere alternativas semelhantes que são seguras para todos.

**Diferencial.** Concorrentes globais (Yuka, Fig, Open Food Facts) avaliam um usuário por vez ou focam em nutrição. O valor aqui está em três coisas juntas: (1) veredito para o **grupo inteiro** numa única leitura, (2) base colaborativa de produtos **brasileiros** e (3) a pergunta que a Ana realmente faz no corredor: “o que posso levar no lugar?”.

**Frase de valor:** “Um scan. A família toda protegida.”

> Aviso permanente do produto: o app é uma ferramenta de apoio. A leitura do rótulo físico continua sendo a referência final, especialmente em casos de anafilaxia.

## Nome e marca

Recomendação: **Pode Comer?** — é literalmente a pergunta que a Ana faz no corredor, funciona como nome de app, de perfil no Instagram e de bordão em vídeo (“Antes de colocar no carrinho: Pode Comer?”).

Critérios usados: fácil de falar em voz alta (indicação boca a boca entre mães), sem termo médico que assuste, buscável na loja junto de “alergia” e “rótulo”, e com domínio .com.br viável.

| Nome | Ideia | Força | Risco |
| --- | --- | --- | --- |
| **Pode Comer?** | A pergunta da mãe no mercado | Emocional, memorável, ótimo para conteúdo | Genérico; checar INPI e lojas |
| Contém? | Brinca com o “CONTÉM” obrigatório do rótulo | Curto, inteligente, ligado à lei | Menos claro para quem não lê rótulos |
| Cesta Segura | O carrinho da família sem risco | Comunica grupo e segurança | Soa institucional |
| Rotulé | “Rótulo” + nome próprio, tipo assistente | Marca própria, fácil de registrar | Precisa de explicação no subtítulo |
| AlergiZero | Zero risco de alergênico | Descritivo para SEO de loja | Promessa de “zero” é juridicamente arriscada |

Nome na loja (ASO): **Pode Comer? Alergia e Rótulos** — o subtítulo carrega as palavras que as pessoas buscam.

**Status do nome:** “Pode Comer?” não tem registro no [INPI](https://busca.inpi.gov.br), mas o @ no Instagram já está em uso. Decisão: o app se chama **Pode Comer?** nas lojas, e redes sociais e landing page usam **@podecomerapp** (Instagram já criado; domínio sugerido: podecomerapp.com.br). O sufixo “app” é um padrão comum e não enfraquece a marca.

Próximos passos do nome: depositar o pedido de marca no INPI antes de divulgar (a busca vazia não garante ausência de marcas parecidas, como grafias “Podecomer” ou “Pode Comer Já”, então vale uma busca fonética), e reservar @podecomerapp também no TikTok, YouTube e Facebook no mesmo dia, para manter o nome igual em todas as redes.

Identidade sugerida: tom acolhedor e calmo (nada de vermelho dominante na marca, porque vermelho será reservado ao status NÃO CONSUMIR). Mascote ou símbolo simples: um carrinho com um check, ou um balão de pergunta em forma de folha.

## Pesquisa de mercado

Há espaço: o maior app brasileiro de rótulos foca em nutrição, e os apps de alergênicos com veredito pessoal são estrangeiros, sem base de produtos brasileiros e sem visão de família.

**Tamanho do público.** O Brasil não tem estatística oficial; a ASBAI estima que cerca de 8% das crianças até 2 anos e 2% dos adultos têm alergia alimentar ([fonte](https://abcdoabc.com.br/mitos-e-verdades-alergia-x-intolerancia-alimentar/)). A doença celíaca atinge cerca de 1% da população segundo a Fenacelbra, e o mercado de produtos para restrição alimentar saltou de R$ 519 milhões para R$ 1,86 bilhão de receita anual ([Sebrae](https://sebrae.com.br/Sebrae/Portal%20Sebrae/UFs/PI/Anexos/Restri%C3%A7%C3%A3o%20alimentar%20-%20ideias%20de%20neg%C3%B3cios%20para%20atender%20a%20esse%20nicho.pdf)). Somando intolerância à lactose (muito mais comum) e dietas por escolha, o público endereçável chega a dezenas de milhões de pessoas.

**Comprador real.** Quem paga é a mãe (ou pai) que gerencia a compra de casa, com 30–45 anos, classe B/C, ativa em grupos de WhatsApp e Instagram de APLV, celíacos e alergias. É um público com dor alta e comunidade organizada: a melhor combinação para crescer barato.

**Regulação que o app aproveita.** A RDC 26/2015 da Anvisa obriga declarar os alergênicos principais (soja, cereais com glúten, crustáceos, ovos, peixes, amendoim, leite, nozes e castanhas, látex) ([fonte](https://www.estudegratis.com.br/questao-de-concurso/938699)), e exige “Alérgicos: Pode conter” para contaminação cruzada ([Anvisa/Nutritotal](https://nutritotal.com.br/pro/wp-content/uploads/2014/06/351-AnvisaAlergenicos.pdf)). A RDC 136/2017 torna obrigatório o “Contém lactose” ([texto](https://faolex.fao.org/docs/pdf/bra163143.pdf)). Isso é ótimo para o motor: os rótulos brasileiros têm frases padronizadas, fáceis de detectar por OCR.

### Concorrentes

| App | Foco | Família/grupo | Base BR | Modelo |
| --- | --- | --- | --- | --- |
| [Desrotulando](https://apps.apple.com/BR/app/id1071285904) | Nota de saúde 0–100 | Não | Sim, +60 mil produtos | Freemium |
| [IngrediCheck](https://huntscreens.com/pt/products/ingredicheck) | Ingredientes por membro | Sim | Não | Freemium |
| [Food Allergy Scanner](https://apps.apple.com/app/id959328989) | Veredito Seguro/Arriscado/Perigoso | Não | Via Open Food Facts | Grátis |
| [Allergen Scan](https://mwm.ai/pt/apps/allergen-scan/1549145699) | Base curada AU/NZ | Não | Não | Pago |

O Desrotulando prova que o brasileiro paga por esse tipo de app: tem mais de 4 milhões de usuários declarados e versão premium ([App Store](https://apps.apple.com/us/app/-/id1071285904)), mas seu foco é “saudável ou não”, não “seguro para a Carol”.

**Posicionamento:** o único app brasileiro feito para a **segurança da família** (não para dieta), com veredito por pessoa e alternativas seguras para todos.

**Risco principal:** cobertura de produtos brasileiros no Open Food Facts é irregular. Por isso o cadastro colaborativo não é um extra: é o ativo mais valioso da empresa.

## Regras de negócio e motor de classificação

O coração do produto é um motor determinístico (sem IA decidindo o veredito): regras claras, auditáveis e testáveis, porque um erro aqui é um risco de saúde.

### Os quatro status

| Status | Quando | Cor | Ação no app |
| --- | --- | --- | --- |
| NÃO CONSUMIR | Ingredientes ou “CONTÉM” citam um alergênico da pessoa | Vermelho | Mostra o termo encontrado + alternativas seguras |
| ATENÇÃO | “Pode conter” / traços / ingrediente ambíguo (ex.: “aroma natural”) | Âmbar | Explica o motivo + alternativas seguras |
| SEGURO | Lista de ingredientes completa e nenhum alergênico do perfil encontrado | Verde | “Seguro para Ana, Carol e Enzo” |
| INCONCLUSIVO | Produto não encontrado ou sem lista de ingredientes | Cinza/azul | Convida a cadastrar com a câmera |

Precedência: NÃO CONSUMIR > ATENÇÃO > INCONCLUSIVO > SEGURO. O veredito do **grupo** é o pior status entre os membros selecionados; cada membro também tem o seu.

### Melhorias que proponho no fluxo original

1. **Separar Leite (APLV) de Lactose.** São condições diferentes: um produto “zero lactose” ainda tem proteína do leite. Para o Enzo (lactose) ele pode ser SEGURO; para uma criança com APLV, é NÃO CONSUMIR.
2. **Gravidade por pessoa (leve / grave-anafilaxia).** Para quem marcou “grave”, o “pode conter” vira NÃO CONSUMIR. A Ana com amendoim provavelmente marcaria grave.
3. **Regra do glúten brasileira.** “Pode conter trigo/centeio/cevada/aveia” é tratado como contém glúten, alinhado à orientação da Anvisa.
4. **“Quem vai comer?”** Antes ou depois do scan, a pessoa marca para quem é a compra (todos, só Carol…). Evita bloquear um produto que só a Ana vai comer.
5. **Data dos dados + “confira o rótulo”.** Receitas mudam. Todo veredito mostra a origem (Open Food Facts / base própria / cadastro da comunidade) e a data da última atualização.
6. **Botão “Isso está errado”.** Cada resultado permite reportar divergência com foto; isso alimenta a fila de revisão.

### Lista de alergênicos do multiselect (MVP)

Amendoim · Leite (APLV) · Lactose · Glúten · Trigo · Ovo · Soja · Peixe · Crustáceos · Castanhas e nozes · Gergelim · Sulfitos. Cada item tem um dicionário de sinônimos em português, por exemplo:

| Alergênico | Termos detectados (amostra) |
| --- | --- |
| Leite (APLV) | leite, caseína, caseinato, soro de leite, whey, lactoalbumina, manteiga, creme de leite, queijo |
| Glúten | trigo, centeio, cevada, aveia, malte, semolina, farinha de trigo, “contém glúten” |
| Amendoim | amendoim, pasta de amendoim, óleo de amendoim, paçoca |
| Ovo | ovo, albumina, ovoalbumina, gema, clara, lisozima |
| Lactose | “contém lactose”, leite e derivados (exceto quando “zero lactose” declarado) |

### Ordem de consulta do produto

1. Base própria **verificada** (mais confiável para produtos brasileiros).
2. Open Food Facts (campos `allergens_tags`, `traces_tags`, `ingredients_text_pt`).
3. Base própria **pendente** (cadastros da comunidade ainda não revisados — veredito com selo “não verificado”).
4. Nada encontrado ou sem ingredientes → INCONCLUSIVO + cadastro.

### Alternativas seguras

Quando o resultado é ATENÇÃO ou NÃO CONSUMIR: buscar produtos da mesma categoria (última categoria do Open Food Facts ou da base própria), filtrar os SEGUROS para todos os membros selecionados e ordenar por popularidade (número de scans no app). Mostrar até 5, com botão “Ver mais”. Se não houver alternativa, dizer isso com honestidade.

### Cadastro colaborativo (produto não encontrado)

Captura guiada pela **câmera ao vivo** em três etapas: código de barras (já lido), frente da embalagem, painel de ingredientes. O OCR roda no aparelho, o usuário confere o texto lido, e o motor devolve o veredito na hora com o selo “baseado no seu cadastro”. O produto fica público após revisão (manual no MVP; depois, confirmação por 2 usuários diferentes).

## Fluxo do app

O fluxo segue o que você desenhou, com uma diferença: o produto só vira INCONCLUSIVO depois de passar pela base própria e pelo Open Food Facts, e todo resultado leva de volta à câmera em um toque.

&#91;embedded content: fluxo do app · do cadastro ao próximo scan\]

O cadastro pela câmera devolve o veredito na hora para quem cadastrou; o produto só entra na base pública depois de revisado. Meu Perfil e Meu Grupo ficam nas abas da Home e alimentam o motor com as alergias de cada pessoa.

## Diretrizes de design UX/UI

O app será usado com uma mão, em pé, no corredor do mercado, muitas vezes com uma criança ao lado: cada decisão de design parte disso.

**Princípios**

- **Um polegar, um toque.** O botão VERIFICAR PRODUTO é grande, fica na metade inferior da tela e também abre por atalho (Quick Action no ícone do app e widget).
- **Veredito legível a 1 metro.** A tela de resultado ocupa o topo com cor + ícone + palavra (nunca só cor, por causa de daltonismo): ✓ SEGURO, ! ATENÇÃO, ✕ NÃO CONSUMIR, ? INCONCLUSIVO.
- **Por pessoa, em uma linha.** Abaixo do veredito, uma faixa com a foto de cada membro e um selo do seu status. Tocar abre o motivo (“Contém: soro de leite”).
- **Explicar sem assustar.** Linguagem simples, sem termos técnicos; o motivo sempre cita o trecho exato do rótulo.
- **Scanner contínuo.** Após um resultado, um botão “Próximo produto” volta direto à câmera; modo de scans em sequência é o que economiza as “horas” da Ana.
- **Feedback tátil.** Vibração diferente para seguro (curta) e não consumir (dupla), para quem não está olhando a tela.

**Paleta.** Marca em verde-água/azul calmo e creme; vermelho e âmbar reservados aos status. Contraste mínimo AA (4,5:1), textos a partir de 16 pt, suporte a fonte dinâmica e modo escuro.

**Telas do MVP (12):** Splash · Onboarding (3 cards) · Cadastro · Verificação de e-mail · Seleção de alergias (multiselect com chips e gravidade) · Home · Scanner · Resultado · Alternativas seguras · Cadastro de produto (3 passos de câmera + revisão do texto) · Meu Perfil · Meu Grupo (lista + formulário de membro).

**Navegação inferior:** Início · \[botão central Verificar\] · Meu Grupo · Meu Perfil. Histórico de scans entra na Home (últimos 10) — é barato e aumenta o uso recorrente.

**Cadastro mais leve (sugestão de UX).** Pedir sexo e data de nascimento no cadastro aumenta abandono e são dados pessoais que a LGPD manda justificar. Proposta: no cadastro, só nome, e-mail, senha e alergias; data de nascimento opcional no perfil (útil para identificar crianças e personalizar conteúdo), e sexo opcional ou removido. Login com Google/Apple reduz ainda mais o atrito.

## Stack técnica e arquitetura

Flutter é a escolha certa: um código para Android e iOS, ótimo suporte a câmera e ML Kit, e é a sua preferência, o que acelera tudo. O backend recomendado é Supabase, porque grupo familiar, alergias e produtos são dados relacionais e o Row Level Security resolve a privacidade sem servidor próprio.

| Camada | Escolha | Por quê | Alternativa |
| --- | --- | --- | --- |
| App | Flutter + Riverpod + go\_router | Um código, performance nativa de câmera | React Native + Expo |
| Leitura de código | mobile\_scanner | Grátis, rápido, EAN-13 dos produtos BR | ML Kit barcode direto |
| OCR | google\_mlkit\_text\_recognition | Roda offline no aparelho, custo zero | Google Cloud Vision (pago) |
| Backend | Supabase | SQL, Auth, Storage e RLS no plano grátis | Firebase |
| Dados de produto | Open Food Facts + base própria | Aberto e gratuito; base própria cobre o Brasil | Parcerias com indústria (fase 2) |
| Assinaturas | RevenueCat | Unifica Apple e Google, paywall e métricas | in\_app\_purchase puro |
| Builds iOS sem Mac | Codemagic | Cota gratuita de builds na nuvem | Mac próprio |

&#91;embedded content: arquitetura do MVP · app, Supabase e serviços externos\]

O veredito é calculado no celular, então funciona rápido e até com sinal fraco no mercado; o servidor só guarda perfis, grupo, produtos e cadastros. Evite IA generativa no veredito do MVP: custa por uso e é difícil de auditar em caso de erro.

## MVP de menor custo

O MVP cabe em cerca de R$ 1.000 de custo fixo no primeiro ano, porque toda a infraestrutura crítica tem plano gratuito e o OCR roda no próprio celular.

### Entra no MVP

- Cadastro com e-mail verificado + login Google/Apple, perfil e alergias com gravidade.
- Meu Grupo com **1 membro no plano grátis** (até 8 no Família).
- Scanner de código de barras com câmera ao vivo, consulta base própria → Open Food Facts.
- Motor dos 4 status, veredito por pessoa e do grupo.
- Alternativas seguras (até 5, mesma categoria).
- Cadastro colaborativo com captura guiada e OCR no aparelho; fila de revisão no painel do Supabase.
- Histórico dos últimos scans, botão “reportar erro”.
- Assinatura Família via RevenueCat.

### Fica para depois

Lista de compras, receitas, modo offline completo, busca por nome, IA generativa, painel administrativo próprio, versão web, outros países.

### Custos de lançamento (valores aproximados, conferir antes de contratar)

| Item | Custo | Observação |
| --- | --- | --- |
| Apple Developer Program | US$ 99/ano (≈ R$ 550) | Obrigatório para a App Store |
| Google Play Console | US$ 25 único (≈ R$ 140) | Pagamento único |
| Supabase (banco, auth, storage) | R$ 0 | Plano Free; Pro a US$ 25/mês quando crescer |
| Open Food Facts API | R$ 0 | Exige User-Agent identificado; respeitar limite de requisições |
| OCR + leitura de código (Google ML Kit) | R$ 0 | Roda no aparelho, sem custo por uso |
| RevenueCat (assinaturas) | R$ 0 | Gratuito até um patamar de receita mensal |
| E-mails transacionais (Resend/SMTP) | R$ 0 | Plano gratuito cobre o início |
| Domínio .com.br | ≈ R$ 40/ano | Site, política de privacidade, e-mail |
| Política de privacidade e termos | R$ 0–800 | Modelo + revisão jurídica pontual recomendada |
| **Total ano 1** | **≈ R$ 730 a R$ 1.530** | Sem contar seu tempo |

**Desenvolvimento:** com Flutter, Claude Code e os prompts deste documento, uma pessoa consegue entregar o MVP em 8–10 semanas de dedicação parcial. Mac é necessário para publicar no iOS (ou usar Codemagic, que tem cota gratuita de build na nuvem).

**Atalho para validar antes de codar tudo:** publicar uma landing page “Pode Comer? — lista de espera” e divulgar em 5 grupos de mães de alérgicos. Meta: 300 e-mails em 3 semanas. Se não chegar perto, ajustar a mensagem antes de investir mais.

## Monetização e projeção financeira

O modelo recomendado é freemium com o **grupo familiar como recurso pago**: o valor que a Ana sente (proteger Carol e Enzo de uma vez) é exatamente o que ela paga.

### Planos

| Plano | Preço | Inclui |
| --- | --- | --- |
| Grátis | R$ 0 | Titular + 1 membro, scans ilimitados, cadastro colaborativo, 1 alternativa segura por produto |
| Família | R$ 9,90/mês ou R$ 79,90/ano | Até 8 membros, todas as alternativas, histórico completo, gravidade por pessoa, sem anúncios |

Teste grátis de 7 dias no Família, oferecido logo após o primeiro scan com resultado ATENÇÃO ou NÃO CONSUMIR (momento de maior percepção de valor). Nunca bloquear o veredito de segurança do titular atrás de pagamento: isso destrói confiança e reviews.

**Taxa das lojas:** 15% em assinaturas (programas para pequenos desenvolvedores na Apple e taxa de assinatura no Google). Receita líquida média estimada: ≈ R$ 6,40 por assinante/mês, considerando mistura de planos mensal e anual.

### Cenários ao fim de 12 meses (estimativa, não garantia)

| Cenário | Downloads acumulados | Conversão paga | Assinantes ativos | Receita líquida/mês |
| --- | --- | --- | --- | --- |
| Conservador | 20 mil | 2% | 400 | ≈ R$ 2.560 |
| Base | 50 mil | 3% | 1.500 | ≈ R$ 9.600 |
| Otimista | 150 mil | 5% | 7.500 | ≈ R$ 48.000 |

Custo mensal até o cenário base fica abaixo de R$ 300 (Supabase Pro + e-mails), então o app se paga com cerca de 50 assinantes.

### Receitas complementares (fase 2)

- **Marcas e indústria:** selo “dados verificados pelo fabricante” e destaque **identificado como patrocinado** dentro da lista de alternativas, **somente entre produtos já SEGUROS**. Patrocínio nunca altera veredito.
- **Afiliados:** link para comprar a alternativa segura em e-commerces e supermercados online.
- **B2B2C:** licença para clínicas de alergia, nutricionistas e escolas acompanharem crianças alérgicas.
- **Relatórios agregados e anonimizados** para indústria (quais categorias faltam opções sem glúten, por exemplo), com base legal clara na LGPD.

### Como conseguir os primeiros 1.000 usuários sem gastar em anúncio

1. Série de vídeos curtos “Pode Comer?” no TikTok/Instagram: escanear produtos populares e mostrar surpresas (“esse biscoito ‘integral’ tem leite”).
2. Parcerias com perfis de mães de alérgicos, associações de celíacos e o movimento Põe no Rótulo; oferecer o Família grátis por 6 meses para quem divulgar.
3. Gamificação do cadastro: “Você já ajudou 37 famílias” e 1 mês de Família grátis a cada 20 produtos aprovados.
4. ASO: palavras-chave “alergia”, “glúten”, “lactose”, “APLV”, “rótulo”, “amendoim” no título, subtítulo e descrição.

## Aspectos legais e regras das lojas

Alergia é dado de saúde, ou seja, **dado pessoal sensível** na LGPD; tratar isso direito desde o início evita reprovação nas lojas e risco jurídico. Não sou advogado: vale uma revisão pontual com especialista em LGPD antes do lançamento.

- **Consentimento específico e destacado** para guardar alergias, separado do aceite dos termos, com finalidade clara: “usamos suas alergias só para calcular o veredito”.
- **Dados de crianças (membros do grupo):** o titular declara ser responsável legal e consente em nome deles. Coletar o mínimo; foto do membro opcional.
- **Minimização:** sexo e data de nascimento opcionais (ver Design). Nada de dados de saúde em analytics, URLs ou logs.
- **Segurança:** Row Level Security no Supabase (cada usuário só lê o próprio grupo), HTTPS, exclusão de conta pelo próprio app (exigência da Apple e do Google).
- **Isenção de responsabilidade visível:** no onboarding e no rodapé de cada resultado (“Confira sempre o rótulo; o app é apoio, não diagnóstico”). Evitar promessas como “100% seguro” ou “zero risco” na loja e no marketing.
- **Open Food Facts:** os dados estão sob licença ODbL, que exige atribuição e pode exigir compartilhar melhorias da base. Caminho mais simples e ético: exibir “Dados: Open Food Facts” e enviar os cadastros aprovados de volta ao Open Food Facts.
- **Fotos de rótulos enviadas por usuários:** termos devem dizer que o usuário cede a imagem para uso na base.
- **Lojas:** Apple e Google exigem formulário de privacidade (App Privacy / Data safety) declarando dados de saúde. Apps que dizem prevenir reações médicas podem ser classificados como app de saúde; posicionar como **ferramenta de informação de rótulos** ajuda na aprovação.
- **Login com Apple:** obrigatório no iOS se houver login com Google.

## Prompts para o Claude Design

Use na ordem: o prompt 1 cria a base visual que todos os outros reaproveitam. Depois de cada resultado, itere com comentários curtos (“aumente o veredito”, “menos texto”).

**Prompt 1 — Identidade e design system**

```text
Crie o design system de um app mobile brasileiro chamado "Pode Comer?", que escaneia o código de barras de alimentos e diz se o produto é seguro para cada pessoa da família com alergias alimentares.
Público: mães e pais de 30 a 45 anos, usando o celular com uma mão no corredor do mercado.
Tom: acolhedor, calmo, confiável; nada infantil nem hospitalar.
Entregue: logo simples (balão de pergunta + carrinho ou folha), paleta de marca em verde-água/azul calmo e creme, e 4 cores de status reservadas: SEGURO (verde), ATENÇÃO (âmbar), NÃO CONSUMIR (vermelho), INCONCLUSIVO (cinza-azulado). Cada status com ícone próprio (✓, !, ✕, ?) para não depender só da cor.
Tipografia legível (Nunito ou Inter), escala com texto base 16pt, contraste mínimo AA, versões claro e escuro.
Componentes: botão primário grande, chips de alergia selecionáveis, avatar com selo de status, card de produto, barra de navegação inferior com botão central de escanear, campos de formulário, banner de aviso.
```

**Prompt 2 — Onboarding e cadastro**

```text
Usando o design system do Pode Comer?, desenhe o fluxo de entrada em telas de celular (390x844):
1) Splash. 2) Três cards de onboarding: "Escaneie o código de barras", "Veja o resultado para cada pessoa da família", "Descubra alternativas seguras"; o último card traz o aviso "O app é um apoio. Confira sempre o rótulo".
3) Cadastro: nome, e-mail, senha, botões "Continuar com Google" e "Continuar com Apple".
4) Verificação de e-mail: ilustração, texto "Enviamos um link para seu e-mail", botões "Abrir e-mail" e "Reenviar".
5) Minhas alergias: multiselect em chips (Amendoim, Leite/APLV, Lactose, Glúten, Trigo, Ovo, Soja, Peixe, Crustáceos, Castanhas e nozes, Gergelim, Sulfitos); ao selecionar, aparece seletor de gravidade Leve / Grave. Checkbox separado de consentimento para dados de saúde.
6) Convite opcional: "Quem mais você protege?" com botão para adicionar membro ou pular.
Poucas palavras por tela, um botão principal por tela.
```

**Prompt 3 — Home e scanner**

```text
Desenhe a Home e o Scanner do Pode Comer?.
Home: saudação com nome, faixa com os avatares do grupo (Ana, Carol, Enzo) e suas alergias em chips pequenos, botão enorme "VERIFICAR PRODUTO" na metade inferior, lista "Últimos produtos" com miniatura, nome e selo de status. Navegação inferior: Início, botão central de escanear, Meu Grupo, Meu Perfil.
Scanner: câmera em tela cheia, moldura de leitura de código de barras com animação sutil, botão de lanterna, seletor "Para quem?" (Todos / membros) no topo, estado de carregamento "Consultando produto...".
```

**Prompt 4 — Resultado e alternativas**

```text
Desenhe a tela de resultado do Pode Comer? nos 4 estados, usando o produto fictício "Biscoito Recheado Chocolate 130g" e o grupo Ana (amendoim, grave), Carol (glúten) e Enzo (lactose).
Topo: veredito do grupo grande, legível a 1 metro (cor + ícone + palavra). Abaixo: linha com o avatar de cada pessoa e seu selo; tocar abre o motivo citando o trecho do rótulo (ex.: "Contém: farinha de trigo", "Pode conter amendoim").
Info da origem dos dados e data ("Open Food Facts · atualizado em 03/2026"), botão "Isso está errado?" e rodapé "Confira sempre o rótulo".
Estados ATENÇÃO e NÃO CONSUMIR mostram a seção "Alternativas seguras para todos" com 3 a 5 cards horizontais (foto, nome, marca, selo SEGURO).
Estado INCONCLUSIVO mostra "Ainda não conhecemos este produto" e botão "Cadastrar com a câmera (1 min)".
Botão fixo "Próximo produto" no rodapé.
```

**Prompt 5 — Cadastro de produto pela câmera**

```text
Desenhe o fluxo de cadastro colaborativo do Pode Comer? em 4 telas: indicador de progresso 1-2-3.
Passo 1: código de barras já lido (mostrar número) e câmera ao vivo com moldura "Enquadre a frente da embalagem", captura automática quando estável.
Passo 2: câmera ao vivo com moldura alta "Enquadre a lista de ingredientes", dica "Inclua as frases CONTÉM e PODE CONTER".
Passo 3: revisão: texto lido pelo OCR em campo editável, termos alergênicos destacados, campos nome e marca preenchidos.
Passo 4: resultado com selo "Baseado no seu cadastro · em revisão" e mensagem de agradecimento "Você acabou de ajudar outras famílias".
```

**Prompt 6 — Meu Perfil, Meu Grupo e assinatura**

```text
Desenhe para o Pode Comer?:
Meu Perfil: foto editável, nome, e-mail, alergias (chips + gravidade), data de nascimento opcional, plano atual, links Privacidade, Termos, Sair e Excluir conta.
Meu Grupo: lista de membros com avatar, nome, idade e chips de alergia; ações editar e excluir (com confirmação); botão "Adicionar membro". Formulário de membro: foto, nome, data de nascimento, sexo (Masculino, Feminino, Prefiro não informar), alergias com gravidade.
Paywall Família: aparece ao tentar adicionar o 2º membro; benefícios em 3 linhas, planos R$ 9,90/mês e R$ 79,90/ano (destaque "economize 33%"), "7 dias grátis", texto de cancelamento claro.
```

**Prompt 7 — Imagens para as lojas**

```text
Crie 6 screenshots verticais para App Store e Google Play do Pode Comer?, cada um com título curto acima do mockup do celular:
1) "Um scan. A família toda protegida." (resultado com 3 avatares)
2) "Veja o motivo, direto do rótulo" (NÃO CONSUMIR com trecho)
3) "Alternativas seguras na hora"
4) "Glúten, lactose, amendoim e mais 9 alergias"
5) "Não achou? Cadastre em 1 minuto"
6) "Feito para produtos do Brasil"
Fundo na cor da marca, texto grande, sem poluição.
```

**Prompt 8 — Landing page de lista de espera** (rode depois do Prompt 1, no mesmo projeto, para herdar o design system)

```text
Usando o design system do Pode Comer? que criamos (paleta, tipografia, componentes, ícones dos 4 status e o mockup da tela de Resultado), desenhe a landing page de lista de espera do app, em versão mobile (390px) e desktop (1440px). Endereço: podecomerapp.com.br. Objetivo único: capturar e-mails antes do lançamento.
Seções, nesta ordem:
1) Hero: título "Um scan. A família toda protegida.", subtítulo "Escaneie o código de barras e saiba na hora se o produto é seguro para cada pessoa da sua família.", mockup do celular com o resultado para Ana (amendoim), Carol (glúten) e Enzo (lactose), campo de e-mail + botão "Quero ser avisada no lançamento".
2) A dor: "Horas lendo rótulo por rótulo" em 3 cards curtos (letras miúdas, nomes técnicos como caseína e malte, alergias diferentes na mesma casa).
3) Como funciona em 3 passos com ícones: escaneie, veja o resultado por pessoa, descubra alternativas seguras.
4) Os 4 status (SEGURO, ATENÇÃO, NÃO CONSUMIR, INCONCLUSIVO) com cor, ícone e uma frase cada.
5) Alergias cobertas em chips: amendoim, leite (APLV), lactose, glúten, trigo, ovo, soja, peixe, crustáceos, castanhas, gergelim, sulfitos.
6) Confiança: regras baseadas na rotulagem da Anvisa, dados do Open Food Facts + base brasileira colaborativa, e o aviso "O app é um apoio: confira sempre o rótulo". Não usar "100% seguro" nem "zero risco".
7) FAQ em acordeão: Vai ser gratuito? Quando lança? Funciona no Android e iPhone? O que vocês fazem com meus dados?
8) CTA final com formulário: nome, e-mail, "Quantas pessoas com alergia ou intolerância na sua casa?" (1, 2, 3+), checkbox de consentimento LGPD com link para a política de privacidade.
9) Rodapé: @podecomerapp no Instagram, contato, política de privacidade.
Inclua o estado de sucesso após o cadastro: "Você está na lista!" + botão "Compartilhar no WhatsApp com outra mãe". Tom acolhedor, frases curtas, botão principal sempre visível no mobile.
```

## Prompts para o Claude Code

Execute um prompt por sessão, na ordem, e só avance quando os testes passarem. O prompt 0 cria o `CLAUDE.md`, que mantém o contexto entre sessões.

**Prompt 0 — Projeto e CLAUDE.md**

```text
Crie um projeto Flutter (versão estável atual) chamado pode_comer para Android e iOS.
Arquitetura: feature-first (lib/features/auth, onboarding, scanner, result, product_submission, profile, group, paywall; lib/core para engine, data, theme, router).
Pacotes: flutter_riverpod, go_router, supabase_flutter, mobile_scanner, camera, google_mlkit_text_recognition, http, freezed + json_serializable, purchases_flutter, image_picker (apenas para foto de perfil; produtos só pela câmera ao vivo), flutter_dotenv.
Idioma padrão pt-BR com intl. Tema claro/escuro com as cores: marca verde-água, SEGURO verde, ATENÇÃO âmbar, NÃO CONSUMIR vermelho, INCONCLUSIVO cinza-azulado.
Crie um CLAUDE.md descrevendo: objetivo do app, os 4 status e sua precedência (NÃO CONSUMIR > ATENÇÃO > INCONCLUSIVO > SEGURO), regra de nunca colocar dados de saúde em logs/analytics, convenções de código e como rodar testes.
```

**Prompt 1 — Banco de dados no Supabase**

```text
Gere migrations SQL para Supabase com:
- profiles (id = auth.users.id, name, birth_date nullable, sex enum masculino/feminino/nao_informar nullable, avatar_url, plan, health_consent_at).
- group_members (id, owner_id, name, birth_date, sex, avatar_url).
- allergens (code, name_pt) com seed: amendoim, leite_aplv, lactose, gluten, trigo, ovo, soja, peixe, crustaceos, castanhas, gergelim, sulfitos.
- person_allergens (person_type profile|member, person_id, allergen_code, severity leve|grave).
- products (barcode PK, name, brand, category, ingredients_text, allergens_contains text[], allergens_traces text[], source own|off, status verified|pending, image_urls, updated_at).
- product_submissions (id, barcode, user_id, front_image, ingredients_image, ocr_text, status pending|approved|rejected, created_at).
- scans (id, user_id, barcode, group_status, created_at) e reports (id, user_id, barcode, message, image_url).
Ative Row Level Security: cada usuário lê e escreve apenas os próprios perfis, membros, alergias, scans e submissões; products verified são leitura pública para autenticados. Buckets de storage avatars (privado por usuário) e submissions. Limite de 1 membro para plan = free via trigger.
```

**Prompt 2 — Motor de alergênicos (o mais importante)**

```text
Em lib/core/engine, implemente em Dart puro (sem Flutter) o AllergenEngine:
Entrada: Product (ingredientsText, allergensContains, allergensTraces, hasIngredients) e lista de Person (id, nome, alergias com severidade).
Saída: PersonVerdict por pessoa (status, motivos com o trecho exato encontrado) e GroupVerdict = pior status entre as pessoas selecionadas.
Regras:
- Sem produto ou sem ingredientes → INCONCLUSIVO.
- Alergênico em allergensContains ou termo do dicionário na lista de ingredientes → NÃO CONSUMIR.
- Em allergensTraces ou em frase "pode conter" → ATENÇÃO; se severidade grave → NÃO CONSUMIR.
- "Pode conter" trigo, centeio, cevada ou aveia conta como glúten.
- Lactose: "zero lactose", "sem lactose", "isento de lactose" anulam lactose, mas NÃO anulam leite_aplv.
- Normalize texto: minúsculas, sem acentos, sem pontuação duplicada; casar palavras inteiras.
Crie dicionário de sinônimos em português em JSON (leite: caseina, caseinato, soro de leite, whey, lactoalbumina, manteiga, creme de leite, queijo...; gluten: trigo, centeio, cevada, aveia, malte, semolina...; ovo: albumina, ovoalbumina, gema, clara, lisozima...; amendoim; soja: lecitina de soja...; etc.) e mapeamento das tags do Open Food Facts (en:milk, en:gluten, en:peanuts, en:eggs, en:soybeans, en:fish, en:crustaceans, en:nuts, en:sesame-seeds, en:sulphur-dioxide-and-sulphites).
Escreva pelo menos 40 testes unitários cobrindo o caso da família Ana (amendoim grave), Carol (glúten) e Enzo (lactose), falsos positivos ("manteiga de cacau" não é leite, "leite de coco" não é leite) e textos com OCR imperfeito.
```

**Prompt 3 — Consulta de produto**

```text
Implemente ProductRepository.lookup(barcode) com esta ordem:
1) tabela products status verified no Supabase;
2) API Open Food Facts v2 (GET https://world.openfoodfacts.org/api/v2/product/{barcode}?fields=product_name,brands,categories_tags,ingredients_text_pt,ingredients_text,allergens_tags,traces_tags,image_front_url,last_modified_t), com User-Agent "PodeComer/1.0 (contato@podecomerapp.com.br)", timeout de 5 s e cache local de 7 dias;
3) products status pending (marcar como não verificado);
4) não encontrado.
Converta tudo para o modelo Product, guardando a origem e a data. Trate erros de rede mostrando INCONCLUSIVO com opção de tentar de novo. Testes com respostas mockadas.
```

**Prompt 4 — Auth, onboarding, perfil e grupo**

```text
Implemente com Riverpod e go_router, seguindo as telas do Claude Design (anexadas):
- Cadastro por e-mail/senha com verificação de e-mail (deep link de confirmação), login Google e Apple, recuperação de senha.
- Rota protegida: sem e-mail verificado, só acessa a tela de verificação.
- Onboarding de alergias com multiselect + severidade e consentimento de dados de saúde gravado em health_consent_at.
- Meu Perfil: editar dados, foto (câmera ou galeria, upload em avatars), excluir conta (apaga dados e auth).
- Meu Grupo: listar, criar, editar e excluir membros com confirmação; ao exceder o limite do plano, abrir o paywall.
```

**Prompt 5 — Scanner, resultado e alternativas**

```text
Implemente:
- ScannerScreen com mobile_scanner (EAN-13, EAN-8, UPC-A), lanterna, seletor "Para quem?", vibração e debounce para não ler o mesmo código duas vezes.
- ResultScreen: veredito do grupo, linha de avatares com status, motivos por pessoa, origem e data dos dados, botão "Isso está errado?" (salva em reports), botão "Próximo produto". Salvar o scan em scans.
- SafeAlternatives para ATENÇÃO e NÃO CONSUMIR: buscar na base própria e no Open Food Facts (search com categories_tags da categoria mais específica e countries_tags=en:brazil), passar cada candidato pelo AllergenEngine e mostrar até 5 SEGUROS para todos os selecionados, ordenados por número de scans. Plano grátis mostra 1 alternativa.
Meça e garanta tempo total scan→veredito abaixo de 2 s com cache.
```

**Prompt 6 — Cadastro de produto pela câmera**

```text
Implemente o fluxo ProductSubmission com o pacote camera (preview ao vivo, sem galeria):
Passo 1 frente da embalagem, Passo 2 lista de ingredientes, com captura automática quando a imagem estiver estável e nítida.
Rode google_mlkit_text_recognition no aparelho sobre a foto dos ingredientes, mostre o texto em campo editável com os termos alergênicos destacados pelo AllergenEngine.
Ao confirmar: comprimir imagens, enviar para o bucket submissions, criar product_submissions e products status pending, e mostrar o veredito com o selo "Baseado no seu cadastro · em revisão".
Crie uma view SQL para eu revisar as submissões pendentes no painel do Supabase e uma função approve_submission(id) que muda o produto para verified.
```

**Prompt 7 — Assinatura e publicação**

```text
Integre RevenueCat (purchases_flutter) com o entitlement "familia" e produtos mensal e anual com 7 dias de teste. Sincronize o plano em profiles via webhook do RevenueCat para uma Edge Function do Supabase.
Prepare a publicação: ícones e splash (flutter_launcher_icons, flutter_native_splash), bundle id com.podecomer.app, permissões de câmera com textos em português, ofuscação no Android, build de release assinada, e um checklist de App Privacy (Apple) e Data safety (Google) declarando dados de saúde, e-mail e fotos.
```

**Prompt 8 — Publicar a landing page** (use antes dos outros, na fase de validação; anexe o design exportado do Claude Design)

```text
Implemente a landing page do Pode Comer? exatamente como o design anexado, como site estático em HTML + Tailwind (sem framework pesado), mobile-first, nota acima de 90 no Lighthouse.
Formulário de lista de espera grava no Supabase: crie a tabela waitlist (id, name, email único, allergy_people 1|2|3+, consent_at, utm_source, utm_medium, utm_campaign, created_at) com RLS permitindo apenas INSERT para o papel anon e nenhuma leitura pública. Capture os parâmetros UTM da URL.
Valide e-mail no front, trate e-mail duplicado com a mensagem "Você já está na lista", inclua campo honeypot contra spam e mostre o estado de sucesso com botão de compartilhar no WhatsApp (link wa.me com texto pronto e a URL da landing).
Crie também a página /privacidade com política simples em português: dados coletados, finalidade (avisar sobre o lançamento), direito de exclusão e contato contato@podecomerapp.com.br.
Adicione meta tags Open Graph (imagem 1200x630 com o título), favicon, e deixe pronto para deploy gratuito na Vercel com o domínio podecomerapp.com.br. Sem cookies de rastreamento; se quiser métricas, use uma solução sem cookies.
```

## Roadmap e próximos passos

O plano leva o app às lojas em cerca de 12 semanas; cada portão é um ponto de decisão para seguir, ajustar ou parar antes de gastar mais.

&#91;embedded content: roadmap · 4 fases e 3 portões\]

O portão de qualidade é o mais importante: testar o motor com 200 produtos reais da sua despensa e do mercado, comparando com o rótulo físico, antes de qualquer lançamento público.

### Para esta semana

- [x] Confirmar o nome no INPI e no Instagram (livre no INPI; redes como @podecomerapp)
- [x] Depositar a marca Pode Comer? no INPI e reservar @podecomerapp (Instagram, TikTok) e o domínio podecomerapp.com.br
- [ ] Publicar a landing de lista de espera e divulgar em 5 grupos de mães de alérgicos
- [ ] Conversar com 3 mães como a Ana e validar o veredito por pessoa e o preço de R$ 9,90
- [ ] Rodar o Prompt 1 do Claude Design (identidade e design system)
- [ ] Criar as contas Google Play Console, Apple Developer e Supabase
- [ ] Escanear 20 produtos da sua casa no site do Open Food Facts para medir a cobertura brasileira real
