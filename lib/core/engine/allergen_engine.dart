import 'allergen.dart';
import 'allergen_dictionary.dart';
import 'label_analyzer.dart';
import 'models.dart';
import 'verdict_status.dart';

/// Motor determinístico de alergênicos. Dart puro: não importar Flutter.
///
/// Regras (precedência NÃO CONSUMIR > ATENÇÃO > INCONCLUSIVO > SEGURO):
/// - Sem produto, ou sem ingredientes → INCONCLUSIVO (nunca SEGURO). O que
///   estiver declarado ainda é avaliado e pode piorar o status.
/// - Alergênico declarado como "contém" ou termo do dicionário nos
///   ingredientes → NÃO CONSUMIR.
/// - Declarado como traço ou dentro de "pode conter" → ATENÇÃO; alergia
///   grave → NÃO CONSUMIR.
/// - Traços de trigo/centeio/cevada/aveia contam como glúten → NÃO CONSUMIR
///   para glúten (orientação da Anvisa).
/// - Ingrediente ambíguo ("aroma de manteiga") → ATENÇÃO.
/// - "Zero/sem/isento de lactose" anula lactose, nunca leite (APLV).
class AllergenEngine {
  const AllergenEngine(this.dictionary);

  final AllergenDictionary dictionary;

  /// [people] são as pessoas selecionadas ("Quem vai comer?").
  GroupVerdict evaluate(Product? product, List<Person> people) {
    final analysis = product == null || product.ingredientsText.trim().isEmpty
        ? LabelAnalysis.empty
        : analyzeLabel(product.ingredientsText, dictionary);
    final contains = dictionary.expandDeclared(
      product?.allergensContains ?? const {},
    );
    final traces = dictionary.expandDeclared(
      product?.allergensTraces ?? const {},
    );

    final verdicts = [
      for (final person in people)
        _evaluatePerson(person, product, analysis, contains, traces),
    ];
    return GroupVerdict(
      status: VerdictStatus.worstOf(verdicts.map((v) => v.status)),
      people: verdicts,
    );
  }

  PersonVerdict _evaluatePerson(
    Person person,
    Product? product,
    LabelAnalysis analysis,
    Set<Allergen> contains,
    Set<Allergen> traces,
  ) {
    final reasons = <VerdictReason>{};

    if (product == null) {
      reasons.add(
        const VerdictReason(
          status: VerdictStatus.inconclusive,
          kind: ReasonKind.productNotFound,
        ),
      );
    } else {
      for (final allergy in person.allergies) {
        reasons.addAll(_reasonsFor(allergy, analysis, contains, traces));
      }
      if (!product.hasUsableIngredients) {
        reasons.add(
          const VerdictReason(
            status: VerdictStatus.inconclusive,
            kind: ReasonKind.noIngredients,
          ),
        );
      }
    }

    final sorted = reasons.toList();
    final order = {for (final (i, r) in sorted.indexed) r: i};
    sorted.sort((a, b) {
      final bySeverity = b.status.severity.compareTo(a.status.severity);
      return bySeverity != 0 ? bySeverity : order[a]!.compareTo(order[b]!);
    });

    return PersonVerdict(
      personId: person.id,
      personName: person.name,
      status: sorted.isEmpty
          ? VerdictStatus.safe
          : VerdictStatus.worstOf(sorted.map((r) => r.status)),
      reasons: sorted,
    );
  }

  Iterable<VerdictReason> _reasonsFor(
    PersonAllergy allergy,
    LabelAnalysis analysis,
    Set<Allergen> contains,
    Set<Allergen> traces,
  ) sync* {
    final allergen = allergy.allergen;
    final annulled = allergen == Allergen.lactose && analysis.lactoseFree;

    if (!annulled && contains.contains(allergen)) {
      yield VerdictReason(
        status: VerdictStatus.doNotConsume,
        kind: ReasonKind.contains,
        source: ReasonSource.declaredContains,
        allergen: allergen,
      );
    }
    if (!annulled && traces.contains(allergen)) {
      yield _traceReason(allergy, source: ReasonSource.declaredTraces);
    }

    for (final match in analysis.matchesFor(allergen)) {
      yield switch (match.kind) {
        TextMatchKind.contains => VerdictReason(
          status: VerdictStatus.doNotConsume,
          kind: ReasonKind.contains,
          source: ReasonSource.ingredientsText,
          allergen: allergen,
          excerpt: match.excerpt,
          approximate: match.approximate,
        ),
        TextMatchKind.ambiguous => VerdictReason(
          status: VerdictStatus.caution,
          kind: ReasonKind.ambiguous,
          source: ReasonSource.ingredientsText,
          allergen: allergen,
          excerpt: match.excerpt,
          approximate: match.approximate,
        ),
        TextMatchKind.traces => _traceReason(
          allergy,
          source: ReasonSource.ingredientsText,
          excerpt: match.excerpt,
          approximate: match.approximate,
        ),
      };
    }
  }

  VerdictReason _traceReason(
    PersonAllergy allergy, {
    required ReasonSource source,
    String? excerpt,
    bool approximate = false,
  }) {
    final (status, escalation) = switch (allergy) {
      PersonAllergy(allergen: Allergen.gluten) => (
        VerdictStatus.doNotConsume,
        Escalation.glutenTraceRule,
      ),
      PersonAllergy(severity: AllergySeverity.severe) => (
        VerdictStatus.doNotConsume,
        Escalation.severeAllergy,
      ),
      _ => (VerdictStatus.caution, Escalation.none),
    };
    return VerdictReason(
      status: status,
      kind: ReasonKind.traces,
      source: source,
      allergen: allergy.allergen,
      excerpt: excerpt,
      approximate: approximate,
      escalation: escalation,
    );
  }
}
