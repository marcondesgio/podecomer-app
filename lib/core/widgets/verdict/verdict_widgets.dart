import 'package:flutter/material.dart';

import '../../engine/models.dart';
import '../../engine/verdict_status.dart';
import '../../theme/app_theme.dart';
import '../../theme/status_colors.dart';
import '../common.dart';
import '../../../l10n/app_localizations.dart';
import 'reason_text.dart';
import 'status_badge.dart';

/// Veredito do grupo, legível a 1 metro: cor + ícone + palavra.
class GroupVerdictHeader extends StatelessWidget {
  const GroupVerdictHeader({
    super.key,
    required this.status,
    required this.names,
  });

  final VerdictStatus status;
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.statusColors.of(status);
    final label = StatusBadge.labelFor(l10n, status);
    final forNames = l10n.verdictFor(joinNames(l10n, names));

    return Semantics(
      label: '$label, $forNames',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: palette.solid,
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
        child: Column(
          children: [
            Icon(StatusBadge.iconFor(status), size: 64, color: palette.onSolid),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: palette.onSolid,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              forNames,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: palette.onSolid),
            ),
          ],
        ),
      ),
    );
  }
}

/// Avatar com o selo de status da pessoa.
class PersonStatusAvatar extends StatelessWidget {
  const PersonStatusAvatar({super.key, required this.verdict, this.onTap});

  final PersonVerdict verdict;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.statusColors.of(verdict.status);
    final label = StatusBadge.labelFor(
      AppLocalizations.of(context),
      verdict.status,
    );
    return Semantics(
      button: onTap != null,
      label: '${verdict.personName}: $label',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            width: 72,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PersonAvatar(name: verdict.personName),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: palette.solid,
                        child: Icon(
                          StatusBadge.iconFor(verdict.status),
                          size: 16,
                          color: palette.onSolid,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(verdict.personName, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Status e motivos de uma pessoa.
class PersonReasonsCard extends StatelessWidget {
  const PersonReasonsCard({super.key, required this.verdict});

  final PersonVerdict verdict;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(verdict.personName, style: textTheme.titleMedium),
                ),
                StatusBadge(status: verdict.status),
              ],
            ),
            const SizedBox(height: 8),
            if (verdict.reasons.isEmpty)
              Text(l10n.reasonSafe(verdict.personName))
            else
              for (final reason in verdict.reasons)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• ${describeReason(l10n, reason)}'),
                ),
          ],
        ),
      ),
    );
  }
}
