import 'package:freezed_annotation/freezed_annotation.dart';

import '../../engine/models.dart';

part 'product_record.freezed.dart';

/// De onde vieram os dados do produto, em ordem de confiança.
enum ProductOrigin {
  /// Base própria, revisada.
  ownVerified,

  /// Open Food Facts.
  openFoodFacts,

  /// Cadastro da comunidade ainda não revisado.
  ownPending;

  bool get isVerified => this != ownPending;
}

/// Produto encontrado em alguma fonte, com a origem e a data dos dados.
/// [product] é o que o `AllergenEngine` consome.
@freezed
abstract class ProductRecord with _$ProductRecord {
  const factory ProductRecord({
    required String barcode,
    required ProductOrigin origin,
    required Product product,
    String? name,
    String? brand,

    /// Categoria mais específica (usada para alternativas seguras).
    String? category,
    String? imageUrl,

    /// Última atualização dos dados na fonte.
    DateTime? updatedAt,

    /// Veio do cache local do Open Food Facts.
    @Default(false) bool fromCache,
  }) = _ProductRecord;
}
