import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pode_comer/core/engine/allergen.dart';
import 'package:pode_comer/core/engine/label_analyzer.dart';
import 'package:pode_comer/core/theme/app_theme.dart';
import 'package:pode_comer/features/product_submission/data/submission_repository.dart';
import 'package:pode_comer/features/product_submission/domain/auto_capture.dart';
import 'package:pode_comer/features/product_submission/domain/image_compression.dart';
import 'package:pode_comer/features/product_submission/presentation/allergen_highlight_controller.dart';

import '../../core/engine/engine_test_helpers.dart';
import 'frames.dart';

void main() {
  group('captura automática', () {
    test('imagem nítida e parada dispara depois de N quadros', () {
      final detector = AutoCaptureDetector(requiredStableFrames: 3);
      // O 1º quadro não tem com o que comparar movimento.
      expect(detector.add(sharpFrame()).ready, isFalse);
      expect(detector.add(sharpFrame()).ready, isFalse);
      expect(detector.add(sharpFrame()).ready, isFalse);
      expect(detector.add(sharpFrame()).ready, isTrue);
    });

    test('imagem desfocada nunca dispara', () {
      final detector = AutoCaptureDetector(requiredStableFrames: 2);
      for (var i = 0; i < 10; i++) {
        expect(detector.add(blurryFrame()).ready, isFalse);
      }
    });

    test('movimento zera a contagem', () {
      final detector = AutoCaptureDetector(requiredStableFrames: 3);
      detector.add(sharpFrame());
      detector.add(sharpFrame());
      expect(detector.add(sharpFrame()).stableFrames, 2);
      // Câmera mexeu: o padrão deslocou um pixel.
      final moved = detector.add(sharpFrame(shift: 1));
      expect(moved.motion, greaterThan(100));
      expect(moved.stableFrames, 0);
    });

    test('nitidez mede bordas', () {
      expect(laplacianVariance(sharpFrame()), greaterThan(1000));
      expect(laplacianVariance(blurryFrame()), 0);
    });
  });

  group('compressão', () {
    test('reduz para no máximo 1600 px e gera JPEG menor', () {
      final big = img.Image(width: 3200, height: 2400);
      for (final pixel in big) {
        pixel
          ..r = (pixel.x * 7) % 256
          ..g = (pixel.y * 3) % 256
          ..b = (pixel.x + pixel.y) % 256;
      }
      final original = img.encodeJpg(big, quality: 100);

      final compressed = compressJpeg(original);
      final decoded = img.decodeJpg(compressed)!;
      expect(decoded.width, 1600);
      expect(decoded.height, 1200);
      expect(compressed.length, lessThan(original.length));
    });

    test('foto em pé mantém a proporção', () {
      final tall = img.encodeJpg(img.Image(width: 1000, height: 2000));
      final decoded = img.decodeJpg(compressJpeg(tall))!;
      expect((decoded.width, decoded.height), (800, 1600));
    });

    test('bytes inválidos são recusados', () {
      expect(
        () => compressJpeg(Uint8List.fromList([1, 2, 3])),
        throwsFormatException,
      );
    });
  });

  test('fotos ficam na pasta do usuário, por código de barras', () {
    final paths = submissionPaths('user-1', '7891000100103', 42);
    expect(paths.front, 'user-1/7891000100103/front_42.jpg');
    expect(paths.ingredients, 'user-1/7891000100103/ingredients_42.jpg');
  });

  group('destaque dos termos', () {
    final dictionary = loadDictionary();

    test('o motor informa a posição exata do termo', () {
      const text = 'Açúcar, Farinha de Trigo. Pode conter amendoim.';
      final analysis = analyzeLabel(text, dictionary);
      final wheat = analysis.matchesFor(Allergen.wheat).single;
      expect(text.substring(wheat.start, wheat.end), 'Farinha de Trigo');
      final peanut = analysis.matchesFor(Allergen.peanut).single;
      expect(text.substring(peanut.start, peanut.end), 'amendoim');
      expect(peanut.kind, TextMatchKind.traces);
    });

    test('junta sobreposições; "contém" vence traço', () {
      final controller = AllergenHighlightController(
        dictionary: dictionary,
        text: 'Leite em pó, aroma de manteiga. Pode conter amendoim.',
      );
      final ranges = [
        for (final h in controller.highlights())
          (controller.text.substring(h.start, h.end), h.contains),
      ];
      expect(ranges, [
        ('Leite em pó', true),
        ('aroma de manteiga', false),
        ('amendoim', false),
      ]);
    });

    testWidgets('pinta os termos no campo de texto', (tester) async {
      final controller = AllergenHighlightController(
        dictionary: dictionary,
        text: 'Açúcar, farinha de trigo.',
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: TextField(controller: controller)),
        ),
      );
      final span = controller.buildTextSpan(
        context: tester.element(find.byType(TextField)),
        withComposing: false,
      );
      final highlighted = span.children!
          .cast<TextSpan>()
          .where((s) => s.style?.backgroundColor != null)
          .map((s) => s.text)
          .toList();
      expect(highlighted, ['farinha de trigo']);
    });
  });
}
