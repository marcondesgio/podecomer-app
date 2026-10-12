import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Reduz a foto para envio: lado maior até [maxSide] px e JPEG [quality].
/// Corrige a orientação do EXIF e descarta os metadados (sem localização).
/// Pesado: rode com `compute`.
Uint8List compressJpeg(
  Uint8List bytes, {
  int maxSide = 1600,
  int quality = 80,
}) {
  // O plugin camera grava JPEG; outros formatos são recusados.
  final isJpeg =
      bytes.length > 3 &&
      bytes[0] == 0xFF &&
      bytes[1] == 0xD8 &&
      bytes[2] == 0xFF;
  final decoded = isJpeg ? img.decodeJpg(bytes) : null;
  if (decoded == null) throw const FormatException('Imagem inválida.');
  var image = img.bakeOrientation(decoded);
  final longest = image.width > image.height ? image.width : image.height;
  if (longest > maxSide) {
    image = image.width >= image.height
        ? img.copyResize(image, width: maxSide)
        : img.copyResize(image, height: maxSide);
  }
  image.exif.clear();
  return img.encodeJpg(image, quality: quality);
}
