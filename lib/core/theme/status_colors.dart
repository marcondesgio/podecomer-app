import 'package:flutter/material.dart';

import '../engine/verdict_status.dart';

/// Cores de um status: [solid] (selo/faixa) com [onSolid] por cima, e
/// [container] (fundo suave) com [onContainer] por cima.
@immutable
class StatusPalette {
  const StatusPalette({
    required this.solid,
    required this.onSolid,
    required this.container,
    required this.onContainer,
  });

  final Color solid;
  final Color onSolid;
  final Color container;
  final Color onContainer;

  static StatusPalette lerp(StatusPalette a, StatusPalette b, double t) =>
      StatusPalette(
        solid: Color.lerp(a.solid, b.solid, t)!,
        onSolid: Color.lerp(a.onSolid, b.onSolid, t)!,
        container: Color.lerp(a.container, b.container, t)!,
        onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
      );
}

/// Cores reservadas aos 4 status. Nunca usar para decoração, botões de
/// marca ou ilustração, e sempre acompanhar de ícone + palavra.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  const StatusColors({
    required this.safe,
    required this.caution,
    required this.doNotConsume,
    required this.inconclusive,
  });

  final StatusPalette safe;
  final StatusPalette caution;
  final StatusPalette doNotConsume;
  final StatusPalette inconclusive;

  static const light = StatusColors(
    safe: StatusPalette(
      solid: Color(0xFF1E7A46),
      onSolid: Colors.white,
      container: Color(0xFFE3F3E8),
      onContainer: Color(0xFF165C35),
    ),
    // Âmbar nunca leva texto branco.
    caution: StatusPalette(
      solid: Color(0xFFF2B233),
      onSolid: Color(0xFF3A2600),
      container: Color(0xFFFCF0D6),
      onContainer: Color(0xFF7A4A00),
    ),
    doNotConsume: StatusPalette(
      solid: Color(0xFFC0362C),
      onSolid: Colors.white,
      container: Color(0xFFFBE5E2),
      onContainer: Color(0xFF9A2A22),
    ),
    inconclusive: StatusPalette(
      solid: Color(0xFF5E7286),
      onSolid: Colors.white,
      container: Color(0xFFE7ECF1),
      onContainer: Color(0xFF45566A),
    ),
  );

  static const dark = StatusColors(
    safe: StatusPalette(
      solid: Color(0xFF5BC98A),
      onSolid: Color(0xFF173A27),
      container: Color(0xFF173A27),
      onContainer: Color(0xFF5BC98A),
    ),
    caution: StatusPalette(
      solid: Color(0xFFF5C056),
      onSolid: Color(0xFF3A2D10),
      container: Color(0xFF3A2D10),
      onContainer: Color(0xFFF5C056),
    ),
    doNotConsume: StatusPalette(
      solid: Color(0xFFFF8A7E),
      onSolid: Color(0xFF3F1C19),
      container: Color(0xFF3F1C19),
      onContainer: Color(0xFFFF8A7E),
    ),
    inconclusive: StatusPalette(
      solid: Color(0xFFA7B8CA),
      onSolid: Color(0xFF253039),
      container: Color(0xFF253039),
      onContainer: Color(0xFFA7B8CA),
    ),
  );

  StatusPalette of(VerdictStatus status) => switch (status) {
    VerdictStatus.safe => safe,
    VerdictStatus.caution => caution,
    VerdictStatus.doNotConsume => doNotConsume,
    VerdictStatus.inconclusive => inconclusive,
  };

  @override
  StatusColors copyWith({
    StatusPalette? safe,
    StatusPalette? caution,
    StatusPalette? doNotConsume,
    StatusPalette? inconclusive,
  }) => StatusColors(
    safe: safe ?? this.safe,
    caution: caution ?? this.caution,
    doNotConsume: doNotConsume ?? this.doNotConsume,
    inconclusive: inconclusive ?? this.inconclusive,
  );

  @override
  StatusColors lerp(StatusColors? other, double t) {
    if (other == null) return this;
    return StatusColors(
      safe: StatusPalette.lerp(safe, other.safe, t),
      caution: StatusPalette.lerp(caution, other.caution, t),
      doNotConsume: StatusPalette.lerp(doNotConsume, other.doNotConsume, t),
      inconclusive: StatusPalette.lerp(inconclusive, other.inconclusive, t),
    );
  }
}

extension StatusColorsContext on BuildContext {
  StatusColors get statusColors => Theme.of(this).extension<StatusColors>()!;
}
