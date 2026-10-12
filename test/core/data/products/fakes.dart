import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pode_comer/core/data/products/off_cache.dart';
import 'package:pode_comer/core/data/products/open_food_facts_client.dart';
import 'package:pode_comer/core/data/products/own_products_source.dart';
import 'package:pode_comer/core/data/products/product_lookup_result.dart';
import 'package:pode_comer/core/data/products/safe_alternatives.dart';

import '../../engine/engine_test_helpers.dart';

const barcode = '7891000100103';

final dictionary = loadDictionary();

/// Resposta do OFF para produto encontrado.
Map<String, dynamic> offFound([Map<String, dynamic> product = const {}]) => {
  'code': barcode,
  'status': 1,
  'status_verbose': 'product found',
  'product': {
    'product_name': 'Biscoito Recheado',
    'brands': 'Marca X, Marca Y',
    'categories_tags': ['en:snacks', 'en:biscuits', 'en:filled-biscuits'],
    'ingredients_text_pt': 'Farinha de trigo, açúcar, leite em pó.',
    'ingredients_text': 'Wheat flour, sugar, milk powder.',
    'allergens_tags': ['en:gluten', 'en:milk'],
    'traces_tags': ['en:peanuts', 'en:mustard'],
    'image_front_url': 'https://images.openfoodfacts.org/x.jpg',
    'last_modified_t': 1767225600, // 2026-01-01T00:00:00Z
    'lang': 'pt',
    ...product,
  },
};

const offNotFound = {
  'code': barcode,
  'status': 0,
  'status_verbose': 'product not found',
};

http.Response jsonResponse(Object body, [int status = 200]) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// Cliente HTTP que responde em sequência e grava as requisições.
class RecordingHttp {
  RecordingHttp(this.responses);

  final List<Future<http.Response> Function(http.Request)> responses;
  final requests = <http.Request>[];

  late final client = MockClient((request) {
    requests.add(request);
    if (requests.length > responses.length) {
      throw StateError('Requisição inesperada: ${request.url}');
    }
    return responses[requests.length - 1](request);
  });
}

Future<http.Response> Function(http.Request) respond(
  Object body, [
  int status = 200,
]) =>
    (_) async => jsonResponse(body, status);

OpenFoodFactsClient offClient(
  http.Client httpClient, {
  OffCache? cache,
  DateTime Function()? now,
  Duration timeout = const Duration(seconds: 5),
}) => OpenFoodFactsClient(
  httpClient: httpClient,
  cache: cache ?? InMemoryOffCache(),
  mapTags: dictionary.allergensFromOffTags,
  now: now,
  timeout: timeout,
);

/// Linha da tabela `products`.
Map<String, dynamic> ownRow({
  String status = 'verified',
  String ingredients = 'Farinha de trigo, açúcar.',
}) => {
  'barcode': barcode,
  'name': 'Biscoito da Base',
  'brand': 'Marca Z',
  'category': 'en:biscuits',
  'ingredients_text': ingredients,
  'allergens_contains': ['gluten', 'trigo'],
  'allergens_traces': ['amendoim'],
  'source': 'own',
  'status': status,
  'image_urls': ['avatars/1.jpg', 'avatars/2.jpg'],
  'updated_at': '2026-09-30T12:00:00+00:00',
};

class FakeOwnProducts implements OwnProductsSource {
  FakeOwnProducts(this.responses, {this.category = const [], this.gate});

  /// Cada item: uma linha, `null` ou uma [ProductSourceException].
  final List<Object?> responses;

  /// Resposta de [verifiedInCategory]: linhas ou [ProductSourceException].
  final Object category;

  /// Se definido, [fetch] só responde quando completar (base lenta).
  final Completer<void>? gate;
  var calls = 0;

  @override
  Future<Map<String, dynamic>?> fetch(String barcode) async {
    final response = responses[calls++];
    await gate?.future;
    if (response is ProductSourceException) throw response;
    return response as Map<String, dynamic>?;
  }

  @override
  Future<List<Map<String, dynamic>>> verifiedInCategory(
    String category, {
    int limit = 50,
  }) async {
    final response = this.category;
    if (response is ProductSourceException) throw response;
    return (response as List).cast<Map<String, dynamic>>();
  }
}

class FakeScanCounts implements ScanCountsSource {
  FakeScanCounts([this.values = const {}]);

  final Map<String, int> values;

  @override
  Future<Map<String, int>> counts(List<String> barcodes) async => {
    for (final b in barcodes) b: ?values[b],
  };
}

/// Produto do OFF no formato da busca.
Map<String, dynamic> offSearchItem(
  String code,
  String name, {
  String ingredients = 'Arroz, sal.',
  List<String> allergens = const [],
  List<String> traces = const [],
  String lang = 'pt',
}) => {
  'code': code,
  'product_name': name,
  'ingredients_text_pt': ingredients,
  'allergens_tags': allergens,
  'traces_tags': traces,
  'categories_tags': ['en:snacks', 'en:biscuits'],
  'lang': lang,
};
