import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/data/links.dart';
import '../../../core/data/subscription/subscription_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';

/// Plano Família: preços e teste grátis vêm da loja (RevenueCat).
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  var _billing = BillingPeriod.annual;
  var _busy = false;

  Future<void> _afterActivation() async {
    final l10n = AppLocalizations.of(context);
    try {
      // Não espera o webhook: sincroniza o plano agora.
      await ref.read(profileRepositoryProvider).syncSubscription();
      ref.invalidate(myProfileProvider);
      if (!mounted) return;
      showMessage(context, l10n.familyActive);
      context.pop(true);
    } on Object {
      // O webhook atualiza o plano em seguida.
      if (mounted) showMessage(context, l10n.familyActivating);
    }
  }

  Future<void> _run(Future<bool> Function() action, String notFound) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      if (await action()) {
        await _afterActivation();
      } else if (notFound.isNotEmpty && mounted) {
        showMessage(context, notFound);
      }
    } on Object {
      if (mounted) showMessage(context, l10n.purchaseFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final offer = ref.watch(paywallOfferProvider);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            Text(l10n.paywallHeadline, style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(l10n.paywallFreeIncludes),
            const SizedBox(height: 16),
            for (final benefit in [
              l10n.paywallBenefit1,
              l10n.paywallBenefit2,
              l10n.paywallBenefit3,
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(benefit),
              ),
            const SizedBox(height: 16),
            ...switch (offer) {
              AsyncData(:final value) when !value.isEmpty => _plans(
                context,
                value,
              ),
              AsyncError() || AsyncData() => [
                Text(l10n.plansUnavailable),
                TextButton(
                  onPressed: () => ref.invalidate(paywallOfferProvider),
                  child: Text(l10n.retry),
                ),
              ],
              _ => [const Center(child: CircularProgressIndicator())],
            },
            const SizedBox(height: 8),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          ref.read(subscriptionServiceProvider).restore,
                          l10n.nothingToRestore,
                        ),
                  child: Text(l10n.restorePurchase),
                ),
                TextButton(
                  onPressed: () => openLink(LegalLinks.terms),
                  child: Text(l10n.termsOfUse),
                ),
                TextButton(
                  onPressed: () => openLink(LegalLinks.privacy),
                  child: Text(l10n.privacyPolicy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _plans(BuildContext context, PaywallOffer offer) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final available = [?offer.annual, ?offer.monthly];
    final selected =
        available.where((p) => p.period == _billing).firstOrNull ??
        available.first;
    final savings = offer.annualSavingsPercent;
    final trialDays = selected.freeTrialDays;
    final period = selected.period == BillingPeriod.annual
        ? l10n.periodYear
        : l10n.periodMonth;
    final store = Platform.isIOS
        ? l10n.storeSubscriptionsIos
        : l10n.storeSubscriptionsAndroid;

    return [
      for (final plan in available)
        _PlanCard(
          key: ValueKey('plan-${plan.period.name}'),
          selected: plan == selected,
          title: plan.period == BillingPeriod.annual
              ? l10n.planAnnual
              : l10n.planMonthly,
          badge: plan.period == BillingPeriod.annual && savings != null
              ? l10n.planSave(savings)
              : null,
          price: plan.period == BillingPeriod.annual
              ? l10n.pricePerYear(plan.priceString)
              : l10n.pricePerMonth(plan.priceString),
          hint: plan.freeTrialDays != null
              ? l10n.freeTrialDays(plan.freeTrialDays!)
              : (plan.period == BillingPeriod.annual
                    ? null
                    : l10n.planMonthlyHint),
          onTap: () => setState(() => _billing = plan.period),
        ),
      const SizedBox(height: 16),
      BusyButton(
        busy: _busy,
        label: trialDays == null
            ? l10n.subscribe
            : l10n.startFreeTrialDays(trialDays),
        onPressed: () => _run(
          () => ref.read(subscriptionServiceProvider).purchase(selected),
          '',
        ),
      ),
      const SizedBox(height: 12),
      // Texto de cancelamento claro, com preço e período reais da loja.
      Text(
        trialDays == null
            ? l10n.cancellationNoTrial(selected.priceString, period, store)
            : l10n.cancellationTrial(
                trialDays,
                selected.priceString,
                period,
                store,
              ),
        textAlign: TextAlign.center,
        style: textTheme.bodySmall,
      ),
    ];
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    super.key,
    required this.selected,
    required this.title,
    required this.price,
    required this.onTap,
    this.badge,
    this.hint,
  });

  final bool selected;
  final String title;
  final String price;
  final String? badge;
  final String? hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outline,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: selected ? scheme.primary : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(title, style: textTheme.titleMedium),
                          if (badge case final badge?)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusChip,
                                ),
                              ),
                              child: Text(
                                badge,
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.onPrimary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (hint case final hint?)
                        Text(hint, style: textTheme.bodySmall),
                    ],
                  ),
                ),
                Text(price, style: textTheme.titleMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
