import 'package:flutter/material.dart';

import '../../engine/verdict_status.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Selo de status: cor + forma/ícone + palavra (nunca só cor).
/// Formas do DS: círculo ✓, triângulo !, octógono ✕, quadrado ?.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final VerdictStatus status;

  static IconData iconFor(VerdictStatus status) => switch (status) {
    VerdictStatus.safe => Icons.check_circle,
    VerdictStatus.caution => Icons.warning_rounded,
    VerdictStatus.doNotConsume => Icons.dangerous,
    VerdictStatus.inconclusive => Icons.help_center,
  };

  static String labelFor(AppLocalizations l10n, VerdictStatus status) =>
      switch (status) {
        VerdictStatus.safe => l10n.statusSafe,
        VerdictStatus.caution => l10n.statusCaution,
        VerdictStatus.doNotConsume => l10n.statusDoNotConsume,
        VerdictStatus.inconclusive => l10n.statusInconclusive,
      };

  @override
  Widget build(BuildContext context) {
    final palette = context.statusColors.of(status);
    final label = labelFor(AppLocalizations.of(context), status);
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.solid,
          borderRadius: BorderRadius.circular(AppSizes.radiusChip),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(iconFor(status), color: palette.onSolid),
              const SizedBox(width: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: palette.onSolid,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
