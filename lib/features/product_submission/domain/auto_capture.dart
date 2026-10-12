import 'dart:math' as math;
import 'dart:typed_data';

/// Quadro da câmera reduzido a uma grade de luminância (0–255).
class LumaFrame {
  LumaFrame(this.width, this.height, this.luma)
    : assert(luma.length == width * height);

  final int width;
  final int height;
  final Uint8List luma;

  int at(int x, int y) => luma[y * width + x];
}

class FrameAssessment {
  const FrameAssessment({
    required this.sharpness,
    required this.motion,
    required this.stableFrames,
    required this.ready,
  });

  /// Variância do laplaciano: alta = bordas nítidas (texto em foco).
  final double sharpness;

  /// Diferença média para o quadro anterior: baixa = câmera parada.
  final double motion;

  /// Quadros seguidos nítidos e parados.
  final int stableFrames;

  /// Hora de tirar a foto.
  final bool ready;

  /// 0–1, para mostrar o progresso ("segure firme").
  double progress(int required) => math.min(1, stableFrames / required);
}

/// Decide quando capturar: imagem nítida e parada por alguns quadros.
///
/// Os limites são um ponto de partida; ajuste em aparelho real. A tela
/// sempre oferece o botão manual.
class AutoCaptureDetector {
  AutoCaptureDetector({
    this.minSharpness = 120,
    this.maxMotion = 6,
    this.requiredStableFrames = 4,
  });

  final double minSharpness;
  final double maxMotion;

  /// Com análise a cada ~150 ms, 4 quadros ≈ 0,6 s parado.
  final int requiredStableFrames;

  LumaFrame? _previous;
  var _stable = 0;

  void reset() {
    _previous = null;
    _stable = 0;
  }

  FrameAssessment add(LumaFrame frame) {
    final sharpness = laplacianVariance(frame);
    final previous = _previous;
    final motion =
        previous == null ||
            previous.width != frame.width ||
            previous.height != frame.height
        ? double.infinity
        : meanAbsoluteDifference(previous, frame);
    _previous = frame;

    final good = sharpness >= minSharpness && motion <= maxMotion;
    _stable = good ? _stable + 1 : 0;
    return FrameAssessment(
      sharpness: sharpness,
      motion: motion,
      stableFrames: _stable,
      ready: _stable >= requiredStableFrames,
    );
  }
}

/// Variância do laplaciano (kernel 4-vizinhos) sobre a grade.
double laplacianVariance(LumaFrame f) {
  if (f.width < 3 || f.height < 3) return 0;
  var sum = 0.0;
  var sumSq = 0.0;
  var n = 0;
  for (var y = 1; y < f.height - 1; y++) {
    for (var x = 1; x < f.width - 1; x++) {
      final lap =
          f.at(x - 1, y) +
          f.at(x + 1, y) +
          f.at(x, y - 1) +
          f.at(x, y + 1) -
          4 * f.at(x, y);
      sum += lap;
      sumSq += lap * lap;
      n++;
    }
  }
  final mean = sum / n;
  return sumSq / n - mean * mean;
}

double meanAbsoluteDifference(LumaFrame a, LumaFrame b) {
  var total = 0;
  for (var i = 0; i < a.luma.length; i++) {
    total += (a.luma[i] - b.luma[i]).abs();
  }
  return total / a.luma.length;
}
