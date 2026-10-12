import 'package:freezed_annotation/freezed_annotation.dart';

import 'allergen.dart';
import 'verdict_status.dart';

part 'models.freezed.dart';

/// Produto como o motor o enxerga. A origem (base própria, Open Food Facts,
/// cadastro) é resolvida antes, na camada de dados.
@freezed
abstract class Product with _$Product {
  const Product._();

  const factory Product({
    /// Lista de ingredientes como está no rótulo (ou lida por OCR).
    @Default('') String ingredientsText,

    /// Alergênicos declarados como presentes ("CONTÉM ...", tags do OFF).
    @Default(<Allergen>{}) Set<Allergen> allergensContains,

    /// Alergênicos declarados como traços ("PODE CONTER ...").
    @Default(<Allergen>{}) Set<Allergen> allergensTraces,

    /// A lista de ingredientes é completa e confiável.
    required bool hasIngredients,
  }) = _Product;

  /// Só há ingredientes se a fonte disser que sim e houver texto.
  bool get hasUsableIngredients =>
      hasIngredients && ingredientsText.trim().isNotEmpty;
}

@freezed
abstract class PersonAllergy with _$PersonAllergy {
  const factory PersonAllergy({
    required Allergen allergen,
    @Default(AllergySeverity.mild) AllergySeverity severity,
  }) = _PersonAllergy;
}

@freezed
abstract class Person with _$Person {
  const factory Person({
    required String id,
    required String name,
    @Default(<PersonAllergy>[]) List<PersonAllergy> allergies,
  }) = _Person;
}

enum ReasonKind {
  /// Ingrediente ou declaração "contém".
  contains,

  /// "Pode conter" / traços.
  traces,

  /// Ingrediente que pode ou não conter o alergênico (ex.: "aroma de manteiga").
  ambiguous,

  /// Produto encontrado, mas sem lista de ingredientes utilizável.
  noIngredients,

  /// Produto não encontrado em nenhuma base.
  productNotFound,
}

enum ReasonSource {
  /// Encontrado no texto de ingredientes.
  ingredientsText,

  /// `Product.allergensContains`.
  declaredContains,

  /// `Product.allergensTraces`.
  declaredTraces,

  /// Sobre o produto como um todo (não encontrado / sem ingredientes).
  product,
}

/// Por que um status foi elevado além do padrão do tipo de motivo.
enum Escalation {
  none,

  /// Traços + alergia grave → NÃO CONSUMIR.
  severeAllergy,

  /// Traços de trigo/centeio/cevada/aveia contam como glúten (Anvisa)
  /// → NÃO CONSUMIR para quem tem restrição a glúten.
  glutenTraceRule,
}

@freezed
abstract class VerdictReason with _$VerdictReason {
  const factory VerdictReason({
    required VerdictStatus status,
    required ReasonKind kind,
    @Default(ReasonSource.product) ReasonSource source,

    /// Alergênico da pessoa que motivou o status.
    Allergen? allergen,

    /// Trecho exato do texto original (ex.: "Pode conter amendoim").
    String? excerpt,

    /// Casou por tolerância a erro de OCR, não por igualdade exata.
    @Default(false) bool approximate,
    @Default(Escalation.none) Escalation escalation,
  }) = _VerdictReason;
}

@freezed
abstract class PersonVerdict with _$PersonVerdict {
  const factory PersonVerdict({
    required String personId,
    required String personName,
    required VerdictStatus status,

    /// Ordenados do mais grave para o menos grave.
    @Default(<VerdictReason>[]) List<VerdictReason> reasons,
  }) = _PersonVerdict;
}

@freezed
abstract class GroupVerdict with _$GroupVerdict {
  const factory GroupVerdict({
    /// Pior status entre as pessoas selecionadas.
    required VerdictStatus status,
    @Default(<PersonVerdict>[]) List<PersonVerdict> people,
  }) = _GroupVerdict;
}
