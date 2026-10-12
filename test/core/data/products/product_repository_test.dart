import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/products/product_lookup_result.dart';
import 'package:pode_comer/core/data/products/product_record.dart';
import 'package:pode_comer/core/data/products/product_repository.dart';
import 'package:pode_comer/core/engine/allergen.dart';

import 'fakes.dart';

void main() {
  late RecordingHttp off;
  late FakeOwnProducts own;

  ProductRepository repository() =>
      ProductRepository(ownProducts: own, openFoodFacts: offClient(off.client));

  Future<ProductRecord> found() async {
    final result = await repository().lookup(barcode);
    expect(result, isA<ProductFound>());
    return (result as ProductFound).record;
  }

  group('ordem de consulta', () {
    test('1) verificado na base própria: não consulta o OFF', () async {
      own = FakeOwnProducts([ownRow()]);
      off = RecordingHttp([]);

      final record = await found();
      expect(record.origin, ProductOrigin.ownVerified);
      expect(record.origin.isVerified, isTrue);
      expect(off.requests, isEmpty);
    });

    test('2) não está na base própria: usa o OFF', () async {
      own = FakeOwnProducts([null]);
      off = RecordingHttp([respond(offFound())]);

      expect((await found()).origin, ProductOrigin.openFoodFacts);
    });

    test('2) pendente na base, mas o OFF tem: OFF vence', () async {
      own = FakeOwnProducts([ownRow(status: 'pending')]);
      off = RecordingHttp([respond(offFound())]);

      expect((await found()).origin, ProductOrigin.openFoodFacts);
    });

    test('3) só pendente: devolve marcado como não verificado', () async {
      own = FakeOwnProducts([ownRow(status: 'pending')]);
      off = RecordingHttp([respond(offNotFound)]);

      final record = await found();
      expect(record.origin, ProductOrigin.ownPending);
      expect(record.origin.isVerified, isFalse);
    });

    test(
      '3) OFF sem ingredientes perde para pendente com ingredientes',
      () async {
        own = FakeOwnProducts([ownRow(status: 'pending')]);
        off = RecordingHttp([
          respond(
            offFound({'ingredients_text_pt': '', 'ingredients_text': ''}),
          ),
        ]);

        expect((await found()).origin, ProductOrigin.ownPending);
      },
    );

    test('4) nenhuma fonte conhece: não encontrado', () async {
      own = FakeOwnProducts([null]);
      off = RecordingHttp([respond(offNotFound, 404)]);

      expect(await repository().lookup(barcode), isA<ProductNotFound>());
    });

    test('código inválido não consulta nenhuma fonte', () async {
      own = FakeOwnProducts([]);
      off = RecordingHttp([]);

      expect(await repository().lookup('abc/../x'), isA<ProductNotFound>());
      expect(own.calls, 0);
      expect(off.requests, isEmpty);
    });
  });

  group('conversão da base própria', () {
    test('guarda origem, data, alergênicos e imagem', () async {
      own = FakeOwnProducts([ownRow()]);
      off = RecordingHttp([]);

      final record = await found();
      expect(record.barcode, barcode);
      expect(record.name, 'Biscoito da Base');
      expect(record.brand, 'Marca Z');
      expect(record.category, 'en:biscuits');
      expect(record.imageUrl, 'avatars/1.jpg');
      expect(record.updatedAt, DateTime.utc(2026, 9, 30, 12));
      expect(record.product.hasIngredients, isTrue);
      expect(record.product.allergensContains, {
        Allergen.gluten,
        Allergen.wheat,
      });
      expect(record.product.allergensTraces, {Allergen.peanut});
    });

    test('sem ingredientes → hasIngredients falso', () async {
      own = FakeOwnProducts([ownRow(ingredients: '  ')]);
      off = RecordingHttp([]);

      expect((await found()).product.hasIngredients, isFalse);
    });
  });

  group('erros de rede viram falha (INCONCLUSIVO + tentar de novo)', () {
    test('Supabase fora do ar: falha, sem cair para o OFF', () async {
      own = FakeOwnProducts([
        const ProductSourceException(LookupFailure.network),
      ]);
      off = RecordingHttp([]);

      final result = await repository().lookup(barcode);
      expect(result, isA<ProductLookupFailed>());
      expect((result as ProductLookupFailed).failure, LookupFailure.network);
      expect(off.requests, isEmpty);
    });

    test(
      'OFF fora do ar com pendente na base: falha, não usa o pendente',
      () async {
        own = FakeOwnProducts([ownRow(status: 'pending')]);
        off = RecordingHttp([respond({}, 502)]);

        final result = await repository().lookup(barcode);
        expect((result as ProductLookupFailed).failure, LookupFailure.server);
      },
    );

    test('tentar de novo depois da falha funciona', () async {
      own = FakeOwnProducts([
        const ProductSourceException(LookupFailure.timeout),
        null,
      ]);
      off = RecordingHttp([respond(offFound())]);
      final repo = repository();

      expect(await repo.lookup(barcode), isA<ProductLookupFailed>());
      expect(await repo.lookup(barcode), isA<ProductFound>());
    });
  });
}
