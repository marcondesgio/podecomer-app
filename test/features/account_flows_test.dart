import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/auth/auth_repository.dart';
import 'package:pode_comer/core/data/group/group_repository.dart';
import 'package:pode_comer/core/data/people.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/models.dart';

import '../support/account_fakes.dart';

void main() {
  group('Cadastro e verificação de e-mail', () {
    testWidgets('deslogado abre nas boas-vindas', (tester) async {
      await AppHarness().pump(tester);
      expect(find.text('Um scan. A família toda protegida.'), findsOneWidget);
      expect(find.text('Começar'), findsOneWidget);
    });

    testWidgets('valida campos do cadastro', (tester) async {
      final app = AppHarness();
      await app.pump(tester);
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();
      expect(find.text('Informe seu nome.'), findsOneWidget);
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(find.text('Use pelo menos 8 caracteres.'), findsOneWidget);
      expect(app.auth.calls, isEmpty);
    });

    testWidgets('cadastro leva à verificação e só ela fica acessível', (
      tester,
    ) async {
      final app = AppHarness();
      await app.pump(tester);
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Ana');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'ana@email.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        '12345678',
      );
      await tester.tap(find.text('Criar conta'));
      await tester.pumpAndSettle();

      expect(app.auth.calls, ['signUp:Ana:ana@email.com']);
      expect(find.text('Confira seu e-mail'), findsOneWidget);
      expect(find.text('ana@email.com'), findsOneWidget);

      await tester.tap(find.text('Reenviar'));
      await tester.pump();
      expect(app.auth.calls.last, 'resend:ana@email.com');
      await tester.pump(const Duration(seconds: 61));
      await tester.pumpAndSettle();

      // Confirmação pelo deep link: entra e vai para o onboarding.
      app.profiles.profile = profileOf(consent: false);
      app.auth.emit(AuthEvent.signedIn, confirmedUser);
      await tester.pumpAndSettle();
      expect(find.text('Minhas alergias'), findsOneWidget);
    });

    testWidgets('"Usar outro e-mail" volta às boas-vindas', (tester) async {
      final app = AppHarness(
        user: const AppUser(id: 'u', email: 'a@b.com', emailConfirmed: false),
      );
      await app.pump(tester);
      expect(find.text('Confira seu e-mail'), findsOneWidget);

      await tester.tap(find.text('Usar outro e-mail'));
      await tester.pumpAndSettle();
      expect(app.auth.calls, contains('signOut'));
      expect(find.text('Começar'), findsOneWidget);
    });
  });

  group('Login e senha', () {
    testWidgets('senha errada mostra erro amigável', (tester) async {
      final app = AppHarness();
      await app.pump(tester);
      await tester.tap(find.text('Já tem conta? Entrar'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'E-mail'),
        'ana@email.com',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), 'x');
      await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
      await tester.pumpAndSettle();
      expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    });

    testWidgets('login com Google abre o fluxo OAuth', (tester) async {
      final app = AppHarness();
      await app.pump(tester);
      await tester.tap(find.text('Já tem conta? Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continuar com Google'));
      await tester.pumpAndSettle();
      expect(app.auth.calls, ['oauth:google']);
    });

    testWidgets('recuperação de senha envia o link', (tester) async {
      final app = AppHarness();
      await app.pump(tester);
      await tester.tap(find.text('Já tem conta? Entrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Esqueci minha senha'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'ana@email.com');
      await tester.tap(find.text('Enviar link'));
      await tester.pumpAndSettle();
      expect(app.auth.calls, ['reset:ana@email.com']);
      expect(find.textContaining('Se houver uma conta'), findsOneWidget);
    });

    testWidgets('link de recuperação abre a tela de nova senha', (
      tester,
    ) async {
      final app = AppHarness(user: confirmedUser);
      await app.pump(tester);
      app.auth.emit(AuthEvent.passwordRecovery, confirmedUser);
      await tester.pumpAndSettle();
      expect(find.text('Nova senha'), findsWidgets);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nova senha'),
        'nova-senha-1',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Repita a senha'),
        'nova-senha-1',
      );
      await tester.tap(find.text('Salvar senha'));
      await tester.pumpAndSettle();
      expect(app.auth.calls, ['updatePassword']);
      expect(find.text('Olá, Ana'), findsOneWidget);
    });
  });

  group('Onboarding', () {
    testWidgets('exige consentimento e grava alergias com gravidade', (
      tester,
    ) async {
      final app = AppHarness(
        user: confirmedUser,
        profile: profileOf(consent: false),
      );
      await app.pump(tester);
      expect(find.text('Passo 1 de 2'), findsOneWidget);

      Finder continueButton() => find.widgetWithText(FilledButton, 'Continuar');
      expect(tester.widget<FilledButton>(continueButton()).onPressed, isNull);
      expect(find.text('Marque a autorização para continuar'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilterChip, 'Amendoim'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byKey(const ValueKey('severity-amendoim')),
          matching: find.text('Grave'),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('health-consent')));
      await tester.pumpAndSettle();
      await tester.tap(continueButton());
      await tester.pumpAndSettle();

      expect(app.profiles.onboardingAllergies, const [
        PersonAllergy(
          allergen: Allergen.peanut,
          severity: AllergySeverity.severe,
        ),
      ]);
      expect(find.text('Quem mais você protege?'), findsOneWidget);

      await tester.tap(find.text('Pular por enquanto'));
      await tester.pumpAndSettle();
      expect(find.text('Olá, Ana'), findsOneWidget);
    });

    testWidgets('sem consentimento não acessa outras telas', (tester) async {
      final app = AppHarness(
        user: confirmedUser,
        profile: profileOf(consent: false),
      );
      await app.pump(tester);
      expect(find.text('Minhas alergias'), findsOneWidget);
      expect(find.text('Meu Grupo'), findsNothing);
    });
  });

  group('Meu Grupo', () {
    const carol = GroupMember(
      id: 'm-carol',
      name: 'Carol',
      allergies: [PersonAllergy(allergen: Allergen.gluten)],
    );

    Future<AppHarness> openGroup(
      WidgetTester tester, {
      Plan plan = Plan.free,
      List<GroupMember>? members,
    }) async {
      final app = AppHarness(
        user: confirmedUser,
        profile: profileOf(plan: plan),
        members: members,
      );
      await app.pump(tester);
      await tester.tap(find.text('Meu Grupo').last);
      await tester.pumpAndSettle();
      return app;
    }

    testWidgets('lista titular e membros com alergias', (tester) async {
      await openGroup(tester, members: [carol]);
      expect(find.text('2 pessoas'), findsOneWidget);
      expect(find.text('Ana (você)'), findsOneWidget);
      expect(find.text('Titular da conta'), findsOneWidget);
      expect(find.text('Carol'), findsOneWidget);
      expect(find.text('Glúten · Leve'), findsOneWidget);
    });

    testWidgets('free com 1 membro: "Adicionar" abre o paywall', (
      tester,
    ) async {
      await openGroup(tester, members: [carol]);
      await tester.tap(find.text('Adicionar membro'));
      await tester.pumpAndSettle();
      expect(find.text('Proteja toda a família'), findsOneWidget);
    });

    testWidgets('cria membro com alergias', (tester) async {
      final app = await openGroup(tester);
      await tester.tap(find.text('Adicionar membro'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Enzo',
      );
      await tester.pumpAndSettle();
      expect(find.text('Alergias de Enzo'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilterChip, 'Lactose'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Masculino'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      final enzo = app.groups.members.single;
      expect(enzo.name, 'Enzo');
      expect(enzo.sex, Sex.male);
      expect(enzo.allergies.single.allergen, Allergen.lactose);
      expect(find.text('Enzo'), findsOneWidget);
    });

    testWidgets('limite do plano recusado no servidor abre o paywall', (
      tester,
    ) async {
      // A lista local está desatualizada: o servidor já tem 1 membro.
      final app = await openGroup(tester);
      app.groups.members.add(carol);
      await tester.tap(find.text('Adicionar membro'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Nome'), 'Bia');
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(find.text('Proteja toda a família'), findsOneWidget);
    });

    testWidgets('plano Família adiciona além de 1 membro', (tester) async {
      await openGroup(tester, plan: Plan.family, members: [carol]);
      await tester.tap(find.text('Adicionar membro'));
      await tester.pumpAndSettle();
      expect(find.text('Novo membro'), findsOneWidget);
    });

    testWidgets('excluir pede confirmação', (tester) async {
      final app = await openGroup(tester, members: [carol]);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir').last);
      await tester.pumpAndSettle();
      expect(find.text('Excluir Carol do grupo?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(app.groups.members, hasLength(1));

      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Excluir'));
      await tester.pumpAndSettle();
      expect(app.groups.members, isEmpty);
      expect(find.text('Carol'), findsNothing);
    });

    testWidgets('editar membro salva alterações', (tester) async {
      final app = await openGroup(tester, members: [carol]);
      await tester.tap(find.text('Carol'));
      await tester.pumpAndSettle();
      expect(find.text('Editar membro'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Carolina',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(app.groups.members.single.name, 'Carolina');
      expect(find.text('Carolina'), findsOneWidget);
    });
  });

  group('Meu Perfil', () {
    Future<AppHarness> openProfile(WidgetTester tester) async {
      final app = AppHarness(
        user: confirmedUser,
        profile: profileOf(
          allergies: const [
            PersonAllergy(
              allergen: Allergen.peanut,
              severity: AllergySeverity.severe,
            ),
          ],
        ),
      );
      await app.pump(tester);
      await tester.tap(find.text('Meu Perfil').last);
      await tester.pumpAndSettle();
      return app;
    }

    testWidgets('mostra dados, alergias e plano', (tester) async {
      await openProfile(tester);
      expect(find.text('ana@email.com'), findsWidgets);
      expect(find.text('Amendoim · Grave'), findsOneWidget);
      expect(find.text('Gratuito'), findsOneWidget);
      expect(find.text('Você + 1 membro'), findsOneWidget);
    });

    testWidgets('edita o nome', (tester) async {
      final app = await openProfile(tester);
      expect(find.text('Salvar alterações'), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nome'),
        'Ana Souza',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Salvar alterações'));
      await tester.pumpAndSettle();
      expect(app.profiles.calls, ['update:Ana Souza']);
      expect(find.text('Alterações salvas.'), findsOneWidget);
    });

    testWidgets('edita alergias', (tester) async {
      final app = await openProfile(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Editar'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Ovo'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();
      expect(app.profiles.calls, ['saveAllergies']);
      expect(find.text('Ovo · Leve'), findsOneWidget);
    });

    testWidgets('excluir conta pede confirmação e sai', (tester) async {
      final app = await openProfile(tester);
      await tester.tap(find.widgetWithText(TextButton, 'Excluir conta'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir sua conta?'), findsOneWidget);

      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(app.profiles.calls, isEmpty);

      await tester.tap(find.widgetWithText(TextButton, 'Excluir conta'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Excluir conta'),
        ),
      );
      await tester.pumpAndSettle();
      expect(app.profiles.calls, ['deleteAccount']);
      expect(find.text('Começar'), findsOneWidget);
    });
  });
}
