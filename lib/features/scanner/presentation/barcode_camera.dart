import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Câmera de leitura. Atrás de uma interface para a tela ser testável sem
/// câmera (ver `barcodeCameraProvider`).
abstract class BarcodeCamera {
  Widget build(
    BuildContext context, {
    required ValueChanged<String> onCode,
    required WidgetBuilder errorBuilder,
  });

  ValueNotifier<bool> get torchOn;
  Future<void> toggleTorch();
  Future<void> pause();
  Future<void> resume();
  void dispose();
}

final barcodeCameraProvider = Provider<BarcodeCamera Function()>(
  (ref) => MobileScannerCamera.new,
);

class MobileScannerCamera implements BarcodeCamera {
  MobileScannerCamera() {
    _controller.addListener(() {
      torchOn.value = _controller.value.torchState == TorchState.on;
    });
  }

  final _controller = MobileScannerController(
    formats: const [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
    ],
  );

  @override
  final torchOn = ValueNotifier(false);

  @override
  Widget build(
    BuildContext context, {
    required ValueChanged<String> onCode,
    required WidgetBuilder errorBuilder,
  }) => MobileScanner(
    controller: _controller,
    onDetect: (capture) {
      for (final barcode in capture.barcodes) {
        if (barcode.rawValue case final value?) onCode(value);
      }
    },
    errorBuilder: (context, _) => errorBuilder(context),
  );

  @override
  Future<void> toggleTorch() => _controller.toggleTorch();

  @override
  Future<void> pause() => _controller.stop();

  @override
  Future<void> resume() => _controller.start();

  @override
  void dispose() {
    torchOn.dispose();
    _controller.dispose();
  }
}
