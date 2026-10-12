import 'allergen.dart';
import 'text_normalizer.dart';

/// Frase já normalizada e tokenizada (ex.: "farinha de trigo" →
/// `['farinha', 'de', 'trigo']`).
typedef Phrase = List<String>;

class AllergenEntry {
  const AllergenEntry({
    required this.allergen,
    required this.namePt,
    required this.terms,
    required this.ambiguous,
    required this.exclusions,
  });

  final Allergen allergen;
  final String namePt;

  /// Presença → NÃO CONSUMIR (ou ATENÇÃO se dentro de "pode conter").
  final List<Phrase> terms;

  /// Pode ou não conter → ATENÇÃO.
  final List<Phrase> ambiguous;

  /// Falsos positivos: qualquer casamento sobreposto a estes é descartado
  /// (ex.: "manteiga de cacau" para leite).
  final List<Phrase> exclusions;
}

/// Dicionário de sinônimos e regras textuais, carregado de
/// `assets/engine/allergen_dictionary.json`.
class AllergenDictionary {
  AllergenDictionary._({
    required this.entries,
    required this.declaredImplies,
    required this.tracePhrases,
    required this.clauseStopWords,
    required this.negationPrefixes,
    required this.negationSuffixes,
    required this.lactoseFreeClaims,
    required this.offTags,
    required this.vocabulary,
  });

  /// Lança [FormatException] se o JSON estiver incompleto ou citar códigos
  /// desconhecidos: um dicionário com lacunas é um risco de saúde.
  factory AllergenDictionary.fromJson(Map<String, dynamic> json) {
    final vocabulary = <String>{};

    Phrase phrase(Object? raw) {
      if (raw is! String) throw FormatException('Termo inválido: $raw');
      final tokens = [
        for (final t in tokenize(raw))
          if (!t.isBoundary) t.text,
      ];
      if (tokens.isEmpty) throw FormatException('Termo vazio: "$raw"');
      vocabulary.addAll(tokens);
      return tokens;
    }

    List<Phrase> phrases(Object? raw) => [
      for (final item in (raw as List<dynamic>? ?? const [])) phrase(item),
    ];

    Allergen allergen(String code) =>
        Allergen.fromCode(code) ??
        (throw FormatException('Alergênico desconhecido: $code'));

    final rawEntries = json['allergens'] as Map<String, dynamic>;
    final entries = <Allergen, AllergenEntry>{
      for (final MapEntry(:key, :value) in rawEntries.entries)
        allergen(key): AllergenEntry(
          allergen: allergen(key),
          namePt: (value as Map<String, dynamic>)['name_pt'] as String,
          terms: phrases(value['terms']),
          ambiguous: phrases(value['ambiguous']),
          exclusions: phrases(value['exclusions']),
        ),
    };
    final missing = Allergen.values.where((a) => !entries.containsKey(a));
    if (missing.isNotEmpty) {
      throw FormatException('Dicionário sem: ${missing.map((a) => a.code)}');
    }
    for (final entry in entries.values) {
      if (entry.terms.isEmpty) {
        throw FormatException('${entry.allergen.code} sem termos');
      }
    }

    Map<K, Set<Allergen>> allergenMap<K>(Object? raw, K Function(String) key) =>
        {
          for (final MapEntry(key: k, :value)
              in (raw as Map<String, dynamic>).entries)
            key(k): {for (final code in value as List<dynamic>) allergen(code)},
        };

    final knownWords = <String>{
      for (final word in json['known_words'] as List<dynamic>) ...phrase(word),
    };

    return AllergenDictionary._(
      entries: entries,
      declaredImplies: allergenMap(json['declared_implies'], allergen),
      tracePhrases: phrases(json['trace_phrases']),
      clauseStopWords: {
        for (final word in json['clause_stop_words'] as List<dynamic>)
          ...phrase(word),
      },
      negationPrefixes: phrases(json['negation_prefixes']),
      negationSuffixes: phrases(json['negation_suffixes']),
      lactoseFreeClaims: phrases(json['lactose_free_claims']),
      offTags: allergenMap(json['off_tags'], (k) => k.toLowerCase()),
      vocabulary: {...vocabulary, ...knownWords},
    );
  }

  final Map<Allergen, AllergenEntry> entries;

  /// Declarar X implica também Y (ex.: trigo → glúten).
  final Map<Allergen, Set<Allergen>> declaredImplies;

  /// Iniciam uma cláusula de traços ("pode conter", "traços de"...).
  final List<Phrase> tracePhrases;

  /// Encerram uma cláusula de traços sem pontuação (OCR costuma perdê-la).
  final Set<String> clauseStopWords;

  /// "sem glúten", "não contém glúten": o termo logo depois é ignorado.
  final List<Phrase> negationPrefixes;

  /// "gluten free".
  final List<Phrase> negationSuffixes;

  /// "zero lactose", "sem lactose"...: anulam lactose, nunca leite (APLV).
  final List<Phrase> lactoseFreeClaims;

  /// Tags `allergens_tags` / `traces_tags` do Open Food Facts.
  final Map<String, Set<Allergen>> offTags;

  /// Palavras reais conhecidas: nunca são "corrigidas" como erro de OCR.
  final Set<String> vocabulary;

  /// Inclui os alergênicos implicados (trigo → trigo + glúten).
  Set<Allergen> expandDeclared(Iterable<Allergen> declared) => {
    for (final allergen in declared) ...{
      allergen,
      ...?declaredImplies[allergen],
    },
  };

  /// Converte tags do Open Food Facts; tags sem mapeamento são ignoradas.
  Set<Allergen> allergensFromOffTags(Iterable<String> tags) => {
    for (final tag in tags) ...?offTags[tag.trim().toLowerCase()],
  };
}
