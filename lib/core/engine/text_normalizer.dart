/// Normalização e tokenização de texto de rótulo.
///
/// Cada caractere normalizado corresponde a um caractere do original, então
/// os tokens guardam o intervalo exato no texto de entrada (para citar o
/// trecho do rótulo nos motivos).
library;

const _accents = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', //
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ç': 'c', 'ñ': 'n',
};

/// Encerram uma frase (e, portanto, uma cláusula "pode conter").
const _sentenceEnds = {'.', ';', '!', '?'};

/// Palavras que indicam que a frase continua na próxima linha.
const _connectives = {'e', 'de', 'do', 'da', 'dos', 'das', 'com', 'ou', 'em'};

/// Minúscula e sem acento.
String normalizeChar(String char) {
  final lower = char.toLowerCase();
  return _accents[lower] ?? lower;
}

/// Texto normalizado: minúsculas, sem acentos, sem pontuação, um espaço entre
/// palavras.
String normalizeText(String input) =>
    tokenize(input).where((t) => !t.isBoundary).map((t) => t.text).join(' ');

class Token {
  const Token(this.text, this.start, this.end) : isBoundary = false;

  /// Fim de frase.
  const Token.boundary(this.start) : text = '', end = start, isBoundary = true;

  /// Palavra normalizada (`[a-z0-9]+`).
  final String text;

  /// Intervalo `[start, end)` no texto original.
  final int start;
  final int end;
  final bool isBoundary;

  @override
  String toString() => isBoundary ? '|' : text;
}

/// Quebra o texto em palavras normalizadas e marcadores de fim de frase.
///
/// - Pontuação comum (vírgula, dois-pontos, parênteses, hífen) separa palavras.
/// - `. ; ! ?` (exceto ponto decimal) e quebras de linha que encerram frase
///   viram [Token.boundary]; repetições colapsam em um só.
/// - Palavra hifenizada na quebra de linha ("amen-\ndoim") é reunida.
List<Token> tokenize(String input) {
  final tokens = <Token>[];
  final buffer = StringBuffer();
  var start = 0;
  var end = 0;

  void flush() {
    if (buffer.isEmpty) return;
    tokens.add(Token(buffer.toString(), start, end));
    buffer.clear();
  }

  void boundary(int at) {
    flush();
    if (tokens.isNotEmpty && !tokens.last.isBoundary) {
      tokens.add(Token.boundary(at));
    }
  }

  var i = 0;
  while (i < input.length) {
    final raw = input[i];
    final char = normalizeChar(raw);

    if (_isWordChar(char)) {
      if (buffer.isEmpty) start = i;
      buffer.write(char);
      end = i + 1;
      i++;
      continue;
    }

    if ((raw == '-' || raw == '­') && buffer.isNotEmpty) {
      final resume = _afterHyphenatedLineBreak(input, i + 1);
      if (resume != null) {
        i = resume;
        continue;
      }
    }

    if (raw == '\n' || raw == '\r') {
      flush();
      if (_newlineEndsSentence(input, i, tokens)) boundary(i);
      i++;
      continue;
    }

    if (_sentenceEnds.contains(raw)) {
      final isDecimalPoint =
          raw == '.' &&
          buffer.isNotEmpty &&
          _isDigit(input[i - 1]) &&
          i + 1 < input.length &&
          _isDigit(input[i + 1]);
      if (isDecimalPoint) {
        flush();
      } else {
        boundary(i);
      }
      i++;
      continue;
    }

    flush();
    i++;
  }
  flush();
  return tokens;
}

bool _isWordChar(String char) {
  final unit = char.codeUnitAt(0);
  return (unit >= 0x61 && unit <= 0x7a) || (unit >= 0x30 && unit <= 0x39);
}

bool _isDigit(String char) {
  final unit = char.codeUnitAt(0);
  return unit >= 0x30 && unit <= 0x39;
}

bool _isInlineSpace(String char) => char == ' ' || char == '\t' || char == ' ';

bool _isLineBreak(String char) => char == '\n' || char == '\r';

/// Se depois do hífen vierem só espaços com uma quebra de linha e então uma
/// letra, devolve o índice dessa letra.
int? _afterHyphenatedLineBreak(String input, int from) {
  var k = from;
  var sawLineBreak = false;
  while (k < input.length &&
      (_isInlineSpace(input[k]) || _isLineBreak(input[k]))) {
    if (_isLineBreak(input[k])) sawLineBreak = true;
    k++;
  }
  if (!sawLineBreak || k >= input.length) return null;
  return _isWordChar(normalizeChar(input[k])) ? k : null;
}

/// Quebra de linha só encerra a frase se a linha não terminar em vírgula,
/// hífen ou conectivo (listas de ingredientes costumam quebrar no meio).
bool _newlineEndsSentence(String input, int at, List<Token> tokens) {
  var k = at - 1;
  while (k >= 0 && (_isInlineSpace(input[k]) || _isLineBreak(input[k]))) {
    k--;
  }
  if (k < 0) return false;
  if (input[k] == ',' || input[k] == '-') return false;
  final last = tokens.isEmpty ? null : tokens.last;
  if (last != null && !last.isBoundary && _connectives.contains(last.text)) {
    return false;
  }
  return true;
}
