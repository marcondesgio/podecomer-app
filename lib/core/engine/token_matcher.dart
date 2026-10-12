import 'text_normalizer.dart';

/// Quanto o casamento tolera erros de leitura.
enum MatchMode {
  /// Igualdade (com plural -s/-es). Usado em exclusões, negações e
  /// alegações "zero lactose": se falharem, o resultado fica mais severo.
  strict,

  /// [strict] + confusões típicas de OCR (0/o, 1/l/i, rn/m, m/n, 5/s) e
  /// palavra partida em duas ("amen doim").
  ocr,

  /// [ocr] + uma edição (troca, inserção, remoção ou transposição) em termos
  /// com 8+ letras.
  fuzzy,
}

/// Intervalo de tokens `[start, end)`.
class Span {
  const Span(this.start, this.end, {this.approximate = false});

  final int start;
  final int end;

  /// Casou por tolerância a OCR.
  final bool approximate;

  int get length => end - start;

  bool overlaps(Span other) => start < other.end && other.start < end;
}

enum _Quality { none, exact, approximate }

class TokenMatcher {
  TokenMatcher(this.tokens, this.vocabulary);

  final List<Token> tokens;

  /// Palavras reais: nunca tratadas como erro de OCR de outra palavra
  /// (evita "avelã" virar "aveia").
  final Set<String> vocabulary;

  bool isKnownWord(String word) =>
      vocabulary.contains(word) ||
      (word.endsWith('s') &&
          vocabulary.contains(word.substring(0, word.length - 1))) ||
      (word.endsWith('es') &&
          vocabulary.contains(word.substring(0, word.length - 2)));

  /// Todas as ocorrências de [phrase].
  List<Span> findAll(List<String> phrase, MatchMode mode) => [
    for (var i = 0; i < tokens.length; i++) ?matchAt(i, phrase, mode),
  ];

  Span? matchAt(int index, List<String> phrase, MatchMode mode) {
    var j = index;
    var approximate = false;
    for (final part in phrase) {
      if (j >= tokens.length || tokens[j].isBoundary) return null;

      final quality = _compare(tokens[j].text, part, mode);
      if (quality != _Quality.none) {
        approximate |= quality == _Quality.approximate;
        j++;
        continue;
      }

      // Palavra partida pelo OCR: "amen doim" → "amendoim".
      if (mode != MatchMode.strict &&
          j + 1 < tokens.length &&
          !tokens[j + 1].isBoundary &&
          !isKnownWord(tokens[j].text) &&
          !isKnownWord(tokens[j + 1].text)) {
        final joined = tokens[j].text + tokens[j + 1].text;
        if (_compare(joined, part, MatchMode.ocr) != _Quality.none) {
          approximate = true;
          j += 2;
          continue;
        }
      }
      return null;
    }
    return Span(index, j, approximate: approximate);
  }

  _Quality _compare(String token, String term, MatchMode mode) {
    if (token == term || token == '${term}s' || token == '${term}es') {
      return _Quality.exact;
    }
    if (mode == MatchMode.strict || isKnownWord(token)) return _Quality.none;

    final canonical = ocrCanonical(token);
    if (canonical == ocrCanonical(term) ||
        canonical == ocrCanonical('${term}s') ||
        canonical == ocrCanonical('${term}es')) {
      return _Quality.approximate;
    }
    if (mode == MatchMode.fuzzy &&
        term.length >= 8 &&
        withinOneEdit(token, term)) {
      return _Quality.approximate;
    }
    return _Quality.none;
  }
}

/// Colapsa caracteres que o OCR confunde entre si.
String ocrCanonical(String word) {
  final buffer = StringBuffer();
  for (final char in word.replaceAll('rn', 'm').split('')) {
    buffer.write(switch (char) {
      '0' => 'o',
      '1' || 'i' => 'l',
      'm' => 'n',
      '5' => 's',
      _ => char,
    });
  }
  return buffer.toString();
}

/// Distância de edição (com transposição adjacente) ≤ 1.
bool withinOneEdit(String a, String b) {
  if (a == b) return true;
  if ((a.length - b.length).abs() > 1) return false;

  if (a.length == b.length) {
    final diffs = <int>[];
    for (var k = 0; k < a.length; k++) {
      if (a[k] != b[k]) {
        diffs.add(k);
        if (diffs.length > 2) return false;
      }
    }
    if (diffs.length == 1) return true;
    return diffs[1] == diffs[0] + 1 &&
        a[diffs[0]] == b[diffs[1]] &&
        a[diffs[1]] == b[diffs[0]];
  }

  final (shorter, longer) = a.length < b.length ? (a, b) : (b, a);
  var i = 0;
  var j = 0;
  var skipped = false;
  while (i < shorter.length && j < longer.length) {
    if (shorter[i] == longer[j]) {
      i++;
      j++;
    } else {
      if (skipped) return false;
      skipped = true;
      j++;
    }
  }
  return true;
}
