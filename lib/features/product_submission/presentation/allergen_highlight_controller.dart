import 'package:flutter/material.dart';

import '../../../core/engine/allergen_dictionary.dart';
import '../../../core/engine/label_analyzer.dart';
import '../../../core/theme/status_colors.dart';

/// Campo de texto que destaca, enquanto a pessoa digita, os termos que o
/// `AllergenEngine` reconhece: "contém" em vermelho claro, traços e
/// ingredientes ambíguos em âmbar claro (sempre com sublinhado, não só cor).
class AllergenHighlightController extends TextEditingController {
  AllergenHighlightController({required this.dictionary, super.text});

  final AllergenDictionary dictionary;

  /// Trechos destacados no texto atual, ordenados e sem sobreposição.
  List<({int start, int end, bool contains})> highlights() {
    final ranges = <({int start, int end, bool contains})>[
      for (final matches in analyzeLabel(text, dictionary).matches.values)
        for (final m in matches)
          (
            start: m.start,
            end: m.end,
            contains: m.kind == TextMatchKind.contains,
          ),
    ]..sort((a, b) => a.start.compareTo(b.start));

    // Mesmo termo em vários alergênicos (ex.: "leite" em leite e lactose):
    // junta, e "contém" vence.
    final merged = <({int start, int end, bool contains})>[];
    for (final r in ranges) {
      final last = merged.isEmpty ? null : merged.last;
      if (last != null && r.start < last.end) {
        merged[merged.length - 1] = (
          start: last.start,
          end: r.end > last.end ? r.end : last.end,
          contains: last.contains || r.contains,
        );
      } else {
        merged.add(r);
      }
    }
    return merged;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Durante a composição do teclado (acentos), não mexe no texto.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }

    final colors = context.statusColors;
    final children = <TextSpan>[];
    var cursor = 0;
    for (final h in highlights()) {
      if (h.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, h.start)));
      }
      final palette = h.contains ? colors.doNotConsume : colors.caution;
      children.add(
        TextSpan(
          text: text.substring(h.start, h.end),
          style: TextStyle(
            backgroundColor: palette.container,
            color: palette.onContainer,
            fontWeight: FontWeight.w800,
            decoration: TextDecoration.underline,
          ),
        ),
      );
      cursor = h.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }
    return TextSpan(style: style, children: children);
  }
}
