import 'product_record.dart';

/// Resultado de `ProductRepository.lookup`.
sealed class ProductLookupResult {
  const ProductLookupResult(this.barcode);

  final String barcode;
}

final class ProductFound extends ProductLookupResult {
  ProductFound(this.record) : super(record.barcode);

  final ProductRecord record;
}

/// Nenhuma fonte conhece o produto → INCONCLUSIVO + cadastro pela câmera.
final class ProductNotFound extends ProductLookupResult {
  const ProductNotFound(super.barcode);
}

/// Alguma fonte falhou antes de sabermos a resposta → INCONCLUSIVO com
/// "Tentar de novo". Nunca cair para uma fonte de menor prioridade.
final class ProductLookupFailed extends ProductLookupResult {
  const ProductLookupFailed(super.barcode, this.failure);

  final LookupFailure failure;
}

enum LookupFailure {
  /// Sem conexão ou conexão interrompida.
  network,

  /// Passou do tempo limite.
  timeout,

  /// Resposta inesperada do servidor.
  server,
}

/// Erro de uma fonte de dados, já classificado.
class ProductSourceException implements Exception {
  const ProductSourceException(this.failure, [this.cause]);

  final LookupFailure failure;
  final Object? cause;

  @override
  String toString() => 'ProductSourceException($failure)';
}

/// EAN-8, UPC-A, EAN-13 e GTIN-14.
bool isValidBarcode(String barcode) => RegExp(r'^\d{8,14}$').hasMatch(barcode);
