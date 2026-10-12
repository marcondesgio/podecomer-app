import 'allergen.dart';
import 'allergen_dictionary.dart';
import 'text_normalizer.dart';
import 'token_matcher.dart';

enum TextMatchKind { contains, traces, ambiguous }

/// Ocorrência de um alergênico no texto de ingredientes.
class TextMatch {
  const TextMatch({
    required this.allergen,
    required this.kind,
    required this.excerpt,
    required this.approximate,
    required this.start,
    required this.end,
  });

  final Allergen allergen;
  final TextMatchKind kind;

  /// Posição do termo encontrado no texto original, `[start, end)`; serve
  /// para destacá-lo (ex.: no campo editável do cadastro).
  final int start;
  final int end;

  /// Trecho do texto original. Para traços, inclui a frase gatilho
  /// ("Pode conter amendoim").
  final String excerpt;
  final bool approximate;
}

class LabelAnalysis {
  const LabelAnalysis({required this.lactoseFree, required this.matches});

  static const empty = LabelAnalysis(lactoseFree: false, matches: {});

  /// O rótulo alega "zero/sem/isento de lactose".
  final bool lactoseFree;
  final Map<Allergen, List<TextMatch>> matches;

  List<TextMatch> matchesFor(Allergen allergen) =>
      matches[allergen] ?? const [];
}

/// Cláusula "pode conter ...": de [triggerStart] (início da frase gatilho)
/// a [to]; alergênicos entre [from] e [to] são traços.
class _TraceClause {
  const _TraceClause(this.triggerStart, this.from, this.to);

  final int triggerStart;
  final int from;
  final int to;

  bool covers(Span span) => from <= span.start && span.end <= to;
}

class _Candidate {
  const _Candidate(this.span, this.kind);

  final Span span;
  final TextMatchKind kind;
}

/// Encontra todos os alergênicos do dicionário em [text].
LabelAnalysis analyzeLabel(String text, AllergenDictionary dictionary) {
  final tokens = tokenize(text);
  if (tokens.isEmpty) return LabelAnalysis.empty;
  final matcher = TokenMatcher(tokens, dictionary.vocabulary);

  List<Span> findAll(Iterable<List<String>> phrases, MatchMode mode) => [
    for (final phrase in phrases) ...matcher.findAll(phrase, mode),
  ];

  final clauses = _traceClauses(
    tokens,
    _longestNonOverlapping(findAll(dictionary.tracePhrases, MatchMode.ocr)),
    dictionary.clauseStopWords,
  );
  final lactoseClaims = findAll(dictionary.lactoseFreeClaims, MatchMode.strict);
  final negatedStarts = {
    for (final span in findAll(dictionary.negationPrefixes, MatchMode.strict))
      span.end,
  };
  final negatedEnds = {
    for (final span in findAll(dictionary.negationSuffixes, MatchMode.strict))
      span.start,
  };

  final matches = <Allergen, List<TextMatch>>{};
  for (final entry in dictionary.entries.values) {
    final allergen = entry.allergen;
    if (allergen == Allergen.lactose && lactoseClaims.isNotEmpty) continue;

    final exclusions = [
      ...findAll(entry.exclusions, MatchMode.strict),
      // "sem lactose" não é leite nem lactose.
      if (allergen == Allergen.lactose || allergen == Allergen.milk)
        ...lactoseClaims,
    ];

    final candidates =
        [
          for (final span in findAll(entry.terms, MatchMode.fuzzy))
            _Candidate(span, TextMatchKind.contains),
          for (final span in findAll(entry.ambiguous, MatchMode.fuzzy))
            _Candidate(span, TextMatchKind.ambiguous),
        ].where(
          (c) =>
              !exclusions.any(c.span.overlaps) &&
              !negatedStarts.contains(c.span.start) &&
              !negatedEnds.contains(c.span.end),
        );

    final found = <TextMatch>[];
    for (final candidate in _resolveOverlaps(candidates)) {
      final span = candidate.span;
      final clause = clauses.where((c) => c.covers(span)).firstOrNull;
      final excerptStart = clause?.triggerStart ?? span.start;
      found.add(
        TextMatch(
          allergen: allergen,
          kind: clause == null ? candidate.kind : TextMatchKind.traces,
          excerpt: text.substring(
            tokens[excerptStart].start,
            tokens[span.end - 1].end,
          ),
          approximate: span.approximate,
          start: tokens[span.start].start,
          end: tokens[span.end - 1].end,
        ),
      );
    }
    if (found.isNotEmpty) matches[allergen] = found;
  }

  return LabelAnalysis(lactoseFree: lactoseClaims.isNotEmpty, matches: matches);
}

List<_TraceClause> _traceClauses(
  List<Token> tokens,
  List<Span> triggers,
  Set<String> stopWords,
) {
  final triggerStarts = {for (final t in triggers) t.start};
  return [
    for (final trigger in triggers)
      _TraceClause(trigger.start, trigger.end, () {
        var k = trigger.end;
        while (k < tokens.length &&
            !tokens[k].isBoundary &&
            !stopWords.contains(tokens[k].text) &&
            !triggerStarts.contains(k)) {
          k++;
        }
        return k;
      }()),
  ];
}

List<Span> _longestNonOverlapping(List<Span> spans) {
  final sorted = [...spans]
    ..sort((a, b) {
      final byLength = b.length.compareTo(a.length);
      return byLength != 0 ? byLength : a.start.compareTo(b.start);
    });
  final accepted = <Span>[];
  for (final span in sorted) {
    if (!accepted.any(span.overlaps)) accepted.add(span);
  }
  return accepted;
}

/// Entre casamentos sobrepostos do mesmo alergênico vence o mais longo
/// ("aroma de manteiga" vence "manteiga"); empate → "contém".
List<_Candidate> _resolveOverlaps(Iterable<_Candidate> candidates) {
  final sorted = [...candidates]
    ..sort((a, b) {
      final byLength = b.span.length.compareTo(a.span.length);
      if (byLength != 0) return byLength;
      final byKind = a.kind.index.compareTo(b.kind.index);
      if (byKind != 0) return byKind;
      return a.span.start.compareTo(b.span.start);
    });
  final accepted = <_Candidate>[];
  for (final candidate in sorted) {
    if (!accepted.any((c) => c.span.overlaps(candidate.span))) {
      accepted.add(candidate);
    }
  }
  accepted.sort((a, b) => a.span.start.compareTo(b.span.start));
  return accepted;
}
