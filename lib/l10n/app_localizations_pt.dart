// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Pode Comer?';

  @override
  String get authTitle => 'Entrar';

  @override
  String get onboardingTitle => 'Boas-vindas';

  @override
  String get scannerTitle => 'Verificar produto';

  @override
  String get resultTitle => 'Resultado';

  @override
  String get productSubmissionTitle => 'Cadastrar produto';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get groupTitle => 'Meu Grupo';

  @override
  String get paywallTitle => 'Plano Família';

  @override
  String get statusSafe => 'SEGURO';

  @override
  String get statusCaution => 'ATENÇÃO';

  @override
  String get statusDoNotConsume => 'NÃO CONSUMIR';

  @override
  String get statusInconclusive => 'INCONCLUSIVO';

  @override
  String get labelDisclaimer =>
      'O app é uma ferramenta de apoio. Confira sempre o rótulo da embalagem.';

  @override
  String get retry => 'Tentar de novo';

  @override
  String get lookupFailedMessage =>
      'Não conseguimos consultar este produto agora. Verifique sua conexão e tente de novo.';

  @override
  String get productNotFoundMessage => 'Ainda não conhecemos este produto.';

  @override
  String get unknownProductName => 'Produto sem nome';

  @override
  String get unverifiedBadge => 'Não verificado';

  @override
  String get originOwnVerified => 'base Pode Comer?';

  @override
  String get originOpenFoodFacts => 'Open Food Facts';

  @override
  String get originOwnPending => 'cadastro da comunidade';

  @override
  String dataSource(String source) {
    return 'Fonte: $source';
  }

  @override
  String dataUpdatedAt(DateTime date, String source) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Atualizado em $dateString · fonte: $source';
  }

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get genericError => 'Algo deu errado. Tente de novo.';

  @override
  String get networkError =>
      'Sem conexão. Verifique sua internet e tente de novo.';

  @override
  String get loading => 'Carregando…';

  @override
  String get tagline => 'Um scan. A família toda protegida.';

  @override
  String get supportDisclaimer => 'O app é um apoio. Confira sempre o rótulo.';

  @override
  String get signOut => 'Sair';

  @override
  String get allergenPeanut => 'Amendoim';

  @override
  String get allergenMilk => 'Leite (APLV)';

  @override
  String get allergenLactose => 'Lactose';

  @override
  String get allergenGluten => 'Glúten';

  @override
  String get allergenWheat => 'Trigo';

  @override
  String get allergenEgg => 'Ovo';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenFish => 'Peixe';

  @override
  String get allergenCrustaceans => 'Crustáceos';

  @override
  String get allergenTreeNuts => 'Castanhas e nozes';

  @override
  String get allergenSesame => 'Gergelim';

  @override
  String get allergenSulfites => 'Sulfitos';

  @override
  String get severityMild => 'Leve';

  @override
  String get severitySevere => 'Grave';

  @override
  String get severityQuestion => 'Qual a gravidade?';

  @override
  String get noAllergies => 'Nenhuma alergia cadastrada';

  @override
  String get sexMale => 'Masculino';

  @override
  String get sexFemale => 'Feminino';

  @override
  String get sexPreferNotToSay => 'Prefiro não informar';

  @override
  String ageYears(int age) {
    String _temp0 = intl.Intl.pluralLogic(
      age,
      locale: localeName,
      other: '$age anos',
      one: '1 ano',
      zero: 'menos de 1 ano',
    );
    return '$_temp0';
  }

  @override
  String get start => 'Começar';

  @override
  String get haveAccountSignIn => 'Já tem conta? Entrar';

  @override
  String get noAccountSignUp => 'Não tem conta? Criar conta';

  @override
  String get signUpTitle => 'Crie sua conta';

  @override
  String get signInTitle => 'Entrar';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get continueWithApple => 'Continuar com Apple';

  @override
  String get orWithEmail => 'ou com e-mail';

  @override
  String get nameLabel => 'Nome';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get passwordLabel => 'Senha';

  @override
  String get newPasswordLabel => 'Nova senha';

  @override
  String get confirmPasswordLabel => 'Repita a senha';

  @override
  String get createAccount => 'Criar conta';

  @override
  String get signInAction => 'Entrar';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get nameRequired => 'Informe seu nome.';

  @override
  String get emailInvalid => 'Informe um e-mail válido.';

  @override
  String get passwordTooShort => 'Use pelo menos 8 caracteres.';

  @override
  String get passwordsDontMatch => 'As senhas não são iguais.';

  @override
  String get authInvalidCredentials => 'E-mail ou senha incorretos.';

  @override
  String get authWeakPassword =>
      'Senha fraca. Use letras e números, com pelo menos 8 caracteres.';

  @override
  String get authRateLimited =>
      'Muitas tentativas. Aguarde um pouco e tente de novo.';

  @override
  String get authNotConfigured => 'O app ainda não está conectado ao servidor.';

  @override
  String get verifyEmailTitle => 'Confira seu e-mail';

  @override
  String get verifyEmailBody => 'Enviamos um link para seu e-mail';

  @override
  String get verifyEmailHint =>
      'Toque no link neste celular para entrar direto no app.';

  @override
  String get resend => 'Reenviar';

  @override
  String get resent => 'Link reenviado.';

  @override
  String resendIn(int seconds) {
    return 'Reenviar em $seconds s';
  }

  @override
  String get alreadyConfirmed => 'Já confirmei';

  @override
  String get useAnotherEmail => 'Usar outro e-mail';

  @override
  String get forgotPasswordTitle => 'Recuperar senha';

  @override
  String get forgotPasswordBody =>
      'Informe seu e-mail. Enviaremos um link para criar uma nova senha.';

  @override
  String get sendLink => 'Enviar link';

  @override
  String get resetLinkSent =>
      'Se houver uma conta com esse e-mail, você vai receber o link em instantes.';

  @override
  String get resetPasswordTitle => 'Nova senha';

  @override
  String get savePassword => 'Salvar senha';

  @override
  String get profileUnavailable => 'Não conseguimos carregar seu perfil.';

  @override
  String get onboardingStep1 => 'Passo 1 de 2';

  @override
  String get onboardingStep2 => 'Passo 2 de 2 · opcional';

  @override
  String get myAllergiesTitle => 'Minhas alergias';

  @override
  String get myAllergiesHint => 'Toque em tudo o que você evita.';

  @override
  String get healthConsent =>
      'Autorizo o uso dos meus dados de saúde (alergias) para personalizar os resultados.';

  @override
  String get howWeUseData => 'Como usamos seus dados';

  @override
  String get howWeUseDataBody =>
      'Suas alergias e as do seu grupo servem só para calcular o resultado de cada produto. Ficam protegidas na sua conta, não são vendidas nem usadas em anúncios, e você pode apagá-las a qualquer momento excluindo a conta.';

  @override
  String get consentRequired => 'Marque a autorização para continuar';

  @override
  String get whoElseTitle => 'Quem mais você protege?';

  @override
  String get whoElseBody =>
      'Filhos, parceiro, avós. Cada um com as suas alergias.';

  @override
  String get addMember => 'Adicionar membro';

  @override
  String get skipForNow => 'Pular por enquanto';

  @override
  String helloName(String name) {
    return 'Olá, $name';
  }

  @override
  String get homeQuestion => 'O que vamos conferir hoje?';

  @override
  String get myGroupLabel => 'Meu grupo';

  @override
  String get checkProduct => 'VERIFICAR PRODUTO';

  @override
  String get navHome => 'Início';

  @override
  String get navScan => 'Escanear';

  @override
  String youSuffix(String name) {
    return '$name (você)';
  }

  @override
  String get birthDateOptional => 'Data de nascimento · opcional';

  @override
  String get birthDateLabel => 'Data de nascimento';

  @override
  String get birthDateHelper => 'Usamos para mostrar a idade no grupo.';

  @override
  String get addAction => 'Adicionar';

  @override
  String get currentPlan => 'Plano atual';

  @override
  String get planFree => 'Gratuito';

  @override
  String get planFamily => 'Família';

  @override
  String get planFreeSummary => 'Você + 1 membro';

  @override
  String get planFamilySummary => 'Membros ilimitados';

  @override
  String get knowFamilyPlan => 'Conhecer o plano Família';

  @override
  String get saveChanges => 'Salvar alterações';

  @override
  String get saved => 'Alterações salvas.';

  @override
  String get changePhoto => 'Alterar foto';

  @override
  String get takePhoto => 'Tirar foto';

  @override
  String get chooseFromGallery => 'Escolher da galeria';

  @override
  String get photoOptional => 'Foto opcional';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get deleteAccountTitle => 'Excluir sua conta?';

  @override
  String get deleteAccountBody =>
      'Seu perfil, seu grupo, as alergias de todos, o histórico e as fotos serão apagados. Não dá para desfazer.';

  @override
  String get deleteAccountConfirm => 'Excluir conta';

  @override
  String get deleteAccountFailed =>
      'Não conseguimos excluir a conta. Tente de novo.';

  @override
  String peopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pessoas',
      one: '1 pessoa',
    );
    return '$_temp0';
  }

  @override
  String get accountOwner => 'Titular da conta';

  @override
  String get freePlanBanner => 'Plano Gratuito: você + 1 membro.';

  @override
  String get seeFamilyPlan => 'Ver plano Família';

  @override
  String get newMemberTitle => 'Novo membro';

  @override
  String get editMemberTitle => 'Editar membro';

  @override
  String get sexLabel => 'Sexo';

  @override
  String memberAllergies(String name) {
    return 'Alergias de $name';
  }

  @override
  String get memberAllergiesDefault => 'Alergias';

  @override
  String deleteMemberTitle(String name) {
    return 'Excluir $name do grupo?';
  }

  @override
  String get deleteMemberBody =>
      'As alergias e o histórico dessa pessoa serão apagados. Não dá para desfazer.';

  @override
  String get removeFromGroup => 'Excluir do grupo';

  @override
  String get paywallHeadline => 'Proteja toda a família';

  @override
  String get paywallFreeIncludes => 'O plano Gratuito inclui você e 1 membro.';

  @override
  String get paywallBenefit1 => 'Membros ilimitados, cada um com suas alergias';

  @override
  String get paywallBenefit2 => 'Um escaneamento, resultado para todos';

  @override
  String get paywallBenefit3 => 'Alternativas seguras para o grupo inteiro';

  @override
  String get planAnnual => 'Anual';

  @override
  String get planMonthly => 'Mensal';

  @override
  String get planMonthlyHint => 'pague mês a mês';

  @override
  String get restorePurchase => 'Restaurar compra';

  @override
  String get scanHint => 'Aponte para o código de barras';

  @override
  String get forWhom => 'Para quem?';

  @override
  String get torchOn => 'Ligar lanterna';

  @override
  String get torchOff => 'Desligar lanterna';

  @override
  String get cameraUnavailable =>
      'Não conseguimos usar a câmera. Permita o acesso nas configurações do celular.';

  @override
  String get closeScanner => 'Fechar';

  @override
  String get keepOnePerson => 'Selecione pelo menos uma pessoa.';

  @override
  String verdictFor(String names) {
    return 'para $names';
  }

  @override
  String namesAnd(String first, String last) {
    return '$first e $last';
  }

  @override
  String get tapPersonHint => 'Toque em uma pessoa para ver o motivo';

  @override
  String get whyTitle => 'Por quê?';

  @override
  String reasonContainsText(String allergen, String excerpt) {
    return '$allergen: contém “$excerpt”';
  }

  @override
  String reasonContainsDeclared(String allergen) {
    return '$allergen: declarado como presente pelo fabricante';
  }

  @override
  String reasonTracesText(String allergen, String excerpt) {
    return '$allergen: “$excerpt”';
  }

  @override
  String reasonTracesDeclared(String allergen) {
    return '$allergen: pode conter, segundo o fabricante';
  }

  @override
  String reasonAmbiguous(String allergen, String excerpt) {
    return '$allergen: ingrediente que pode conter, “$excerpt”';
  }

  @override
  String get reasonSevereNote => 'alergia grave: traços também contam';

  @override
  String get reasonGlutenNote =>
      'traços de trigo, centeio, cevada ou aveia contam como glúten';

  @override
  String get reasonApproximate => 'leitura aproximada do rótulo';

  @override
  String get reasonNoIngredients => 'Sem lista de ingredientes confiável';

  @override
  String get reasonNotFound => 'Produto não encontrado';

  @override
  String reasonSafe(String name) {
    return 'Nenhum alergênico de $name encontrado';
  }

  @override
  String get reportWrong => 'Isso está errado?';

  @override
  String get reportTitle => 'O que está errado?';

  @override
  String get reportHint => 'Ex.: a receita mudou, agora contém leite';

  @override
  String get reportSend => 'Enviar';

  @override
  String get reportThanks => 'Obrigado! Vamos revisar.';

  @override
  String get reportRequired => 'Conte rapidamente o que está errado.';

  @override
  String get nextProduct => 'Próximo produto';

  @override
  String get registerProduct => 'Cadastrar produto';

  @override
  String alternativesTitle(String names) {
    return 'Alternativas seguras para $names';
  }

  @override
  String get alternativesNone =>
      'Não encontramos alternativas seguras nesta categoria. Confira os rótulos no mercado.';

  @override
  String get alternativesFailed => 'Não conseguimos buscar alternativas agora.';

  @override
  String get alternativesMore => 'Veja até 5 alternativas no plano Família';

  @override
  String get alternativesSearching => 'Procurando alternativas…';

  @override
  String get submissionStepFront => 'Passo 1 de 2 · Frente da embalagem';

  @override
  String get submissionStepIngredients =>
      'Passo 2 de 2 · Lista de ingredientes';

  @override
  String get submissionFrontHint =>
      'Enquadre a frente do produto, com nome e marca.';

  @override
  String get submissionIngredientsHint =>
      'Enquadre toda a lista de ingredientes e o quadro de alérgicos.';

  @override
  String get holdSteady => 'Segure firme…';

  @override
  String get autoCaptureHint =>
      'A foto é tirada sozinha quando a imagem fica nítida.';

  @override
  String get takePhotoNow => 'Tirar foto';

  @override
  String get readingIngredients => 'Lendo os ingredientes…';

  @override
  String get reviewTitle => 'Confira os ingredientes';

  @override
  String get reviewHint =>
      'Corrija o que a leitura errou. Termos alergênicos aparecem destacados.';

  @override
  String get ocrEmpty =>
      'Não conseguimos ler o texto. Digite os ingredientes ou refaça a foto.';

  @override
  String get ingredientsLabel => 'Ingredientes';

  @override
  String get ingredientsRequired => 'Informe a lista de ingredientes.';

  @override
  String get productNameOptional => 'Nome do produto · opcional';

  @override
  String get brandOptional => 'Marca · opcional';

  @override
  String get retakeIngredients => 'Refazer foto dos ingredientes';

  @override
  String get legendContains => 'Contém';

  @override
  String get legendMayContain => 'Pode conter / ambíguo';

  @override
  String get sendSubmission => 'Enviar cadastro';

  @override
  String get sendingSubmission => 'Enviando…';

  @override
  String get submissionFailed =>
      'Não conseguimos enviar o cadastro. Verifique sua conexão e tente de novo.';

  @override
  String get submissionRateLimited =>
      'Você já enviou muitos cadastros hoje. Tente de novo amanhã.';

  @override
  String get submissionSeal => 'Baseado no seu cadastro · em revisão';

  @override
  String get submissionThanksTitle => 'Você acabou de ajudar outras famílias';

  @override
  String get submissionThanksBody =>
      'Depois da revisão, o produto fica disponível para todos.';

  @override
  String planSave(int percent) {
    return 'economize $percent%';
  }

  @override
  String pricePerYear(String price) {
    return '$price/ano';
  }

  @override
  String pricePerMonth(String price) {
    return '$price/mês';
  }

  @override
  String freeTrialDays(int days) {
    return '$days dias grátis';
  }

  @override
  String startFreeTrialDays(int days) {
    return 'Começar $days dias grátis';
  }

  @override
  String get subscribe => 'Assinar';

  @override
  String get periodYear => 'ano';

  @override
  String get periodMonth => 'mês';

  @override
  String get storeSubscriptionsIos => 'Ajustes › seu nome › Assinaturas';

  @override
  String get storeSubscriptionsAndroid =>
      'Play Store › Pagamentos e assinaturas › Assinaturas';

  @override
  String cancellationTrial(
    int days,
    String price,
    String period,
    String store,
  ) {
    return 'Hoje você paga R\$ 0. Depois de $days dias, $price por $period, com renovação automática. Cancele quando quiser em $store, até 24 h antes do fim do teste, e nada será cobrado.';
  }

  @override
  String cancellationNoTrial(String price, String period, String store) {
    return '$price por $period, com renovação automática. Cancele quando quiser em $store, até 24 h antes da renovação.';
  }

  @override
  String get plansUnavailable => 'Não conseguimos carregar os planos agora.';

  @override
  String get purchaseFailed =>
      'A compra não foi concluída. Nada foi cobrado. Tente de novo.';

  @override
  String get familyActive =>
      'Plano Família ativo! Agora você pode adicionar todo o grupo.';

  @override
  String get familyActivating =>
      'Assinatura confirmada. A liberação pode levar alguns instantes.';

  @override
  String get nothingToRestore =>
      'Nenhuma assinatura Família encontrada nesta conta da loja.';

  @override
  String get privacyPolicy => 'Privacidade';

  @override
  String get termsOfUse => 'Termos de uso';
}
