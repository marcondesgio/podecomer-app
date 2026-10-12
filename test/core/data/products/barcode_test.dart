import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/products/barcode.dart';

void main() {
  group('normalizeScannedBarcode', () {
    test('EAN-13 válido passa igual', () {
      expect(normalizeScannedBarcode('7891000100103'), '7891000100103');
    });

    test('EAN-8 válido passa igual', () {
      expect(normalizeScannedBarcode('78910003'), '78910003');
    });

    test('UPC-A vira EAN-13 com zero à esquerda', () {
      expect(normalizeScannedBarcode('036000291452'), '0036000291452');
    });

    test('dígito verificador errado (leitura falha) é recusado', () {
      expect(normalizeScannedBarcode('7891000100104'), isNull);
      expect(normalizeScannedBarcode('78910004'), isNull);
    });

    test('formatos e caracteres inesperados são recusados', () {
      expect(normalizeScannedBarcode('12345'), isNull);
      expect(normalizeScannedBarcode('789100010010A'), isNull);
      expect(normalizeScannedBarcode('https://exemplo.com'), isNull);
    });
  });

  group('ScanDebouncer', () {
    test('ignora o mesmo código dentro da janela', () {
      var now = DateTime(2026);
      final debouncer = ScanDebouncer(now: () => now);

      expect(debouncer.accept('7891000100103'), isTrue);
      now = now.add(const Duration(milliseconds: 500));
      expect(debouncer.accept('7891000100103'), isFalse);
      now = now.add(const Duration(seconds: 2));
      expect(debouncer.accept('7891000100103'), isFalse);
    });

    test('aceita de novo depois da janela', () {
      var now = DateTime(2026);
      final debouncer = ScanDebouncer(now: () => now);
      debouncer.accept('7891000100103');
      now = now.add(const Duration(seconds: 3));
      expect(debouncer.accept('7891000100103'), isTrue);
    });

    test('código diferente é aceito na hora', () {
      final debouncer = ScanDebouncer(now: () => DateTime(2026));
      expect(debouncer.accept('7891000100103'), isTrue);
      expect(debouncer.accept('7891000100110'), isTrue);
    });
  });
}
