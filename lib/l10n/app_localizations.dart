import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('pt')];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Pode Comer?'**
  String get appTitle;

  /// No description provided for @authTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get authTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In pt, this message translates to:
  /// **'Boas-vindas'**
  String get onboardingTitle;

  /// No description provided for @scannerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Verificar produto'**
  String get scannerTitle;

  /// No description provided for @resultTitle.
  ///
  /// In pt, this message translates to:
  /// **'Resultado'**
  String get resultTitle;

  /// No description provided for @productSubmissionTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar produto'**
  String get productSubmissionTitle;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu Perfil'**
  String get profileTitle;

  /// No description provided for @groupTitle.
  ///
  /// In pt, this message translates to:
  /// **'Meu Grupo'**
  String get groupTitle;

  /// No description provided for @paywallTitle.
  ///
  /// In pt, this message translates to:
  /// **'Plano Família'**
  String get paywallTitle;

  /// No description provided for @statusSafe.
  ///
  /// In pt, this message translates to:
  /// **'SEGURO'**
  String get statusSafe;

  /// No description provided for @statusCaution.
  ///
  /// In pt, this message translates to:
  /// **'ATENÇÃO'**
  String get statusCaution;

  /// No description provided for @statusDoNotConsume.
  ///
  /// In pt, this message translates to:
  /// **'NÃO CONSUMIR'**
  String get statusDoNotConsume;

  /// No description provided for @statusInconclusive.
  ///
  /// In pt, this message translates to:
  /// **'INCONCLUSIVO'**
  String get statusInconclusive;

  /// No description provided for @labelDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'O app é uma ferramenta de apoio. Confira sempre o rótulo da embalagem.'**
  String get labelDisclaimer;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar de novo'**
  String get retry;

  /// No description provided for @lookupFailedMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos consultar este produto agora. Verifique sua conexão e tente de novo.'**
  String get lookupFailedMessage;

  /// No description provided for @productNotFoundMessage.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não conhecemos este produto.'**
  String get productNotFoundMessage;

  /// No description provided for @unknownProductName.
  ///
  /// In pt, this message translates to:
  /// **'Produto sem nome'**
  String get unknownProductName;

  /// No description provided for @unverifiedBadge.
  ///
  /// In pt, this message translates to:
  /// **'Não verificado'**
  String get unverifiedBadge;

  /// No description provided for @originOwnVerified.
  ///
  /// In pt, this message translates to:
  /// **'base Pode Comer?'**
  String get originOwnVerified;

  /// No description provided for @originOpenFoodFacts.
  ///
  /// In pt, this message translates to:
  /// **'Open Food Facts'**
  String get originOpenFoodFacts;

  /// No description provided for @originOwnPending.
  ///
  /// In pt, this message translates to:
  /// **'cadastro da comunidade'**
  String get originOwnPending;

  /// No description provided for @dataSource.
  ///
  /// In pt, this message translates to:
  /// **'Fonte: {source}'**
  String dataSource(String source);

  /// No description provided for @dataUpdatedAt.
  ///
  /// In pt, this message translates to:
  /// **'Atualizado em {date} · fonte: {source}'**
  String dataUpdatedAt(DateTime date, String source);

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In pt, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @continueLabel.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueLabel;

  /// No description provided for @genericError.
  ///
  /// In pt, this message translates to:
  /// **'Algo deu errado. Tente de novo.'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In pt, this message translates to:
  /// **'Sem conexão. Verifique sua internet e tente de novo.'**
  String get networkError;

  /// No description provided for @loading.
  ///
  /// In pt, this message translates to:
  /// **'Carregando…'**
  String get loading;

  /// No description provided for @tagline.
  ///
  /// In pt, this message translates to:
  /// **'Um scan. A família toda protegida.'**
  String get tagline;

  /// No description provided for @supportDisclaimer.
  ///
  /// In pt, this message translates to:
  /// **'O app é um apoio. Confira sempre o rótulo.'**
  String get supportDisclaimer;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @allergenPeanut.
  ///
  /// In pt, this message translates to:
  /// **'Amendoim'**
  String get allergenPeanut;

  /// No description provided for @allergenMilk.
  ///
  /// In pt, this message translates to:
  /// **'Leite (APLV)'**
  String get allergenMilk;

  /// No description provided for @allergenLactose.
  ///
  /// In pt, this message translates to:
  /// **'Lactose'**
  String get allergenLactose;

  /// No description provided for @allergenGluten.
  ///
  /// In pt, this message translates to:
  /// **'Glúten'**
  String get allergenGluten;

  /// No description provided for @allergenWheat.
  ///
  /// In pt, this message translates to:
  /// **'Trigo'**
  String get allergenWheat;

  /// No description provided for @allergenEgg.
  ///
  /// In pt, this message translates to:
  /// **'Ovo'**
  String get allergenEgg;

  /// No description provided for @allergenSoy.
  ///
  /// In pt, this message translates to:
  /// **'Soja'**
  String get allergenSoy;

  /// No description provided for @allergenFish.
  ///
  /// In pt, this message translates to:
  /// **'Peixe'**
  String get allergenFish;

  /// No description provided for @allergenCrustaceans.
  ///
  /// In pt, this message translates to:
  /// **'Crustáceos'**
  String get allergenCrustaceans;

  /// No description provided for @allergenTreeNuts.
  ///
  /// In pt, this message translates to:
  /// **'Castanhas e nozes'**
  String get allergenTreeNuts;

  /// No description provided for @allergenSesame.
  ///
  /// In pt, this message translates to:
  /// **'Gergelim'**
  String get allergenSesame;

  /// No description provided for @allergenSulfites.
  ///
  /// In pt, this message translates to:
  /// **'Sulfitos'**
  String get allergenSulfites;

  /// No description provided for @severityMild.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get severityMild;

  /// No description provided for @severitySevere.
  ///
  /// In pt, this message translates to:
  /// **'Grave'**
  String get severitySevere;

  /// No description provided for @severityQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Qual a gravidade?'**
  String get severityQuestion;

  /// No description provided for @noAllergies.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma alergia cadastrada'**
  String get noAllergies;

  /// No description provided for @sexMale.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get sexMale;

  /// No description provided for @sexFemale.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get sexFemale;

  /// No description provided for @sexPreferNotToSay.
  ///
  /// In pt, this message translates to:
  /// **'Prefiro não informar'**
  String get sexPreferNotToSay;

  /// No description provided for @ageYears.
  ///
  /// In pt, this message translates to:
  /// **'{age, plural, =0{menos de 1 ano} =1{1 ano} other{{age} anos}}'**
  String ageYears(int age);

  /// No description provided for @start.
  ///
  /// In pt, this message translates to:
  /// **'Começar'**
  String get start;

  /// No description provided for @haveAccountSignIn.
  ///
  /// In pt, this message translates to:
  /// **'Já tem conta? Entrar'**
  String get haveAccountSignIn;

  /// No description provided for @noAccountSignUp.
  ///
  /// In pt, this message translates to:
  /// **'Não tem conta? Criar conta'**
  String get noAccountSignUp;

  /// No description provided for @signUpTitle.
  ///
  /// In pt, this message translates to:
  /// **'Crie sua conta'**
  String get signUpTitle;

  /// No description provided for @signInTitle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signInTitle;

  /// No description provided for @continueWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In pt, this message translates to:
  /// **'Continuar com Apple'**
  String get continueWithApple;

  /// No description provided for @orWithEmail.
  ///
  /// In pt, this message translates to:
  /// **'ou com e-mail'**
  String get orWithEmail;

  /// No description provided for @nameLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordLabel;

  /// No description provided for @newPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get newPasswordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In pt, this message translates to:
  /// **'Repita a senha'**
  String get confirmPasswordLabel;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar conta'**
  String get createAccount;

  /// No description provided for @signInAction.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get signInAction;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get forgotPassword;

  /// No description provided for @nameRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu nome.'**
  String get nameRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get emailInvalid;

  /// No description provided for @passwordTooShort.
  ///
  /// In pt, this message translates to:
  /// **'Use pelo menos 8 caracteres.'**
  String get passwordTooShort;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não são iguais.'**
  String get passwordsDontMatch;

  /// No description provided for @authInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get authInvalidCredentials;

  /// No description provided for @authWeakPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha fraca. Use letras e números, com pelo menos 8 caracteres.'**
  String get authWeakPassword;

  /// No description provided for @authRateLimited.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Aguarde um pouco e tente de novo.'**
  String get authRateLimited;

  /// No description provided for @authNotConfigured.
  ///
  /// In pt, this message translates to:
  /// **'O app ainda não está conectado ao servidor.'**
  String get authNotConfigured;

  /// No description provided for @verifyEmailTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confira seu e-mail'**
  String get verifyEmailTitle;

  /// No description provided for @verifyEmailBody.
  ///
  /// In pt, this message translates to:
  /// **'Enviamos um link para seu e-mail'**
  String get verifyEmailBody;

  /// No description provided for @verifyEmailHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque no link neste celular para entrar direto no app.'**
  String get verifyEmailHint;

  /// No description provided for @resend.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar'**
  String get resend;

  /// No description provided for @resent.
  ///
  /// In pt, this message translates to:
  /// **'Link reenviado.'**
  String get resent;

  /// No description provided for @resendIn.
  ///
  /// In pt, this message translates to:
  /// **'Reenviar em {seconds} s'**
  String resendIn(int seconds);

  /// No description provided for @alreadyConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Já confirmei'**
  String get alreadyConfirmed;

  /// No description provided for @useAnotherEmail.
  ///
  /// In pt, this message translates to:
  /// **'Usar outro e-mail'**
  String get useAnotherEmail;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordBody.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail. Enviaremos um link para criar uma nova senha.'**
  String get forgotPasswordBody;

  /// No description provided for @sendLink.
  ///
  /// In pt, this message translates to:
  /// **'Enviar link'**
  String get sendLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In pt, this message translates to:
  /// **'Se houver uma conta com esse e-mail, você vai receber o link em instantes.'**
  String get resetLinkSent;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get resetPasswordTitle;

  /// No description provided for @savePassword.
  ///
  /// In pt, this message translates to:
  /// **'Salvar senha'**
  String get savePassword;

  /// No description provided for @profileUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar seu perfil.'**
  String get profileUnavailable;

  /// No description provided for @onboardingStep1.
  ///
  /// In pt, this message translates to:
  /// **'Passo 1 de 2'**
  String get onboardingStep1;

  /// No description provided for @onboardingStep2.
  ///
  /// In pt, this message translates to:
  /// **'Passo 2 de 2 · opcional'**
  String get onboardingStep2;

  /// No description provided for @myAllergiesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Minhas alergias'**
  String get myAllergiesTitle;

  /// No description provided for @myAllergiesHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em tudo o que você evita.'**
  String get myAllergiesHint;

  /// No description provided for @healthConsent.
  ///
  /// In pt, this message translates to:
  /// **'Autorizo o uso dos meus dados de saúde (alergias) para personalizar os resultados.'**
  String get healthConsent;

  /// No description provided for @howWeUseData.
  ///
  /// In pt, this message translates to:
  /// **'Como usamos seus dados'**
  String get howWeUseData;

  /// No description provided for @howWeUseDataBody.
  ///
  /// In pt, this message translates to:
  /// **'Suas alergias e as do seu grupo servem só para calcular o resultado de cada produto. Ficam protegidas na sua conta, não são vendidas nem usadas em anúncios, e você pode apagá-las a qualquer momento excluindo a conta.'**
  String get howWeUseDataBody;

  /// No description provided for @consentRequired.
  ///
  /// In pt, this message translates to:
  /// **'Marque a autorização para continuar'**
  String get consentRequired;

  /// No description provided for @whoElseTitle.
  ///
  /// In pt, this message translates to:
  /// **'Quem mais você protege?'**
  String get whoElseTitle;

  /// No description provided for @whoElseBody.
  ///
  /// In pt, this message translates to:
  /// **'Filhos, parceiro, avós. Cada um com as suas alergias.'**
  String get whoElseBody;

  /// No description provided for @addMember.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar membro'**
  String get addMember;

  /// No description provided for @skipForNow.
  ///
  /// In pt, this message translates to:
  /// **'Pular por enquanto'**
  String get skipForNow;

  /// No description provided for @helloName.
  ///
  /// In pt, this message translates to:
  /// **'Olá, {name}'**
  String helloName(String name);

  /// No description provided for @homeQuestion.
  ///
  /// In pt, this message translates to:
  /// **'O que vamos conferir hoje?'**
  String get homeQuestion;

  /// No description provided for @myGroupLabel.
  ///
  /// In pt, this message translates to:
  /// **'Meu grupo'**
  String get myGroupLabel;

  /// No description provided for @checkProduct.
  ///
  /// In pt, this message translates to:
  /// **'VERIFICAR PRODUTO'**
  String get checkProduct;

  /// No description provided for @navHome.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get navHome;

  /// No description provided for @navScan.
  ///
  /// In pt, this message translates to:
  /// **'Escanear'**
  String get navScan;

  /// No description provided for @youSuffix.
  ///
  /// In pt, this message translates to:
  /// **'{name} (você)'**
  String youSuffix(String name);

  /// No description provided for @birthDateOptional.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento · opcional'**
  String get birthDateOptional;

  /// No description provided for @birthDateLabel.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento'**
  String get birthDateLabel;

  /// No description provided for @birthDateHelper.
  ///
  /// In pt, this message translates to:
  /// **'Usamos para mostrar a idade no grupo.'**
  String get birthDateHelper;

  /// No description provided for @addAction.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get addAction;

  /// No description provided for @currentPlan.
  ///
  /// In pt, this message translates to:
  /// **'Plano atual'**
  String get currentPlan;

  /// No description provided for @planFree.
  ///
  /// In pt, this message translates to:
  /// **'Gratuito'**
  String get planFree;

  /// No description provided for @planFamily.
  ///
  /// In pt, this message translates to:
  /// **'Família'**
  String get planFamily;

  /// No description provided for @planFreeSummary.
  ///
  /// In pt, this message translates to:
  /// **'Você + 1 membro'**
  String get planFreeSummary;

  /// No description provided for @planFamilySummary.
  ///
  /// In pt, this message translates to:
  /// **'Membros ilimitados'**
  String get planFamilySummary;

  /// No description provided for @knowFamilyPlan.
  ///
  /// In pt, this message translates to:
  /// **'Conhecer o plano Família'**
  String get knowFamilyPlan;

  /// No description provided for @saveChanges.
  ///
  /// In pt, this message translates to:
  /// **'Salvar alterações'**
  String get saveChanges;

  /// No description provided for @saved.
  ///
  /// In pt, this message translates to:
  /// **'Alterações salvas.'**
  String get saved;

  /// No description provided for @changePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Alterar foto'**
  String get changePhoto;

  /// No description provided for @takePhoto.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In pt, this message translates to:
  /// **'Escolher da galeria'**
  String get chooseFromGallery;

  /// No description provided for @photoOptional.
  ///
  /// In pt, this message translates to:
  /// **'Foto opcional'**
  String get photoOptional;

  /// No description provided for @deleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir sua conta?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountBody.
  ///
  /// In pt, this message translates to:
  /// **'Seu perfil, seu grupo, as alergias de todos, o histórico e as fotos serão apagados. Não dá para desfazer.'**
  String get deleteAccountBody;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In pt, this message translates to:
  /// **'Excluir conta'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos excluir a conta. Tente de novo.'**
  String get deleteAccountFailed;

  /// No description provided for @peopleCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 pessoa} other{{count} pessoas}}'**
  String peopleCount(int count);

  /// No description provided for @accountOwner.
  ///
  /// In pt, this message translates to:
  /// **'Titular da conta'**
  String get accountOwner;

  /// No description provided for @freePlanBanner.
  ///
  /// In pt, this message translates to:
  /// **'Plano Gratuito: você + 1 membro.'**
  String get freePlanBanner;

  /// No description provided for @seeFamilyPlan.
  ///
  /// In pt, this message translates to:
  /// **'Ver plano Família'**
  String get seeFamilyPlan;

  /// No description provided for @newMemberTitle.
  ///
  /// In pt, this message translates to:
  /// **'Novo membro'**
  String get newMemberTitle;

  /// No description provided for @editMemberTitle.
  ///
  /// In pt, this message translates to:
  /// **'Editar membro'**
  String get editMemberTitle;

  /// No description provided for @sexLabel.
  ///
  /// In pt, this message translates to:
  /// **'Sexo'**
  String get sexLabel;

  /// No description provided for @memberAllergies.
  ///
  /// In pt, this message translates to:
  /// **'Alergias de {name}'**
  String memberAllergies(String name);

  /// No description provided for @memberAllergiesDefault.
  ///
  /// In pt, this message translates to:
  /// **'Alergias'**
  String get memberAllergiesDefault;

  /// No description provided for @deleteMemberTitle.
  ///
  /// In pt, this message translates to:
  /// **'Excluir {name} do grupo?'**
  String deleteMemberTitle(String name);

  /// No description provided for @deleteMemberBody.
  ///
  /// In pt, this message translates to:
  /// **'As alergias e o histórico dessa pessoa serão apagados. Não dá para desfazer.'**
  String get deleteMemberBody;

  /// No description provided for @removeFromGroup.
  ///
  /// In pt, this message translates to:
  /// **'Excluir do grupo'**
  String get removeFromGroup;

  /// No description provided for @paywallHeadline.
  ///
  /// In pt, this message translates to:
  /// **'Proteja toda a família'**
  String get paywallHeadline;

  /// No description provided for @paywallFreeIncludes.
  ///
  /// In pt, this message translates to:
  /// **'O plano Gratuito inclui você e 1 membro.'**
  String get paywallFreeIncludes;

  /// No description provided for @paywallBenefit1.
  ///
  /// In pt, this message translates to:
  /// **'Membros ilimitados, cada um com suas alergias'**
  String get paywallBenefit1;

  /// No description provided for @paywallBenefit2.
  ///
  /// In pt, this message translates to:
  /// **'Um escaneamento, resultado para todos'**
  String get paywallBenefit2;

  /// No description provided for @paywallBenefit3.
  ///
  /// In pt, this message translates to:
  /// **'Alternativas seguras para o grupo inteiro'**
  String get paywallBenefit3;

  /// No description provided for @planAnnual.
  ///
  /// In pt, this message translates to:
  /// **'Anual'**
  String get planAnnual;

  /// No description provided for @planMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get planMonthly;

  /// No description provided for @planMonthlyHint.
  ///
  /// In pt, this message translates to:
  /// **'pague mês a mês'**
  String get planMonthlyHint;

  /// No description provided for @restorePurchase.
  ///
  /// In pt, this message translates to:
  /// **'Restaurar compra'**
  String get restorePurchase;

  /// No description provided for @scanHint.
  ///
  /// In pt, this message translates to:
  /// **'Aponte para o código de barras'**
  String get scanHint;

  /// No description provided for @forWhom.
  ///
  /// In pt, this message translates to:
  /// **'Para quem?'**
  String get forWhom;

  /// No description provided for @torchOn.
  ///
  /// In pt, this message translates to:
  /// **'Ligar lanterna'**
  String get torchOn;

  /// No description provided for @torchOff.
  ///
  /// In pt, this message translates to:
  /// **'Desligar lanterna'**
  String get torchOff;

  /// No description provided for @cameraUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos usar a câmera. Permita o acesso nas configurações do celular.'**
  String get cameraUnavailable;

  /// No description provided for @closeScanner.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get closeScanner;

  /// No description provided for @keepOnePerson.
  ///
  /// In pt, this message translates to:
  /// **'Selecione pelo menos uma pessoa.'**
  String get keepOnePerson;

  /// No description provided for @verdictFor.
  ///
  /// In pt, this message translates to:
  /// **'para {names}'**
  String verdictFor(String names);

  /// No description provided for @namesAnd.
  ///
  /// In pt, this message translates to:
  /// **'{first} e {last}'**
  String namesAnd(String first, String last);

  /// No description provided for @tapPersonHint.
  ///
  /// In pt, this message translates to:
  /// **'Toque em uma pessoa para ver o motivo'**
  String get tapPersonHint;

  /// No description provided for @whyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por quê?'**
  String get whyTitle;

  /// No description provided for @reasonContainsText.
  ///
  /// In pt, this message translates to:
  /// **'{allergen}: contém “{excerpt}”'**
  String reasonContainsText(String allergen, String excerpt);

  /// No description provided for @reasonContainsDeclared.
  ///
  /// In pt, this message translates to:
  /// **'{allergen}: declarado como presente pelo fabricante'**
  String reasonContainsDeclared(String allergen);

  /// No description provided for @reasonTracesText.
  ///
  /// In pt, this message translates to:
  /// **'{allergen}: “{excerpt}”'**
  String reasonTracesText(String allergen, String excerpt);

  /// No description provided for @reasonTracesDeclared.
  ///
  /// In pt, this message translates to:
  /// **'{allergen}: pode conter, segundo o fabricante'**
  String reasonTracesDeclared(String allergen);

  /// No description provided for @reasonAmbiguous.
  ///
  /// In pt, this message translates to:
  /// **'{allergen}: ingrediente que pode conter, “{excerpt}”'**
  String reasonAmbiguous(String allergen, String excerpt);

  /// No description provided for @reasonSevereNote.
  ///
  /// In pt, this message translates to:
  /// **'alergia grave: traços também contam'**
  String get reasonSevereNote;

  /// No description provided for @reasonGlutenNote.
  ///
  /// In pt, this message translates to:
  /// **'traços de trigo, centeio, cevada ou aveia contam como glúten'**
  String get reasonGlutenNote;

  /// No description provided for @reasonApproximate.
  ///
  /// In pt, this message translates to:
  /// **'leitura aproximada do rótulo'**
  String get reasonApproximate;

  /// No description provided for @reasonNoIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Sem lista de ingredientes confiável'**
  String get reasonNoIngredients;

  /// No description provided for @reasonNotFound.
  ///
  /// In pt, this message translates to:
  /// **'Produto não encontrado'**
  String get reasonNotFound;

  /// No description provided for @reasonSafe.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum alergênico de {name} encontrado'**
  String reasonSafe(String name);

  /// No description provided for @reportWrong.
  ///
  /// In pt, this message translates to:
  /// **'Isso está errado?'**
  String get reportWrong;

  /// No description provided for @reportTitle.
  ///
  /// In pt, this message translates to:
  /// **'O que está errado?'**
  String get reportTitle;

  /// No description provided for @reportHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: a receita mudou, agora contém leite'**
  String get reportHint;

  /// No description provided for @reportSend.
  ///
  /// In pt, this message translates to:
  /// **'Enviar'**
  String get reportSend;

  /// No description provided for @reportThanks.
  ///
  /// In pt, this message translates to:
  /// **'Obrigado! Vamos revisar.'**
  String get reportThanks;

  /// No description provided for @reportRequired.
  ///
  /// In pt, this message translates to:
  /// **'Conte rapidamente o que está errado.'**
  String get reportRequired;

  /// No description provided for @nextProduct.
  ///
  /// In pt, this message translates to:
  /// **'Próximo produto'**
  String get nextProduct;

  /// No description provided for @registerProduct.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar produto'**
  String get registerProduct;

  /// No description provided for @alternativesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alternativas seguras para {names}'**
  String alternativesTitle(String names);

  /// No description provided for @alternativesNone.
  ///
  /// In pt, this message translates to:
  /// **'Não encontramos alternativas seguras nesta categoria. Confira os rótulos no mercado.'**
  String get alternativesNone;

  /// No description provided for @alternativesFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos buscar alternativas agora.'**
  String get alternativesFailed;

  /// No description provided for @alternativesMore.
  ///
  /// In pt, this message translates to:
  /// **'Veja até 5 alternativas no plano Família'**
  String get alternativesMore;

  /// No description provided for @alternativesSearching.
  ///
  /// In pt, this message translates to:
  /// **'Procurando alternativas…'**
  String get alternativesSearching;

  /// No description provided for @submissionStepFront.
  ///
  /// In pt, this message translates to:
  /// **'Passo 1 de 2 · Frente da embalagem'**
  String get submissionStepFront;

  /// No description provided for @submissionStepIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Passo 2 de 2 · Lista de ingredientes'**
  String get submissionStepIngredients;

  /// No description provided for @submissionFrontHint.
  ///
  /// In pt, this message translates to:
  /// **'Enquadre a frente do produto, com nome e marca.'**
  String get submissionFrontHint;

  /// No description provided for @submissionIngredientsHint.
  ///
  /// In pt, this message translates to:
  /// **'Enquadre toda a lista de ingredientes e o quadro de alérgicos.'**
  String get submissionIngredientsHint;

  /// No description provided for @holdSteady.
  ///
  /// In pt, this message translates to:
  /// **'Segure firme…'**
  String get holdSteady;

  /// No description provided for @autoCaptureHint.
  ///
  /// In pt, this message translates to:
  /// **'A foto é tirada sozinha quando a imagem fica nítida.'**
  String get autoCaptureHint;

  /// No description provided for @takePhotoNow.
  ///
  /// In pt, this message translates to:
  /// **'Tirar foto'**
  String get takePhotoNow;

  /// No description provided for @readingIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Lendo os ingredientes…'**
  String get readingIngredients;

  /// No description provided for @reviewTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confira os ingredientes'**
  String get reviewTitle;

  /// No description provided for @reviewHint.
  ///
  /// In pt, this message translates to:
  /// **'Corrija o que a leitura errou. Termos alergênicos aparecem destacados.'**
  String get reviewHint;

  /// No description provided for @ocrEmpty.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos ler o texto. Digite os ingredientes ou refaça a foto.'**
  String get ocrEmpty;

  /// No description provided for @ingredientsLabel.
  ///
  /// In pt, this message translates to:
  /// **'Ingredientes'**
  String get ingredientsLabel;

  /// No description provided for @ingredientsRequired.
  ///
  /// In pt, this message translates to:
  /// **'Informe a lista de ingredientes.'**
  String get ingredientsRequired;

  /// No description provided for @productNameOptional.
  ///
  /// In pt, this message translates to:
  /// **'Nome do produto · opcional'**
  String get productNameOptional;

  /// No description provided for @brandOptional.
  ///
  /// In pt, this message translates to:
  /// **'Marca · opcional'**
  String get brandOptional;

  /// No description provided for @retakeIngredients.
  ///
  /// In pt, this message translates to:
  /// **'Refazer foto dos ingredientes'**
  String get retakeIngredients;

  /// No description provided for @legendContains.
  ///
  /// In pt, this message translates to:
  /// **'Contém'**
  String get legendContains;

  /// No description provided for @legendMayContain.
  ///
  /// In pt, this message translates to:
  /// **'Pode conter / ambíguo'**
  String get legendMayContain;

  /// No description provided for @sendSubmission.
  ///
  /// In pt, this message translates to:
  /// **'Enviar cadastro'**
  String get sendSubmission;

  /// No description provided for @sendingSubmission.
  ///
  /// In pt, this message translates to:
  /// **'Enviando…'**
  String get sendingSubmission;

  /// No description provided for @submissionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos enviar o cadastro. Verifique sua conexão e tente de novo.'**
  String get submissionFailed;

  /// No description provided for @submissionRateLimited.
  ///
  /// In pt, this message translates to:
  /// **'Você já enviou muitos cadastros hoje. Tente de novo amanhã.'**
  String get submissionRateLimited;

  /// No description provided for @submissionSeal.
  ///
  /// In pt, this message translates to:
  /// **'Baseado no seu cadastro · em revisão'**
  String get submissionSeal;

  /// No description provided for @submissionThanksTitle.
  ///
  /// In pt, this message translates to:
  /// **'Você acabou de ajudar outras famílias'**
  String get submissionThanksTitle;

  /// No description provided for @submissionThanksBody.
  ///
  /// In pt, this message translates to:
  /// **'Depois da revisão, o produto fica disponível para todos.'**
  String get submissionThanksBody;

  /// No description provided for @planSave.
  ///
  /// In pt, this message translates to:
  /// **'economize {percent}%'**
  String planSave(int percent);

  /// No description provided for @pricePerYear.
  ///
  /// In pt, this message translates to:
  /// **'{price}/ano'**
  String pricePerYear(String price);

  /// No description provided for @pricePerMonth.
  ///
  /// In pt, this message translates to:
  /// **'{price}/mês'**
  String pricePerMonth(String price);

  /// No description provided for @freeTrialDays.
  ///
  /// In pt, this message translates to:
  /// **'{days} dias grátis'**
  String freeTrialDays(int days);

  /// No description provided for @startFreeTrialDays.
  ///
  /// In pt, this message translates to:
  /// **'Começar {days} dias grátis'**
  String startFreeTrialDays(int days);

  /// No description provided for @subscribe.
  ///
  /// In pt, this message translates to:
  /// **'Assinar'**
  String get subscribe;

  /// No description provided for @periodYear.
  ///
  /// In pt, this message translates to:
  /// **'ano'**
  String get periodYear;

  /// No description provided for @periodMonth.
  ///
  /// In pt, this message translates to:
  /// **'mês'**
  String get periodMonth;

  /// No description provided for @storeSubscriptionsIos.
  ///
  /// In pt, this message translates to:
  /// **'Ajustes › seu nome › Assinaturas'**
  String get storeSubscriptionsIos;

  /// No description provided for @storeSubscriptionsAndroid.
  ///
  /// In pt, this message translates to:
  /// **'Play Store › Pagamentos e assinaturas › Assinaturas'**
  String get storeSubscriptionsAndroid;

  /// No description provided for @cancellationTrial.
  ///
  /// In pt, this message translates to:
  /// **'Hoje você paga R\$ 0. Depois de {days} dias, {price} por {period}, com renovação automática. Cancele quando quiser em {store}, até 24 h antes do fim do teste, e nada será cobrado.'**
  String cancellationTrial(int days, String price, String period, String store);

  /// No description provided for @cancellationNoTrial.
  ///
  /// In pt, this message translates to:
  /// **'{price} por {period}, com renovação automática. Cancele quando quiser em {store}, até 24 h antes da renovação.'**
  String cancellationNoTrial(String price, String period, String store);

  /// No description provided for @plansUnavailable.
  ///
  /// In pt, this message translates to:
  /// **'Não conseguimos carregar os planos agora.'**
  String get plansUnavailable;

  /// No description provided for @purchaseFailed.
  ///
  /// In pt, this message translates to:
  /// **'A compra não foi concluída. Nada foi cobrado. Tente de novo.'**
  String get purchaseFailed;

  /// No description provided for @familyActive.
  ///
  /// In pt, this message translates to:
  /// **'Plano Família ativo! Agora você pode adicionar todo o grupo.'**
  String get familyActive;

  /// No description provided for @familyActivating.
  ///
  /// In pt, this message translates to:
  /// **'Assinatura confirmada. A liberação pode levar alguns instantes.'**
  String get familyActivating;

  /// No description provided for @nothingToRestore.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma assinatura Família encontrada nesta conta da loja.'**
  String get nothingToRestore;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get termsOfUse;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
