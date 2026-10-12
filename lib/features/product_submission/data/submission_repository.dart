import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/data/supabase_providers.dart';
import '../domain/image_compression.dart';

class SubmissionDraft {
  const SubmissionDraft({
    required this.barcode,
    required this.frontJpeg,
    required this.ingredientsJpeg,
    required this.ingredientsText,
    this.name,
    this.brand,
  });

  final String barcode;
  final Uint8List frontJpeg;
  final Uint8List ingredientsJpeg;
  final String ingredientsText;
  final String? name;
  final String? brand;
}

/// Já enviou 30 cadastros nas últimas 24 h.
class SubmissionRateLimited implements Exception {
  const SubmissionRateLimited();
}

abstract interface class SubmissionRepository {
  /// Comprime e envia as fotos, cria a submissão e o produto pendente.
  Future<void> submit(SubmissionDraft draft);
}

final submissionRepositoryProvider = Provider<SubmissionRepository>(
  (ref) => SupabaseSubmissionRepository(ref.watch(supabaseClientProvider)),
);

/// Caminhos no bucket `submissions`: sempre na pasta do usuário.
({String front, String ingredients}) submissionPaths(
  String userId,
  String barcode,
  int timestamp,
) => (
  front: '$userId/$barcode/front_$timestamp.jpg',
  ingredients: '$userId/$barcode/ingredients_$timestamp.jpg',
);

class SupabaseSubmissionRepository implements SubmissionRepository {
  SupabaseSubmissionRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> submit(SubmissionDraft draft) async {
    final userId =
        _client.auth.currentUser?.id ?? (throw StateError('Sem sessão.'));
    final (front, ingredients) = await (
      compute(_compress, draft.frontJpeg),
      compute(_compress, draft.ingredientsJpeg),
    ).wait;
    final paths = submissionPaths(
      userId,
      draft.barcode,
      DateTime.now().millisecondsSinceEpoch,
    );

    final bucket = _client.storage.from('submissions');
    const options = FileOptions(contentType: 'image/jpeg');
    await bucket.uploadBinary(paths.front, front, fileOptions: options);
    await bucket.uploadBinary(
      paths.ingredients,
      ingredients,
      fileOptions: options,
    );

    try {
      await _client.rpc<String>(
        'submit_product',
        params: {
          'p_barcode': draft.barcode,
          'p_name': draft.name,
          'p_brand': draft.brand,
          'p_front_image': paths.front,
          'p_ingredients_image': paths.ingredients,
          'p_ocr_text': draft.ingredientsText,
        },
      );
    } on PostgrestException catch (e) {
      // Sem submissão, as fotos não servem para nada.
      await bucket
          .remove([paths.front, paths.ingredients])
          .catchError((Object _) => <FileObject>[]);
      if (e.hint == 'submission_rate_limit') {
        throw const SubmissionRateLimited();
      }
      rethrow;
    }
  }
}

Uint8List _compress(Uint8List bytes) => compressJpeg(bytes);
