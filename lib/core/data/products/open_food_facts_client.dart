import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../engine/allergen.dart';
import '../../engine/models.dart';
import 'off_cache.dart';
import 'product_lookup_result.dart';
import 'product_record.dart';

/// Cliente da API v2 do Open Food Facts, com cache local.
class OpenFoodFactsClient {
  OpenFoodFactsClient({
    required http.Client httpClient,
    required this.cache,
    required this.mapTags,
    DateTime Function()? now,
    this.timeout = const Duration(seconds: 5),
    this.cacheTtl = const Duration(days: 7),
    this.searchCacheTtl = const Duration(days: 1),
  }) : _http = httpClient,
       _now = now ?? DateTime.now;

  static const userAgent = 'PodeComer/1.0 (contato@podecomerapp.com.br)';

  /// Campos pedidos à API. `lang` diz o idioma de `ingredients_text`: sem
  /// ele não dá para saber se o texto está em português.
  static const fields = [
    'product_name',
    'brands',
    'categories_tags',
    'ingredients_text_pt',
    'ingredients_text',
    'allergens_tags',
    'traces_tags',
    'image_front_url',
    'last_modified_t',
    'lang',
  ];

  final http.Client _http;
  final OffCache cache;
  final DateTime Function() _now;

  /// Converte `allergens_tags` / `traces_tags` (ex.: `en:milk`).
  final Set<Allergen> Function(Iterable<String> tags) mapTags;
  final Duration timeout;
  final Duration cacheTtl;

  /// Buscas por categoria mudam mais que um produto: cache de 1 dia.
  final Duration searchCacheTtl;

  static Uri productUri(String barcode) => Uri.https(
    'world.openfoodfacts.org',
    '/api/v2/product/$barcode',
    {'fields': fields.join(',')},
  );

  static Uri searchUri(String categoryTag) =>
      Uri.https('world.openfoodfacts.org', '/api/v2/search', {
        'categories_tags': categoryTag,
        'countries_tags': 'en:brazil',
        'fields': ['code', ...fields].join(','),
        'sort_by': 'unique_scans_n',
        'page_size': '50',
      });

  /// Produtos do Brasil na categoria, mais escaneados no OFF primeiro.
  /// Lança [ProductSourceException] em falha.
  Future<List<ProductRecord>> searchCategory(String categoryTag) async {
    final key = 'search:$categoryTag';
    final cached = await cache.read(key);
    if (cached != null &&
        _now().difference(cached.fetchedAt) < searchCacheTtl) {
      try {
        return _searchRecords(cached.product);
      } on TypeError {
        // Entrada inválida: busca de novo.
      }
    }

    final body = await _getJson(searchUri(categoryTag));
    if (body == null) return const [];
    final List<ProductRecord> records;
    try {
      records = _searchRecords(body);
    } on TypeError catch (e) {
      throw ProductSourceException(LookupFailure.server, e);
    }
    await cache.write(key, CachedOffProduct(product: body, fetchedAt: _now()));
    return records;
  }

  List<ProductRecord> _searchRecords(Map<String, dynamic> body) => [
    for (final item in body['products'] as List<dynamic>? ?? const [])
      if (item case {'code': final String code} when isValidBarcode(code))
        offProductToRecord(code, item as Map<String, dynamic>, mapTags),
  ];

  /// GET com User-Agent e timeout. `null` em 404.
  Future<Map<String, dynamic>?> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: {'User-Agent': userAgent})
          .timeout(timeout);
    } on TimeoutException catch (e) {
      throw ProductSourceException(LookupFailure.timeout, e);
    } on SocketException catch (e) {
      throw ProductSourceException(LookupFailure.network, e);
    } on http.ClientException catch (e) {
      throw ProductSourceException(LookupFailure.network, e);
    }

    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ProductSourceException(LookupFailure.server, response.statusCode);
    }
    try {
      return jsonDecode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw ProductSourceException(LookupFailure.server, e);
    } on TypeError catch (e) {
      throw ProductSourceException(LookupFailure.server, e);
    }
  }

  /// Produto do OFF, `null` se não existir.
  /// Lança [ProductSourceException] em falha de rede ou servidor.
  Future<ProductRecord?> fetch(String barcode) async {
    final cached = await cache.read(barcode);
    if (cached != null) {
      if (_now().difference(cached.fetchedAt) < cacheTtl) {
        try {
          return offProductToRecord(
            barcode,
            cached.product,
            mapTags,
            fromCache: true,
          );
        } on TypeError {
          // Entrada inválida: descarta e busca de novo.
        }
      }
      await cache.remove(barcode);
    }

    final body = await _getJson(productUri(barcode));
    if (body == null) return null;
    final product = body['product'];
    if (body['status'] != 1 || product is! Map<String, dynamic>) return null;

    final ProductRecord record;
    try {
      record = offProductToRecord(barcode, product, mapTags);
    } on TypeError catch (e) {
      throw ProductSourceException(LookupFailure.server, e);
    }

    // Só produtos encontrados vão para o cache: um "não encontrado" guardado
    // por 7 dias esconderia um cadastro novo no OFF.
    await cache.write(
      barcode,
      CachedOffProduct(product: product, fetchedAt: _now()),
    );
    return record;
  }
}

/// Converte o objeto `product` da API em [ProductRecord].
ProductRecord offProductToRecord(
  String barcode,
  Map<String, dynamic> json,
  Set<Allergen> Function(Iterable<String>) mapTags, {
  bool fromCache = false,
}) {
  String? text(String key) {
    final value = (json[key] as String?)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  List<String> tags(String key) => [
    for (final tag in (json[key] as List<dynamic>? ?? const [])) tag as String,
  ];

  // O dicionário é em português: texto em outro idioma não pode gerar SEGURO.
  final ptText = text('ingredients_text_pt');
  final mainText = text('ingredients_text');
  final mainIsPortuguese = json['lang'] == 'pt';
  final ingredients = ptText ?? mainText ?? '';
  final ingredientsArePortuguese =
      ptText != null || (mainText != null && mainIsPortuguese);

  final categories = tags('categories_tags');
  final modified = json['last_modified_t'];

  return ProductRecord(
    barcode: barcode,
    origin: ProductOrigin.openFoodFacts,
    name: text('product_name'),
    brand: text('brands'),
    category: categories.isEmpty ? null : categories.last,
    imageUrl: text('image_front_url'),
    updatedAt: modified is int
        ? DateTime.fromMillisecondsSinceEpoch(modified * 1000, isUtc: true)
        : null,
    fromCache: fromCache,
    product: Product(
      ingredientsText: ingredients,
      hasIngredients: ingredientsArePortuguese,
      allergensContains: mapTags(tags('allergens_tags')),
      allergensTraces: mapTags(tags('traces_tags')),
    ),
  );
}
