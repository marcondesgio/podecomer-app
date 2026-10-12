import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/data/allergen_engine_provider.dart';
import '../../../core/data/household.dart';
import '../../../core/data/products/barcode.dart';
import '../../../core/data/products/product_providers.dart';
import '../../../core/data/scan_metrics.dart';
import '../../../core/router/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../../../l10n/app_localizations.dart';
import 'barcode_camera.dart';

class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen> {
  late final BarcodeCamera _camera = ref.read(barcodeCameraProvider)();
  final _debouncer = ScanDebouncer();
  var _opening = false;

  @override
  void initState() {
    super.initState();
    // Aquece o que o resultado vai precisar enquanto a câmera foca.
    ref.read(allergenEngineProvider.future).ignore();
    ref.read(productRepositoryProvider.future).ignore();
    ref.read(householdProvider.future).ignore();
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  Future<void> _onCode(String raw) async {
    if (_opening) return;
    final barcode = normalizeScannedBarcode(raw);
    if (barcode == null || !_debouncer.accept(barcode)) return;

    _opening = true;
    final trace = ScanTrace();
    unawaited(HapticFeedback.mediumImpact());
    // Começa a consulta já, em paralelo com a transição de tela.
    final prefetch = ref.listenManual(
      productLookupProvider(barcode),
      (_, _) {},
    );
    try {
      await _camera.pause();
      if (!mounted) return;
      await context.push(AppRoutes.resultFor(barcode), extra: trace);
      if (mounted) await _camera.resume();
    } finally {
      prefetch.close();
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _camera.build(
            context,
            onCode: _onCode,
            errorBuilder: (context) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.screenMargin),
                child: Text(
                  l10n.cameraUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
          const _Viewfinder(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton.filledTonal(
                      tooltip: l10n.closeScanner,
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const Spacer(),
                    ValueListenableBuilder(
                      valueListenable: _camera.torchOn,
                      builder: (context, on, _) => IconButton.filledTonal(
                        tooltip: on ? l10n.torchOff : l10n.torchOn,
                        isSelected: on,
                        onPressed: _camera.toggleTorch,
                        icon: Icon(on ? Icons.flash_on : Icons.flash_off),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  l10n.scanHint,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                const _ForWhomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: Center(
      child: Container(
        width: 280,
        height: 160,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 3),
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
      ),
    ),
  );
}

/// "Para quem?": chips com cada pessoa do grupo.
class _ForWhomPanel extends ConsumerWidget {
  const _ForWhomPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final household = ref.watch(householdProvider).value;
    final excluded = ref.watch(excludedPeopleProvider);
    if (household == null || household.length < 2) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppSizes.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.screenMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.forWhom, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final person in household)
                  FilterChip(
                    avatar: PersonAvatar(name: person.name, radius: 12),
                    label: Text(person.name),
                    selected: !excluded.contains(person.id),
                    onSelected: (_) {
                      final ok = ref
                          .read(excludedPeopleProvider.notifier)
                          .toggle(person.id, household);
                      if (!ok) showMessage(context, l10n.keepOnePerson);
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
