/// Código lido pela câmera → GTIN válido, ou `null`.
///
/// - UPC-A (12 dígitos) vira EAN-13 com zero à esquerda, como o iOS já faz
///   e como o Open Food Facts indexa.
/// - O dígito verificador é conferido: uma leitura errada poderia trazer
///   outro produto e, com ele, um veredito errado.
String? normalizeScannedBarcode(String raw) {
  final digits = raw.trim();
  if (!RegExp(r'^\d+$').hasMatch(digits)) return null;
  final code = switch (digits.length) {
    12 => '0$digits',
    8 || 13 => digits,
    _ => null,
  };
  return code != null && hasValidCheckDigit(code) ? code : null;
}

/// Dígito verificador GS1 (EAN-8, UPC-A, EAN-13, GTIN-14).
bool hasValidCheckDigit(String code) {
  if (code.length < 8 || !RegExp(r'^\d+$').hasMatch(code)) return false;
  var sum = 0;
  // Da direita para a esquerda, sem o dígito verificador: pesos 3, 1, 3...
  for (var i = code.length - 2, weight = 3; i >= 0; i--) {
    sum += int.parse(code[i]) * weight;
    weight = weight == 3 ? 1 : 3;
  }
  final check = (10 - sum % 10) % 10;
  return check == int.parse(code[code.length - 1]);
}

/// Ignora o mesmo código lido de novo dentro de [window] (a câmera lê
/// várias vezes por segundo).
class ScanDebouncer {
  ScanDebouncer({
    this.window = const Duration(seconds: 3),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final Duration window;
  final DateTime Function() _now;
  String? _lastCode;
  DateTime? _lastAt;

  bool accept(String code) {
    final now = _now();
    final last = _lastAt;
    if (code == _lastCode && last != null && now.difference(last) < window) {
      return false;
    }
    _lastCode = code;
    _lastAt = now;
    return true;
  }
}
