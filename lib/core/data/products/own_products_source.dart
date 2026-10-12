import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../engine/allergen.dart';
import '../../engine/models.dart';
import 'product_lookup_result.dart';
import 'product_record.dart';

/// Tabela `products` da base própria (Supabase).
abstract interface class OwnProductsSource {
  /// Linha de `products` (verified ou pending) ou `null`.
  /// Lança [ProductSourceException] em falha.
  Future<Map<String, dynamic>?> fetch(String barcode);

  /// Produtos **verificados** da categoria (candidatos a alternativa).
  /// Lança [ProductSourceException] em falha.
  Future<List<Map<String, dynamic>>> verifiedInCategory(
    String category, {
    int limit = 50,
  });
}

class SupabaseOwnProductsSource implements OwnProductsSource {
  SupabaseOwnProductsSource(
    this._client, {
    this.timeout = const Duration(seconds: 5),
  });

  final SupabaseClient _client;
  final Duration timeout;

  static const _columns =
      'barcode, name, brand, category, ingredients_text, allergens_contains, '
      'allergens_traces, source, status, image_urls, updated_at';

  @override
  Future<Map<String, dynamic>?> fetch(String barcode) => _guard(
    () => _client
        .from('products')
        .select(_columns)
        .eq('barcode', barcode)
        .maybeSingle(),
  );

  @override
  Future<List<Map<String, dynamic>>> verifiedInCategory(
    String category, {
    int limit = 50,
  }) => _guard(
    () => _client
        .from('products')
        .select(_columns)
        .eq('category', category)
        .eq('status', 'verified')
        .limit(limit),
  );

  Future<T> _guard<T>(Future<T> Function() query) async {
    try {
      return await query().timeout(timeout);
    } on TimeoutException catch (e) {
      throw ProductSourceException(LookupFailure.timeout, e);
    } on PostgrestException catch (e) {
      throw ProductSourceException(LookupFailure.server, e);
    } on SocketException catch (e) {
      throw ProductSourceException(LookupFailure.network, e);
    } on Exception catch (e) {
      throw ProductSourceException(LookupFailure.network, e);
    }
  }
}

/// Converte uma linha de `products` em [ProductRecord].
ProductRecord productRecordFromRow(Map<String, dynamic> row) {
  Set<Allergen> allergens(Object? codes) => {
    for (final code in (codes as List<dynamic>? ?? const []))
      ?Allergen.fromCode(code as String),
  };

  final ingredients = (row['ingredients_text'] as String?)?.trim() ?? '';
  final images = (row['image_urls'] as List<dynamic>? ?? const []);
  final updatedAt = row['updated_at'] as String?;

  return ProductRecord(
    barcode: row['barcode'] as String,
    origin: row['status'] == 'verified'
        ? ProductOrigin.ownVerified
        : ProductOrigin.ownPending,
    name: row['name'] as String?,
    brand: row['brand'] as String?,
    category: row['category'] as String?,
    imageUrl: images.isEmpty ? null : images.first as String,
    updatedAt: updatedAt == null ? null : DateTime.parse(updatedAt),
    product: Product(
      ingredientsText: ingredients,
      hasIngredients: ingredients.isNotEmpty,
      allergensContains: allergens(row['allergens_contains']),
      allergensTraces: allergens(row['allergens_traces']),
    ),
  );
}
