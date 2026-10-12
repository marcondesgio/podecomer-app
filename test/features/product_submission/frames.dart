import 'dart:typed_data';

import 'package:pode_comer/features/product_submission/domain/auto_capture.dart';

/// Quadro com bordas fortes (texto em foco).
LumaFrame sharpFrame({int shift = 0}) {
  const w = 32, h = 24;
  final luma = Uint8List(w * h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      luma[y * w + x] = ((x + y + shift) % 2 == 0) ? 0 : 255;
    }
  }
  return LumaFrame(w, h, luma);
}

/// Quadro desfocado (sem bordas).
LumaFrame blurryFrame() =>
    LumaFrame(32, 24, Uint8List(32 * 24)..fillRange(0, 32 * 24, 128));
