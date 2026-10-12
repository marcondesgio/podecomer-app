import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/auto_capture.dart';

/// Foto capturada: arquivo (para o OCR) e bytes (para o envio).
class CapturedPhoto {
  const CapturedPhoto({required this.path, required this.bytes});

  final String path;
  final Uint8List bytes;
}

/// Câmera ao vivo para fotografar a embalagem. Nunca galeria.
abstract class DocumentCamera {
  Future<void> initialize();
  Widget preview();

  /// Quadros reduzidos para a captura automática (≈ 1 a cada 150 ms).
  void startFrames(ValueChanged<LumaFrame> onFrame);
  Future<void> stopFrames();
  Future<CapturedPhoto> capture();
  Future<void> dispose();
}

final documentCameraProvider = Provider<DocumentCamera Function()>(
  (ref) => PluginDocumentCamera.new,
);

class PluginDocumentCamera implements DocumentCamera {
  static const _frameInterval = Duration(milliseconds: 150);
  static const _gridWidth = 96;

  CameraController? _controller;
  var _streaming = false;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  Future<void> initialize() async {
    final cameras = await availableCameras();
    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final controller = CameraController(
      back,
      // Resolução alta: o OCR precisa de letras pequenas legíveis.
      ResolutionPreset.veryHigh,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    await controller.setFocusMode(FocusMode.auto);
    _controller = controller;
  }

  @override
  Widget preview() {
    final controller = _controller;
    return controller == null
        ? const SizedBox.shrink()
        : CameraPreview(controller);
  }

  @override
  void startFrames(ValueChanged<LumaFrame> onFrame) {
    final controller = _controller;
    if (controller == null || _streaming) return;
    _streaming = true;
    controller.startImageStream((image) {
      final now = DateTime.now();
      if (now.difference(_lastFrame) < _frameInterval) return;
      _lastFrame = now;
      onFrame(lumaFromCameraImage(image, gridWidth: _gridWidth));
    });
  }

  @override
  Future<void> stopFrames() async {
    if (!_streaming) return;
    _streaming = false;
    await _controller?.stopImageStream();
  }

  @override
  Future<CapturedPhoto> capture() async {
    await stopFrames();
    final file = await _controller!.takePicture();
    return CapturedPhoto(path: file.path, bytes: await file.readAsBytes());
  }

  @override
  Future<void> dispose() async {
    await stopFrames();
    await _controller?.dispose();
    _controller = null;
  }
}

/// Reduz o quadro a uma grade de luminância. Android (YUV420): plano Y.
/// iOS (BGRA): luminância calculada de B, G e R.
LumaFrame lumaFromCameraImage(CameraImage image, {required int gridWidth}) {
  final plane = image.planes.first;
  final bgra = image.format.group == ImageFormatGroup.bgra8888;
  final step = (image.width / gridWidth).ceil().clamp(1, 1 << 20);
  final w = image.width ~/ step;
  final h = image.height ~/ step;
  final out = Uint8List(w * h);
  final bytes = plane.bytes;
  final pixelStride = bgra ? 4 : (plane.bytesPerPixel ?? 1);

  for (var gy = 0; gy < h; gy++) {
    final row = gy * step * plane.bytesPerRow;
    for (var gx = 0; gx < w; gx++) {
      final i = row + gx * step * pixelStride;
      out[gy * w + gx] = bgra
          ? (bytes[i] * 114 + bytes[i + 1] * 587 + bytes[i + 2] * 299) ~/ 1000
          : bytes[i];
    }
  }
  return LumaFrame(w, h, out);
}
