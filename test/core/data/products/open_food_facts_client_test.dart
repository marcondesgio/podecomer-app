import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pode_comer/core/data/products/off_cache.dart';
import 'package:pode_comer/core/data/products/product_lookup_result.dart';
import 'package:pode_comer/core/data/products/product_record.dart';
import 'package:pode_comer/core/engine/allergen.dart';

import 'fakes.dart';

void main() {
  group('requisição', () {
    test('usa a URL v2, os campos pedidos e o User-Agent', () async {
      final server = RecordingHttp([respond(offFound())]);
      await offClient(server.client).fetch(barcode);

      final request = server.requests.single;
      expect(request.method, 'GET');
      expect(
        request.url.toString(),
        startsWith(
          'https://world.openfoodfacts.org/api/v2/product/$barcode?fields=',
        ),
      );
      expect(
        request.url.queryParameters['fields'],
        'product_name,brands,categories_tags,ingredients_text_pt,'
        'ingredients_text,allergens_tags,traces_tags,image_front_url,'
        'last_modified_t,lang',
      );
      expect(
        request.headers['User-Agent'],
        'PodeComer/1.0 (contato@podecomerapp.com.br)',
      );
    });
  });

  group('conversão para Product', () {
    test('produto encontrado com ingredientes em português', () async {
      final server = RecordingHttp([respond(offFound())]);
      final record = (await offClient(server.client).fetch(barcode))!;

      expect(record.origin, ProductOrigin.openFoodFacts);
      expect(record.name, 'Biscoito Recheado');
      expect(record.brand, 'Marca X, Marca Y');
      expect(record.category, 'en:filled-biscuits');
      expect(record.imageUrl, 'https://images.openfoodfacts.org/x.jpg');
      expect(record.updatedAt, DateTime.utc(2026));
      expect(record.fromCache, isFalse);
      expect(
        record.product.ingredientsText,
        'Farinha de trigo, açúcar, leite em pó.',
      );
      expect(record.product.hasIngredients, isTrue);
      expect(record.product.allergensContains, {
        Allergen.gluten,
        Allergen.milk,
      });
      // en:mustard não está no MVP e é ignorada.
      expect(record.product.allergensTraces, {Allergen.peanut});
    });

    test(
      'sem ingredients_text_pt usa ingredients_text se o idioma for pt',
      () async {
        final server = RecordingHttp([
          respond(
            offFound({
              'ingredients_text_pt': '',
              'ingredients_text': 'Arroz, sal.',
            }),
          ),
        ]);
        final product = (await offClient(
          server.client,
        ).fetch(barcode))!.product;
        expect(product.ingredientsText, 'Arroz, sal.');
        expect(product.hasIngredients, isTrue);
      },
    );

    test(
      'ingredientes só em outro idioma não contam como lista utilizável',
      () async {
        final server = RecordingHttp([
          respond(
            offFound({
              'ingredients_text_pt': null,
              'ingredients_text': 'Rice, salt.',
              'lang': 'en',
            }),
          ),
        ]);
        final product = (await offClient(
          server.client,
        ).fetch(barcode))!.product;
        expect(product.hasIngredients, isFalse);
      },
    );

    test('campos ausentes viram nulos', () async {
      final server = RecordingHttp([
        respond({'status': 1, 'product': <String, dynamic>{}}),
      ]);
      final record = (await offClient(server.client).fetch(barcode))!;
      expect(record.name, isNull);
      expect(record.updatedAt, isNull);
      expect(record.product.hasIngredients, isFalse);
    });
  });

  group('não encontrado', () {
    test('status 0 → null', () async {
      final server = RecordingHttp([respond(offNotFound)]);
      expect(await offClient(server.client).fetch(barcode), isNull);
    });

    test('HTTP 404 → null', () async {
      final server = RecordingHttp([respond(offNotFound, 404)]);
      expect(await offClient(server.client).fetch(barcode), isNull);
    });
  });

  group('erros', () {
    Future<LookupFailure> failureOf(
      Future<http.Response> Function(http.Request) response, {
      Duration timeout = const Duration(seconds: 5),
    }) async {
      final server = RecordingHttp([response]);
      try {
        await offClient(server.client, timeout: timeout).fetch(barcode);
      } on ProductSourceException catch (e) {
        return e.failure;
      }
      fail('deveria lançar ProductSourceException');
    }

    test('HTTP 500 → server', () async {
      expect(await failureOf(respond({}, 500)), LookupFailure.server);
    });

    test('JSON inválido → server', () async {
      expect(
        await failureOf((_) async => http.Response('<html>', 200)),
        LookupFailure.server,
      );
    });

    test('tipo inesperado no produto → server', () async {
      expect(
        await failureOf(respond(offFound({'allergens_tags': 'en:milk'}))),
        LookupFailure.server,
      );
    });

    test('sem conexão → network', () async {
      expect(
        await failureOf((_) => throw const SocketException('offline')),
        LookupFailure.network,
      );
      expect(
        await failureOf((_) => throw http.ClientException('reset')),
        LookupFailure.network,
      );
    });

    test('mais de 5 s (aqui 20 ms) → timeout', () async {
      final failure = await failureOf(
        (_) => Completer<http.Response>().future,
        timeout: const Duration(milliseconds: 20),
      );
      expect(failure, LookupFailure.timeout);
    });

    test('timeout padrão é 5 s', () {
      expect(offClient(http.Client()).timeout, const Duration(seconds: 5));
    });
  });

  group('cache local de 7 dias', () {
    late DateTime now;
    late InMemoryOffCache cache;

    setUp(() {
      now = DateTime.utc(2026, 10, 8);
      cache = InMemoryOffCache();
    });

    test('segunda consulta em menos de 7 dias não vai à rede', () async {
      final server = RecordingHttp([respond(offFound())]);
      final client = offClient(server.client, cache: cache, now: () => now);

      await client.fetch(barcode);
      now = now.add(const Duration(days: 6, hours: 23));
      final second = await client.fetch(barcode);

      expect(server.requests, hasLength(1));
      expect(second!.fromCache, isTrue);
      expect(second.name, 'Biscoito Recheado');
      expect(second.product.allergensContains, contains(Allergen.milk));
    });

    test('depois de 7 dias busca de novo', () async {
      final server = RecordingHttp([
        respond(offFound()),
        respond(offFound({'product_name': 'Nova receita'})),
      ]);
      final client = offClient(server.client, cache: cache, now: () => now);

      await client.fetch(barcode);
      now = now.add(const Duration(days: 7));
      final second = await client.fetch(barcode);

      expect(server.requests, hasLength(2));
      expect(second!.name, 'Nova receita');
      expect(second.fromCache, isFalse);
    });

    test('"não encontrado" não é guardado no cache', () async {
      final server = RecordingHttp([respond(offNotFound), respond(offFound())]);
      final client = offClient(server.client, cache: cache, now: () => now);

      expect(await client.fetch(barcode), isNull);
      expect(await client.fetch(barcode), isNotNull);
      expect(server.requests, hasLength(2));
    });

    test('erro não é guardado no cache', () async {
      final server = RecordingHttp([respond({}, 503), respond(offFound())]);
      final client = offClient(server.client, cache: cache, now: () => now);

      await expectLater(
        client.fetch(barcode),
        throwsA(isA<ProductSourceException>()),
      );
      expect(await client.fetch(barcode), isNotNull);
    });

    test('entrada de cache inválida é descartada', () async {
      await cache.write(
        barcode,
        CachedOffProduct(product: {'allergens_tags': 42}, fetchedAt: now),
      );
      final server = RecordingHttp([respond(offFound())]);
      final record = await offClient(
        server.client,
        cache: cache,
        now: () => now,
      ).fetch(barcode);

      expect(record!.fromCache, isFalse);
      expect(server.requests, hasLength(1));
    });
  });
}
