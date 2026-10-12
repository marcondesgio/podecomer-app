import 'dart:async';

import 'open_food_facts_client.dart';
import 'own_products_source.dart';
import 'product_lookup_result.dart';
import 'product_record.dart';

class ProductRepository {
  ProductRepository({
    required OwnProductsSource ownProducts,
    required OpenFoodFactsClient openFoodFacts,
    this.offHedge = const Duration(milliseconds: 300),
    this.memoryTtl = const Duration(minutes: 10),
    this.memoryCapacity = 50,
    DateTime Function()? now,
  }) : _own = ownProducts,
       _off = openFoodFacts,
       _now = now ?? DateTime.now;

  final OwnProductsSource _own;
  final OpenFoodFactsClient _off;
  final DateTime Function() _now;

  /// Se a base própria não responder neste tempo, o OFF é consultado em
  /// paralelo (o tempo total fica perto do maior, não da soma). Quando a base
  /// responde rápido, o código não é enviado ao OFF à toa.
  final Duration offHedge;

  /// Produtos encontrados ficam em memória: reescanear é instantâneo.
  final Duration memoryTtl;
  final int memoryCapacity;
  final _memory = <String, (DateTime, ProductFound)>{};

  /// Ordem de consulta:
  /// 1. base própria verificada;
  /// 2. Open Food Facts;
  /// 3. base própria pendente (não verificado);
  /// 4. não encontrado.
  ///
  /// Se uma fonte falhar antes da resposta, devolve [ProductLookupFailed]
  /// em vez de pular para uma fonte menos confiável.
  Future<ProductLookupResult> lookup(String barcode) async {
    if (!isValidBarcode(barcode)) return ProductNotFound(barcode);

    final cached = _memory.remove(barcode);
    if (cached != null && _now().difference(cached.$1) < memoryTtl) {
      _memory[barcode] = cached; // mais recente no fim (LRU)
      return cached.$2;
    }

    final result = await _lookupSources(barcode);
    if (result is ProductFound) {
      _memory[barcode] = (_now(), result);
      while (_memory.length > memoryCapacity) {
        _memory.remove(_memory.keys.first);
      }
    }
    return result;
  }

  Future<ProductLookupResult> _lookupSources(String barcode) async {
    final own = _settle(_own.fetch(barcode));
    Future<_Settled<ProductRecord?>>? off;
    if (!await _completesWithin(own, offHedge)) {
      off = _settle(_off.fetch(barcode));
    }

    final ownResult = await own;
    if (ownResult.error case final ProductSourceException e) {
      return ProductLookupFailed(barcode, e.failure);
    }
    if (ownResult.error case final Object e) throw e;

    final row = ownResult.value;
    final ownRecord = row == null ? null : productRecordFromRow(row);
    if (ownRecord?.origin == ProductOrigin.ownVerified) {
      return ProductFound(ownRecord!);
    }

    final offResult = await (off ?? _settle(_off.fetch(barcode)));
    if (offResult.error case final ProductSourceException e) {
      return ProductLookupFailed(barcode, e.failure);
    }
    if (offResult.error case final Object e) throw e;

    final offRecord = offResult.value;
    final pending = ownRecord;
    if (offRecord != null) {
      // OFF sem ingredientes utilizáveis perde para um cadastro pendente
      // que os tenha: sem ingredientes o veredito seria INCONCLUSIVO.
      final pendingIsMoreUseful =
          pending != null &&
          !offRecord.product.hasUsableIngredients &&
          pending.product.hasUsableIngredients;
      return ProductFound(pendingIsMoreUseful ? pending : offRecord);
    }
    if (pending != null) return ProductFound(pending);
    return ProductNotFound(barcode);
  }
}

class _Settled<T> {
  const _Settled({this.value, this.error});

  final T? value;
  final Object? error;
}

/// Nunca falha: o erro vira valor (evita erro não tratado quando o
/// resultado de uma fonte é descartado).
Future<_Settled<T>> _settle<T>(Future<T> future) => future.then(
  (value) => _Settled<T>(value: value),
  onError: (Object error) => _Settled<T>(error: error),
);

Future<bool> _completesWithin(Future<Object?> future, Duration limit) {
  final completer = Completer<bool>();
  final timer = Timer(limit, () {
    if (!completer.isCompleted) completer.complete(false);
  });
  future.whenComplete(() {
    timer.cancel();
    if (!completer.isCompleted) completer.complete(true);
  });
  return completer.future;
}
