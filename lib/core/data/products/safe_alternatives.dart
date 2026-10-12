import 'package:supabase_flutter/supabase_flutter.dart';

import '../../engine/allergen_engine.dart';
import '../../engine/models.dart';
import '../../engine/verdict_status.dart';
import 'open_food_facts_client.dart';
import 'own_products_source.dart';
import 'product_lookup_result.dart';
import 'product_record.dart';

/// Total de scans por produto (popularidade no app).
abstract interface class ScanCountsSource {
  Future<Map<String, int>> counts(List<String> barcodes);
}

class SupabaseScanCounts implements ScanCountsSource {
  SupabaseScanCounts(this._client);

  final SupabaseClient _client;

  @override
  Future<Map<String, int>> counts(List<String> barcodes) async {
    if (barcodes.isEmpty) return const {};
    final rows = await _client.rpc<List<dynamic>>(
      'scan_counts',
      params: {'p_barcodes': barcodes},
    );
    return {
      for (final row in rows.cast<Map<String, dynamic>>())
        row['barcode'] as String: (row['scans'] as num).toInt(),
    };
  }
}

/// Produtos da mesma categoria SEGUROS para todos os selecionados.
class SafeAlternativesRepository {
  SafeAlternativesRepository({
    required OwnProductsSource ownProducts,
    required OpenFoodFactsClient openFoodFacts,
    required ScanCountsSource scanCounts,
  }) : _own = ownProducts,
       _off = openFoodFacts,
       _counts = scanCounts;

  static const maxResults = 5;

  final OwnProductsSource _own;
  final OpenFoodFactsClient _off;
  final ScanCountsSource _counts;

  /// Até [maxResults], mais escaneados no app primeiro.
  /// Lança [ProductSourceException] só se as duas fontes falharem.
  Future<List<ProductRecord>> find({
    required ProductRecord product,
    required List<Person> people,
    required AllergenEngine engine,
  }) async {
    final category = product.category;
    if (category == null || category.isEmpty || people.isEmpty) return const [];

    final (ownRows, offRecords) = await (
      _attempt(() => _own.verifiedInCategory(category)),
      _attempt(() => _off.searchCategory(category)),
    ).wait;
    if (ownRows.error != null && offRecords.error != null) {
      throw ownRows.error!;
    }

    // Base própria primeiro: em código repetido, ela vence.
    final candidates = <String, ProductRecord>{};
    for (final row in ownRows.value ?? const <Map<String, dynamic>>[]) {
      final record = productRecordFromRow(row);
      candidates.putIfAbsent(record.barcode, () => record);
    }
    for (final record in offRecords.value ?? const <ProductRecord>[]) {
      candidates.putIfAbsent(record.barcode, () => record);
    }
    candidates.remove(product.barcode);

    // Só SEGURO para o grupo; sem ingredientes = INCONCLUSIVO = descartado.
    final safe = [
      for (final record in candidates.values)
        if (engine.evaluate(record.product, people).status ==
            VerdictStatus.safe)
          record,
    ];
    if (safe.isEmpty) return const [];

    Map<String, int> counts;
    try {
      counts = await _counts.counts([for (final r in safe) r.barcode]);
    } on Object {
      counts = const {}; // Popularidade é só ordenação.
    }

    final order = {for (final (i, r) in safe.indexed) r.barcode: i};
    safe.sort((a, b) {
      final byScans = (counts[b.barcode] ?? 0).compareTo(
        counts[a.barcode] ?? 0,
      );
      return byScans != 0
          ? byScans
          : order[a.barcode]!.compareTo(order[b.barcode]!);
    });
    return safe.take(maxResults).toList();
  }
}

Future<({T? value, ProductSourceException? error})> _attempt<T>(
  Future<T> Function() action,
) async {
  try {
    return (value: await action(), error: null);
  } on ProductSourceException catch (e) {
    return (value: null, error: e);
  }
}
