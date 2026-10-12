import '../../engine/models.dart';
import '../labels.dart';
import '../../../l10n/app_localizations.dart';

/// "Ana, Carol e Enzo".
String joinNames(AppLocalizations l10n, List<String> names) => switch (names) {
  [] => '',
  [final only] => only,
  [...final init, final last] => l10n.namesAnd(init.join(', '), last),
};

/// Motivo em português, citando o trecho do rótulo quando houver.
String describeReason(AppLocalizations l10n, VerdictReason reason) {
  final allergen = reason.allergen == null
      ? ''
      : l10n.allergen(reason.allergen!);
  final excerpt = reason.excerpt;
  final text = switch ((reason.kind, reason.source)) {
    (ReasonKind.productNotFound, _) => l10n.reasonNotFound,
    (ReasonKind.noIngredients, _) => l10n.reasonNoIngredients,
    (ReasonKind.contains, ReasonSource.ingredientsText) when excerpt != null =>
      l10n.reasonContainsText(allergen, excerpt),
    (ReasonKind.contains, _) => l10n.reasonContainsDeclared(allergen),
    (ReasonKind.traces, ReasonSource.ingredientsText) when excerpt != null =>
      l10n.reasonTracesText(allergen, excerpt),
    (ReasonKind.traces, _) => l10n.reasonTracesDeclared(allergen),
    (ReasonKind.ambiguous, _) => l10n.reasonAmbiguous(allergen, excerpt ?? ''),
  };
  final notes = [
    if (reason.escalation == Escalation.severeAllergy) l10n.reasonSevereNote,
    if (reason.escalation == Escalation.glutenTraceRule) l10n.reasonGlutenNote,
    if (reason.approximate) l10n.reasonApproximate,
  ];
  return notes.isEmpty ? text : '$text (${notes.join('; ')})';
}
