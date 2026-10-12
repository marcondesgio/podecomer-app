import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pode_comer/core/engine/verdict_status.dart';
import 'package:pode_comer/core/theme/app_theme.dart';
import 'package:pode_comer/core/theme/status_colors.dart';

/// Contraste WCAG entre duas cores opacas.
double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  for (final (name, theme) in [
    ('claro', AppTheme.light),
    ('escuro', AppTheme.dark),
  ]) {
    group('tema $name', () {
      final status = theme.extension<StatusColors>()!;

      test('tem cores para os 4 status', () {
        for (final s in VerdictStatus.values) {
          expect(status.of(s), isNotNull);
        }
      });

      test('pares de texto de status atingem AA (4,5:1)', () {
        for (final s in VerdictStatus.values) {
          final p = status.of(s);
          expect(
            _contrast(p.solid, p.onSolid),
            greaterThanOrEqualTo(4.5),
            reason: '$s solid',
          );
          expect(
            _contrast(p.container, p.onContainer),
            greaterThanOrEqualTo(4.5),
            reason: '$s container',
          );
        }
      });

      test('texto principal sobre fundo atinge AA', () {
        final c = theme.colorScheme;
        expect(_contrast(c.surface, c.onSurface), greaterThanOrEqualTo(4.5));
        expect(_contrast(c.primary, c.onPrimary), greaterThanOrEqualTo(4.5));
      });
    });
  }
}
