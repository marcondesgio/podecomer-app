import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../auth/auth_controller.dart';
import '../env.dart';

/// Entitlement do RevenueCat que libera o plano Família.
const familyEntitlement = 'familia';

enum BillingPeriod { monthly, annual }

/// Um plano à venda, com preço da loja (já localizado).
class PlanOffer {
  const PlanOffer({
    required this.period,
    required this.priceString,
    required this.price,
    this.freeTrialDays,
    this.handle,
  });

  final BillingPeriod period;
  final String priceString;
  final double price;

  /// Dias grátis, se a pessoa ainda tiver direito ao teste.
  final int? freeTrialDays;

  /// Objeto da loja (Package do RevenueCat).
  final Object? handle;
}

class PaywallOffer {
  const PaywallOffer({this.monthly, this.annual});

  final PlanOffer? monthly;
  final PlanOffer? annual;

  bool get isEmpty => monthly == null && annual == null;

  /// Economia do anual sobre 12 mensalidades (ex.: 33).
  int? get annualSavingsPercent {
    final m = monthly, a = annual;
    if (m == null || a == null || m.price <= 0) return null;
    final saving = 1 - a.price / (m.price * 12);
    return saving > 0 ? (saving * 100).round() : null;
  }
}

class SubscriptionFailure implements Exception {
  const SubscriptionFailure();
}

abstract interface class SubscriptionService {
  /// Liga o cliente do RevenueCat ao id do usuário no Supabase (é por esse
  /// id que o webhook atualiza `profiles.plan`).
  Future<void> identify(String userId);
  Future<void> reset();
  Future<PaywallOffer> offers();

  /// `true` = Família ativo; `false` = cancelou. Erro → [SubscriptionFailure].
  Future<bool> purchase(PlanOffer offer);

  /// `true` se havia assinatura Família para restaurar.
  Future<bool> restore();
}

final subscriptionServiceProvider = Provider<SubscriptionService>((ref) {
  final key = Platform.isIOS ? Env.revenueCatIosKey : Env.revenueCatAndroidKey;
  return key.isEmpty
      ? const UnavailableSubscriptionService()
      : RevenueCatSubscriptionService(key);
});

/// Mantém o cliente do RevenueCat ligado ao usuário logado: o webhook usa
/// esse id para atualizar `profiles.plan`. Observado uma vez pelo app.
final subscriptionIdentityProvider = Provider<void>((ref) {
  ref.listen(authControllerProvider.select((s) => s.user?.id), (_, userId) {
    final service = ref.read(subscriptionServiceProvider);
    final sync = userId == null ? service.reset() : service.identify(userId);
    sync.catchError((Object _) {});
  }, fireImmediately: true);
});

/// Planos da loja para o paywall.
final paywallOfferProvider = FutureProvider.autoDispose<PaywallOffer>(
  (ref) => ref.watch(subscriptionServiceProvider).offers(),
);

class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService(this._apiKey);

  final String _apiKey;
  var _configured = false;

  @override
  Future<void> identify(String userId) => _guard(() async {
    if (!_configured) {
      await Purchases.configure(
        PurchasesConfiguration(_apiKey)..appUserID = userId,
      );
      _configured = true;
    } else {
      await Purchases.logIn(userId);
    }
  });

  @override
  Future<void> reset() async {
    if (!_configured) return;
    try {
      await Purchases.logOut();
    } on PlatformException {
      // Já anônimo: nada a fazer.
    }
  }

  @override
  Future<PaywallOffer> offers() => _guard(() async {
    final offering = (await Purchases.getOfferings()).current;
    PlanOffer? map(Package? package, BillingPeriod period) {
      if (package == null) return null;
      final product = package.storeProduct;
      final intro = product.introductoryPrice;
      final trialDays = intro != null && intro.price == 0
          ? switch (intro.periodUnit) {
              PeriodUnit.day => intro.periodNumberOfUnits,
              PeriodUnit.week => intro.periodNumberOfUnits * 7,
              PeriodUnit.month => intro.periodNumberOfUnits * 30,
              _ => null,
            }
          : null;
      return PlanOffer(
        period: period,
        priceString: product.priceString,
        price: product.price,
        freeTrialDays: trialDays,
        handle: package,
      );
    }

    return PaywallOffer(
      monthly: map(offering?.monthly, BillingPeriod.monthly),
      annual: map(offering?.annual, BillingPeriod.annual),
    );
  });

  @override
  Future<bool> purchase(PlanOffer offer) async {
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(offer.handle! as Package),
      );
      return result.customerInfo.entitlements.active.containsKey(
        familyEntitlement,
      );
    } on PlatformException catch (e) {
      if (PurchasesErrorHelper.getErrorCode(e) ==
          PurchasesErrorCode.purchaseCancelledError) {
        return false;
      }
      throw const SubscriptionFailure();
    }
  }

  @override
  Future<bool> restore() => _guard(() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(familyEntitlement);
  });

  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException {
      throw const SubscriptionFailure();
    }
  }
}

/// Sem chave do RevenueCat no `.env`: o paywall mostra erro, sem travar.
class UnavailableSubscriptionService implements SubscriptionService {
  const UnavailableSubscriptionService();

  @override
  Future<void> identify(String userId) async {}
  @override
  Future<void> reset() async {}
  @override
  Future<PaywallOffer> offers() async => throw const SubscriptionFailure();
  @override
  Future<bool> purchase(PlanOffer offer) async =>
      throw const SubscriptionFailure();
  @override
  Future<bool> restore() async => throw const SubscriptionFailure();
}
