import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/group/group_repository.dart';
import 'package:pode_comer/core/data/people.dart';
import 'package:pode_comer/core/data/subscription/subscription_service.dart';
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/models.dart';
import 'package:pode_comer/features/profile/presentation/profile_screen.dart';

import '../support/account_fakes.dart';

class FakeSubscriptions implements SubscriptionService {
  FakeSubscriptions({
    this.offer = defaultOffer,
    this.purchaseResult = true,
    this.restoreResult = false,
    this.failOffers = false,
    this.failPurchase = false,
  });

  static const defaultOffer = PaywallOffer(
    monthly: PlanOffer(
      period: BillingPeriod.monthly,
      priceString: r'R$ 9,90',
      price: 9.90,
      freeTrialDays: 7,
    ),
    annual: PlanOffer(
      period: BillingPeriod.annual,
      priceString: r'R$ 79,90',
      price: 79.90,
      freeTrialDays: 7,
    ),
  );

  final PaywallOffer offer;
  final bool purchaseResult;
  final bool restoreResult;
  final bool failOffers;
  final bool failPurchase;
  final calls = <String>[];

  @override
  Future<void> identify(String userId) async => calls.add('identify:$userId');
  @override
  Future<void> reset() async => calls.add('reset');
  @override
  Future<PaywallOffer> offers() async {
    if (failOffers) throw const SubscriptionFailure();
    return offer;
  }

  @override
  Future<bool> purchase(PlanOffer offer) async {
    calls.add('purchase:${offer.period.name}');
    if (failPurchase) throw const SubscriptionFailure();
    return purchaseResult;
  }

  @override
  Future<bool> restore() async {
    calls.add('restore');
    return restoreResult;
  }
}

const _carol = GroupMember(
  id: 'carol',
  name: 'Carol',
  allergies: [PersonAllergy(allergen: Allergen.gluten)],
);

void main() {
  test('anual economiza 33% sobre 12 mensalidades', () {
    expect(FakeSubscriptions.defaultOffer.annualSavingsPercent, 33);
  });

  late AppHarness app;
  late FakeSubscriptions subscriptions;

  Future<void> openPaywallFromGroup(
    WidgetTester tester, {
    FakeSubscriptions? service,
  }) async {
    subscriptions = service ?? FakeSubscriptions();
    app = AppHarness(
      user: confirmedUser,
      members: [_carol],
      overrides: [subscriptionServiceProvider.overrideWithValue(subscriptions)],
    );
    await app.pump(tester);
    await tester.tap(find.text('Meu Grupo').last);
    await tester.pumpAndSettle();
    // Free com 1 membro: o 2º abre o paywall.
    await tester.tap(find.text('Adicionar membro'));
    await tester.pumpAndSettle();
  }

  testWidgets('RevenueCat segue o usuário logado', (tester) async {
    subscriptions = FakeSubscriptions();
    app = AppHarness(
      user: confirmedUser,
      overrides: [subscriptionServiceProvider.overrideWithValue(subscriptions)],
    );
    await app.pump(tester);
    expect(subscriptions.calls, ['identify:user-1']);

    await tester.tap(find.text('Meu Perfil').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Sair'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ProfileScreen),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();
    expect(subscriptions.calls, ['identify:user-1', 'reset']);
  });

  testWidgets('mostra benefícios, preços da loja e cancelamento claro', (
    tester,
  ) async {
    await openPaywallFromGroup(tester);

    expect(find.text('Proteja toda a família'), findsOneWidget);
    expect(find.text('Um escaneamento, resultado para todos'), findsOneWidget);
    expect(find.text(r'R$ 79,90/ano'), findsOneWidget);
    expect(find.text(r'R$ 9,90/mês'), findsOneWidget);
    expect(find.text('economize 33%'), findsOneWidget);
    expect(find.text('7 dias grátis'), findsWidgets);
    expect(find.text('Começar 7 dias grátis'), findsOneWidget);
    expect(
      find.text(
        r'Hoje você paga R$ 0. Depois de 7 dias, R$ 79,90 por ano, com '
        'renovação automática. Cancele quando quiser em Play Store › '
        'Pagamentos e assinaturas › Assinaturas, até 24 h antes do fim do '
        'teste, e nada será cobrado.',
      ),
      findsOneWidget,
    );
    expect(find.text('Restaurar compra'), findsOneWidget);
    expect(find.text('Termos de uso'), findsOneWidget);
    expect(find.text('Privacidade'), findsOneWidget);
  });

  testWidgets('trocar para mensal atualiza o texto de cancelamento', (
    tester,
  ) async {
    await openPaywallFromGroup(tester);
    await tester.tap(find.byKey(const ValueKey('plan-monthly')));
    await tester.pumpAndSettle();
    expect(find.textContaining(r'R$ 9,90 por mês'), findsOneWidget);
  });

  testWidgets('assinar sincroniza o plano e libera o 2º membro', (
    tester,
  ) async {
    await openPaywallFromGroup(tester);
    app.profiles.planAfterSync = Plan.family;

    await tester.tap(find.text('Começar 7 dias grátis'));
    await tester.pumpAndSettle();

    expect(subscriptions.calls.last, 'purchase:annual');
    expect(app.profiles.calls, contains('syncSubscription'));
    expect(
      find.text('Plano Família ativo! Agora você pode adicionar todo o grupo.'),
      findsOneWidget,
    );
    expect(find.text('Proteja toda a família'), findsNothing);

    await tester.tap(find.text('Adicionar membro'));
    await tester.pumpAndSettle();
    expect(find.text('Novo membro'), findsOneWidget);
  });

  testWidgets('cancelar a compra não mostra erro nem sincroniza', (
    tester,
  ) async {
    await openPaywallFromGroup(
      tester,
      service: FakeSubscriptions(purchaseResult: false),
    );
    await tester.tap(find.text('Começar 7 dias grátis'));
    await tester.pumpAndSettle();
    expect(app.profiles.calls, isNot(contains('syncSubscription')));
    expect(find.byType(SnackBar), findsNothing);
    expect(find.text('Proteja toda a família'), findsOneWidget);
  });

  testWidgets('falha na compra avisa que nada foi cobrado', (tester) async {
    await openPaywallFromGroup(
      tester,
      service: FakeSubscriptions(failPurchase: true),
    );
    await tester.tap(find.text('Começar 7 dias grátis'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nada foi cobrado'), findsOneWidget);
  });

  testWidgets('restaurar sem assinatura avisa', (tester) async {
    await openPaywallFromGroup(tester);
    await tester.tap(find.text('Restaurar compra'));
    await tester.pumpAndSettle();
    expect(
      find.text('Nenhuma assinatura Família encontrada nesta conta da loja.'),
      findsOneWidget,
    );
  });

  testWidgets('sem planos da loja: erro e tentar de novo', (tester) async {
    await openPaywallFromGroup(
      tester,
      service: FakeSubscriptions(failOffers: true),
    );
    expect(
      find.text('Não conseguimos carregar os planos agora.'),
      findsOneWidget,
    );
    expect(find.text('Começar 7 dias grátis'), findsNothing);
  });

  testWidgets('sem teste grátis: botão "Assinar" e texto sem R\$ 0', (
    tester,
  ) async {
    await openPaywallFromGroup(
      tester,
      service: FakeSubscriptions(
        offer: const PaywallOffer(
          annual: PlanOffer(
            period: BillingPeriod.annual,
            priceString: r'R$ 79,90',
            price: 79.90,
          ),
        ),
      ),
    );
    expect(find.text('Assinar'), findsOneWidget);
    expect(find.textContaining('Hoje você paga'), findsNothing);
    expect(find.textContaining(r'R$ 79,90 por ano'), findsOneWidget);
  });
}
