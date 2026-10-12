import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/data/products/product_lookup_result.dart';
import 'package:pode_comer/core/data/products/product_record.dart';
import 'package:pode_comer/core/data/products/safe_alternatives.dart';
import 'package:pode_comer/core/engine/models.dart';

import '../../engine/engine_test_helpers.dart';
import 'fakes.dart';

void main() {
  const scanned = ProductRecord(
    barcode: barcode,
    origin: ProductOrigin.openFoodFacts,
    category: 'en:biscuits',
    product: Product(
      ingredientsText: 'Farinha de trigo.',
      hasIngredients: true,
    ),
  );

  Map<String, dynamic> ownSafe(String code, String name) => {
    ...ownRow(ingredients: 'Farinha de arroz, açúcar.'),
    'barcode': code,
    'name': name,
    'allergens_contains': <String>[],
    'allergens_traces': <String>[],
  };

  Future<List<ProductRecord>> find({
    Object own = const [],
    List<Object> off = const [],
    Map<String, int> counts = const {},
    List<Person> people = family,
    ProductRecord product = scanned,
    RecordingHttp? server,
  }) {
    final http =
        server ??
        RecordingHttp([
          respond({'products': off}),
        ]);
    return SafeAlternativesRepository(
      ownProducts: FakeOwnProducts(const [], category: own),
      openFoodFacts: offClient(http.client),
      scanCounts: FakeScanCounts(counts),
    ).find(product: product, people: people, engine: engine);
  }

  test('busca no OFF pela categoria mais específica, no Brasil', () async {
    final server = RecordingHttp([
      respond({'products': <Object>[]}),
    ]);
    await find(server: server);

    final uri = server.requests.single.url;
    expect(uri.path, '/api/v2/search');
    expect(uri.queryParameters['categories_tags'], 'en:biscuits');
    expect(uri.queryParameters['countries_tags'], 'en:brazil');
    expect(uri.queryParameters['fields'], contains('ingredients_text_pt'));
    expect(
      server.requests.single.headers['User-Agent'],
      startsWith('PodeComer/1.0'),
    );
  });

  test('só devolve produtos SEGUROS para todos os selecionados', () async {
    final result = await find(
      off: [
        offSearchItem('7891000100110', 'Biscoito de arroz'),
        offSearchItem(
          '7891000100127',
          'Com trigo',
          ingredients: 'Farinha de trigo.',
        ),
        offSearchItem(
          '7891000100134',
          'Pode conter amendoim',
          ingredients: 'Milho. Pode conter amendoim.',
        ),
        offSearchItem(
          '7891000100141',
          'Com leite',
          ingredients: 'Milho, leite em pó.',
        ),
      ],
    );
    expect(result.map((r) => r.name), ['Biscoito de arroz']);
  });

  test('o que é seguro depende de quem foi selecionado', () async {
    final result = await find(
      people: [ana, enzo], // sem a Carol (glúten)
      off: [
        offSearchItem(
          '7891000100127',
          'Com trigo',
          ingredients: 'Farinha de trigo.',
        ),
      ],
    );
    expect(result.map((r) => r.name), ['Com trigo']);
  });

  test('sem ingredientes ou em outro idioma não é alternativa', () async {
    final result = await find(
      off: [
        offSearchItem('7891000100110', 'Sem ingredientes', ingredients: ''),
        offSearchItem(
          '7891000100127',
          'Em inglês',
          lang: 'en',
          ingredients: '',
        ),
      ],
    );
    expect(result, isEmpty);
  });

  test('não sugere o próprio produto escaneado', () async {
    final result = await find(off: [offSearchItem(barcode, 'O mesmo')]);
    expect(result, isEmpty);
  });

  test('ordena por número de scans e limita a 5', () async {
    final result = await find(
      off: [
        for (final (i, code) in [
          '7891000100110',
          '7891000100127',
          '7891000100134',
          '7891000100141',
          '7891000100158',
          '7891000100165',
        ].indexed)
          offSearchItem(code, 'P$i'),
      ],
      counts: {'7891000100158': 40, '7891000100127': 10},
    );
    expect(result.map((r) => r.name), ['P4', 'P1', 'P0', 'P2', 'P3']);
  });

  test('junta base própria e OFF; código repetido fica com a base', () async {
    final result = await find(
      own: [ownSafe('7891000100110', 'Da base')],
      off: [
        offSearchItem('7891000100110', 'Do OFF'),
        offSearchItem('7891000100127', 'Só no OFF'),
      ],
    );
    expect(result.map((r) => r.name), ['Da base', 'Só no OFF']);
    expect(result.first.origin, ProductOrigin.ownVerified);
  });

  test('uma fonte fora do ar não impede a outra', () async {
    final result = await find(
      own: const ProductSourceException(LookupFailure.network),
      off: [offSearchItem('7891000100110', 'Do OFF')],
    );
    expect(result.map((r) => r.name), ['Do OFF']);
  });

  test('as duas fontes fora do ar: erro', () async {
    await expectLater(
      find(
        own: const ProductSourceException(LookupFailure.network),
        server: RecordingHttp([respond({}, 503)]),
      ),
      throwsA(isA<ProductSourceException>()),
    );
  });

  test('sem categoria: nenhuma alternativa, sem consultar nada', () async {
    final server = RecordingHttp([]);
    final result = await find(
      server: server,
      product: scanned.copyWith(category: null),
    );
    expect(result, isEmpty);
    expect(server.requests, isEmpty);
  });
}
