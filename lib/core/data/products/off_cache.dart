import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Resposta do Open Food Facts guardada localmente.
class CachedOffProduct {
  const CachedOffProduct({required this.product, required this.fetchedAt});

  /// Objeto `product` da API, como veio.
  final Map<String, dynamic> product;
  final DateTime fetchedAt;
}

/// Cache local das respostas do Open Food Facts (só produtos, sem dados
/// pessoais). A validade é decidida por quem lê.
abstract interface class OffCache {
  Future<CachedOffProduct?> read(String barcode);
  Future<void> write(String barcode, CachedOffProduct entry);
  Future<void> remove(String barcode);
}

class SharedPreferencesOffCache implements OffCache {
  SharedPreferencesOffCache(this._prefs);

  final SharedPreferencesAsync _prefs;

  static String _key(String barcode) => 'off_cache.$barcode';

  @override
  Future<CachedOffProduct?> read(String barcode) async {
    final raw = await _prefs.getString(_key(barcode));
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return CachedOffProduct(
        product: json['product'] as Map<String, dynamic>,
        fetchedAt: DateTime.parse(json['fetched_at'] as String),
      );
    } on Object {
      // Entrada corrompida: descarta e busca de novo.
      await remove(barcode);
      return null;
    }
  }

  @override
  Future<void> write(String barcode, CachedOffProduct entry) =>
      _prefs.setString(
        _key(barcode),
        jsonEncode({
          'product': entry.product,
          'fetched_at': entry.fetchedAt.toUtc().toIso8601String(),
        }),
      );

  @override
  Future<void> remove(String barcode) => _prefs.remove(_key(barcode));
}

class InMemoryOffCache implements OffCache {
  final _entries = <String, CachedOffProduct>{};

  @override
  Future<CachedOffProduct?> read(String barcode) async => _entries[barcode];

  @override
  Future<void> write(String barcode, CachedOffProduct entry) async =>
      _entries[barcode] = entry;

  @override
  Future<void> remove(String barcode) async => _entries.remove(barcode);
}
