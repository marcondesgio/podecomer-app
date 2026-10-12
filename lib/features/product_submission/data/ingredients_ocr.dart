import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

/// OCR no aparelho (ML Kit): a foto não sai do celular para ser lida.
abstract interface class IngredientsOcr {
  Future<String> read(String imagePath);
}

final ingredientsOcrProvider = Provider<IngredientsOcr>(
  (ref) => const MlKitIngredientsOcr(),
);

class MlKitIngredientsOcr implements IngredientsOcr {
  const MlKitIngredientsOcr();

  @override
  Future<String> read(String imagePath) async {
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final result = await recognizer.processImage(
        InputImage.fromFilePath(imagePath),
      );
      // Blocos na ordem de leitura, separados por linha.
      return result.blocks.map((b) => b.text).join('\n').trim();
    } finally {
      await recognizer.close();
    }
  }
}
