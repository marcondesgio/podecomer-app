import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/products/product_lookup_result.dart';
import 'package:pode_comer/core/data/products/product_record.dart';
import 'package:pode_comer/core/data/products/product_repository.dart';

import 'fakes.dart';

void main() {
  test('base própria lenta: OFF é consultado em paralelo', () async {
    final gate = Completer<void>();
    final own = FakeOwnProducts([null], gate: gate);
    final off = RecordingHttp([respond(offFound())]);
    final repo = ProductRepository(
      ownProducts: own,
      openFoodFacts: offClient(off.client),
      offHedge: const Duration(milliseconds: 10),
    );

    final result = repo.lookup(barcode);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    // A base ainda não respondeu e o OFF já foi chamado.
    expect(gate.isCompleted, isFalse);
    expect(off.requests, hasLength(1));

    gate.complete();
    expect(
      ((await result) as ProductFound).record.origin,
      ProductOrigin.openFoodFacts,
    );
  });

  test('base própria rápida: o código não vai ao OFF', () async {
    final off = RecordingHttp([]);
    final repo = ProductRepository(
      ownProducts: FakeOwnProducts([ownRow()]),
      openFoodFacts: offClient(off.client),
    );
    expect(await repo.lookup(barcode), isA<ProductFound>());
    expect(off.requests, isEmpty);
  });

  test('base lenta e verificada: resultado do OFF é descartado', () async {
    final gate = Completer<void>();
    final off = RecordingHttp([respond({}, 500)]); // erro ignorado
    final repo = ProductRepository(
      ownProducts: FakeOwnProducts([ownRow()], gate: gate),
      openFoodFacts: offClient(off.client),
      offHedge: Duration.zero,
    );
    final result = repo.lookup(barcode);
    await Future<void>.delayed(const Duration(milliseconds: 20));
    gate.complete();
    expect(
      ((await result) as ProductFound).record.origin,
      ProductOrigin.ownVerified,
    );
  });

  test('reescanear usa a memória, sem rede', () async {
    final own = FakeOwnProducts([null]);
    final off = RecordingHttp([respond(offFound())]);
    final repo = ProductRepository(
      ownProducts: own,
      openFoodFacts: offClient(off.client),
    );

    await repo.lookup(barcode);
    final watch = Stopwatch()..start();
    final second = await repo.lookup(barcode);
    watch.stop();

    expect(second, isA<ProductFound>());
    expect(own.calls, 1);
    expect(off.requests, hasLength(1));
    expect(watch.elapsedMilliseconds, lessThan(50));
  });

  test('memória expira e não guarda "não encontrado"', () async {
    var now = DateTime(2026);
    final own = FakeOwnProducts([null, null, ownRow(), ownRow()]);
    final off = RecordingHttp([respond(offNotFound), respond(offNotFound)]);
    final repo = ProductRepository(
      ownProducts: own,
      openFoodFacts: offClient(off.client),
      now: () => now,
    );

    expect(await repo.lookup(barcode), isA<ProductNotFound>());
    expect(await repo.lookup(barcode), isA<ProductNotFound>());
    expect(await repo.lookup(barcode), isA<ProductFound>());
    expect(own.calls, 3);

    now = now.add(const Duration(minutes: 9));
    await repo.lookup(barcode);
    expect(own.calls, 3); // ainda na memória

    now = now.add(const Duration(minutes: 2));
    await repo.lookup(barcode);
    expect(own.calls, 4); // expirou: consulta de novo
  });
}
