import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../engine/allergen.dart';
import '../engine/models.dart';
import 'labels.dart';

/// Multiselect de alergênicos + gravidade de cada selecionado.
class AllergySelector extends StatelessWidget {
  const AllergySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final List<PersonAllergy> value;
  final ValueChanged<List<PersonAllergy>> onChanged;

  void _toggle(Allergen allergen, bool selected) {
    final next = selected
        ? [...value, PersonAllergy(allergen: allergen)]
        : value.where((a) => a.allergen != allergen).toList();
    next.sort((a, b) => a.allergen.index.compareTo(b.allergen.index));
    onChanged(next);
  }

  void _setSeverity(Allergen allergen, AllergySeverity severity) => onChanged([
    for (final a in value)
      a.allergen == allergen ? a.copyWith(severity: severity) : a,
  ]);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final selected = {for (final a in value) a.allergen};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final allergen in Allergen.values)
              FilterChip(
                label: Text(l10n.allergen(allergen)),
                selected: selected.contains(allergen),
                onSelected: (on) => _toggle(allergen, on),
              ),
          ],
        ),
        if (value.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            l10n.severityQuestion,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final allergy in value)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(child: Text(l10n.allergen(allergy.allergen))),
                  SegmentedButton<AllergySeverity>(
                    key: ValueKey('severity-${allergy.allergen.code}'),
                    showSelectedIcon: false,
                    segments: [
                      for (final severity in AllergySeverity.values)
                        ButtonSegment(
                          value: severity,
                          label: Text(l10n.severity(severity)),
                        ),
                    ],
                    selected: {allergy.severity},
                    onSelectionChanged: (s) =>
                        _setSeverity(allergy.allergen, s.single),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// Chips só de leitura: "Amendoim Grave".
class AllergyChips extends StatelessWidget {
  const AllergyChips({super.key, required this.allergies});

  final List<PersonAllergy> allergies;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (allergies.isEmpty) {
      return Text(
        l10n.noAllergies,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final a in allergies)
          Chip(
            label: Text(
              '${l10n.allergen(a.allergen)} · ${l10n.severity(a.severity)}',
            ),
          ),
      ],
    );
  }
}
