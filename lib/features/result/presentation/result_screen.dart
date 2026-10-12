import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/account_providers.dart';
import '../../../core/data/allergen_engine_provider.dart';
import '../../../core/data/household.dart';
import '../../../core/data/people.dart';
import '../../../core/data/products/product_lookup_result.dart';
import '../../../core/data/products/product_providers.dart';
import '../../../core/data/products/product_record.dart';
import '../../../core/data/scan_metrics.dart';
import '../../../core/engine/models.dart';
import '../../../core/engine/verdict_status.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/status_colors.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/verdict/reason_text.dart';
import '../../../core/widgets/verdict/status_badge.dart';
import '../../../core/widgets/verdict/verdict_widgets.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key, required this.barcode, this.trace});

  final String barcode;

  /// Presente quando veio do scanner: mede scan→veredito e "Próximo produto"
  /// volta para a câmera.
  final ScanTrace? trace;

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends ConsumerState<ResultScreen> {
  final _personKeys = <String, GlobalKey>{};
  var _scanSaved = false;

  void _retry() => ref.invalidate(productLookupProvider(widget.barcode));

  void _nextProduct() {
    if (widget.trace != null && context.canPop()) {
      context.pop();
    } else {
      context.pushReplacement(AppRoutes.scanner);
    }
  }

  /// Uma vez por tela: grava o scan e registra o tempo até o veredito.
  void _onVerdict(GroupVerdict verdict, ProductRecord? record) {
    if (_scanSaved) return;
    _scanSaved = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trace case final trace?) {
        ref
            .read(scanMetricsProvider.notifier)
            .record(
              ScanMetric(
                elapsed: trace.markVerdict(),
                fromCache: record?.fromCache ?? false,
              ),
            );
      }
    });
    // Não bloqueia a tela; falha ao gravar histórico não afeta o veredito.
    ref
        .read(activityRepositoryProvider)
        .saveScan(widget.barcode, verdict.status)
        .catchError((Object _) {});
  }

  Future<void> _report() async {
    final l10n = AppLocalizations.of(context);
    final message = await showDialog<String>(
      context: context,
      builder: (context) => const _ReportDialog(),
    );
    if (message == null || !mounted) return;
    try {
      await ref
          .read(activityRepositoryProvider)
          .report(widget.barcode, message);
      if (mounted) showMessage(context, l10n.reportThanks);
    } on Object {
      if (mounted) showMessage(context, l10n.genericError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lookup = ref.watch(productLookupProvider(widget.barcode));
    final people = ref.watch(selectedPeopleProvider);
    final engine = ref.watch(allergenEngineProvider);

    final List<Widget> body;
    // Recarregando = dados possivelmente antigos: espera, não dá veredito.
    final selected = people.isLoading ? null : people.value;
    switch ((lookup, selected, engine.value)) {
      case (
        AsyncData(value: ProductFound() || ProductNotFound()),
        final selected?,
        final engine?,
      ):
        final record = switch (lookup.value) {
          ProductFound(:final record) => record,
          _ => null,
        };
        final verdict = engine.evaluate(record?.product, selected);
        _onVerdict(verdict, record);
        body = _verdictBody(context, verdict, record);
      case (AsyncData(value: ProductLookupFailed()), _, _) ||
          (AsyncError(), _, _):
        // Falha de rede/servidor: nunca um veredito.
        body = [
          const Align(
            alignment: Alignment.centerLeft,
            child: StatusBadge(status: VerdictStatus.inconclusive),
          ),
          const SizedBox(height: 12),
          Text(l10n.lookupFailedMessage),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.retry),
          ),
        ];
      case _ when people.hasError || engine.hasError:
        body = [
          Text(l10n.genericError),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              ref.invalidate(householdProvider);
              ref.invalidate(allergenEngineProvider);
            },
            child: Text(l10n.retry),
          ),
        ];
      default:
        body = [
          const SizedBox(height: 48),
          const Center(child: CircularProgressIndicator()),
        ];
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.resultTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSizes.screenMargin),
          children: [
            ...body,
            const SizedBox(height: 24),
            Text(
              l10n.labelDisclaimer,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _nextProduct,
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(l10n.nextProduct),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _verdictBody(
    BuildContext context,
    GroupVerdict verdict,
    ProductRecord? record,
  ) {
    final l10n = AppLocalizations.of(context);
    final names = [for (final p in verdict.people) p.personName];
    final needsAlternatives =
        record != null &&
        (verdict.status == VerdictStatus.caution ||
            verdict.status == VerdictStatus.doNotConsume);

    return [
      if (record != null) _ProductInfo(record: record),
      const SizedBox(height: 16),
      GroupVerdictHeader(status: verdict.status, names: names),
      const SizedBox(height: 16),
      if (verdict.people.length > 1) ...[
        Text(l10n.tapPersonHint, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final person in verdict.people)
                PersonStatusAvatar(
                  verdict: person,
                  onTap: () => Scrollable.ensureVisible(
                    _personKeys[person.personId]!.currentContext!,
                    duration: const Duration(milliseconds: 300),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      Text(l10n.whyTitle, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      for (final person in verdict.people)
        PersonReasonsCard(
          key: _personKeys.putIfAbsent(person.personId, GlobalKey.new),
          verdict: person,
        ),
      if (record == null) ...[
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () =>
              context.push(AppRoutes.productSubmissionFor(widget.barcode)),
          icon: const Icon(Icons.add_a_photo_outlined),
          label: Text(l10n.registerProduct),
        ),
      ],
      if (needsAlternatives) ...[
        const SizedBox(height: 16),
        _SafeAlternatives(barcode: widget.barcode, names: names),
      ],
      if (record != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: _report,
            icon: const Icon(Icons.flag_outlined),
            label: Text(l10n.reportWrong),
          ),
        ),
    ];
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.record});

  final ProductRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final source = switch (record.origin) {
      ProductOrigin.ownVerified => l10n.originOwnVerified,
      ProductOrigin.openFoodFacts => l10n.originOpenFoodFacts,
      ProductOrigin.ownPending => l10n.originOwnPending,
    };
    final updatedAt = record.updatedAt;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          record.name ?? l10n.unknownProductName,
          style: textTheme.headlineSmall,
        ),
        if (record.brand case final brand?)
          Text(brand, style: textTheme.bodyMedium),
        if (!record.origin.isVerified)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Chip(
              avatar: const Icon(Icons.pending_outlined),
              label: Text(l10n.unverifiedBadge),
            ),
          ),
        const SizedBox(height: 4),
        Text(
          updatedAt == null
              ? l10n.dataSource(source)
              : l10n.dataUpdatedAt(updatedAt.toLocal(), source),
          style: textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _SafeAlternatives extends ConsumerWidget {
  const _SafeAlternatives({required this.barcode, required this.names});

  final String barcode;
  final List<String> names;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final alternatives = ref.watch(safeAlternativesProvider(barcode));
    final plan = ref.watch(myProfileProvider).value?.plan ?? Plan.free;
    // Plano grátis: 1 alternativa; Família: até 5.
    final visible = plan == Plan.free ? 1 : 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.alternativesTitle(joinNames(l10n, names)),
          style: textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        ...switch (alternatives) {
          AsyncData(:final value) when value.isEmpty => [
            Text(l10n.alternativesNone),
          ],
          AsyncData(:final value) => [
            for (final record in value.take(visible))
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    StatusBadge.iconFor(VerdictStatus.safe),
                    color: context.statusColors.safe.solid,
                  ),
                  title: Text(record.name ?? l10n.unknownProductName),
                  subtitle: record.brand == null ? null : Text(record.brand!),
                  onTap: () =>
                      context.push(AppRoutes.resultFor(record.barcode)),
                ),
              ),
            if (value.length > visible)
              TextButton(
                onPressed: () => context.push(AppRoutes.paywall),
                child: Text(l10n.alternativesMore),
              ),
          ],
          AsyncError() => [
            Text(l10n.alternativesFailed),
            TextButton(
              onPressed: () =>
                  ref.invalidate(safeAlternativesProvider(barcode)),
              child: Text(l10n.retry),
            ),
          ],
          _ => [
            Row(
              children: [
                const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.alternativesSearching)),
              ],
            ),
          ],
        },
      ],
    );
  }
}

class _ReportDialog extends StatefulWidget {
  const _ReportDialog();

  @override
  State<_ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<_ReportDialog> {
  final _form = GlobalKey<FormState>();
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.reportTitle),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _message,
          autofocus: true,
          maxLines: 4,
          maxLength: 2000,
          decoration: InputDecoration(hintText: l10n.reportHint),
          validator: (v) =>
              (v ?? '').trim().isEmpty ? l10n.reportRequired : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (_form.currentState!.validate()) {
              Navigator.of(context).pop(_message.text.trim());
            }
          },
          child: Text(l10n.reportSend),
        ),
      ],
    );
  }
}
