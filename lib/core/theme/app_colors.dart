import 'package:flutter/material.dart';

/// Tokens de cor do Design System v2.0 (docs/Pode Comer — Design System.pdf).
abstract final class AppColors {
  // Marca
  static const jabuticaba = Color(0xFF5B2A7A); // primária
  static const manga = Color(0xFFFF8F5E); // calor, ilustração
  static const lilas = Color(0xFFF1E6F6); // seleção
  static const azulCalmo = Color(0xFF3D6E8F); // links, info

  // Neutros — claro
  static const massa = Color(0xFFFFF8F0); // fundo
  static const farinha = Color(0xFFF7EDE2); // superfície
  static const areia = Color(0xFFEADCCB); // bordas
  static const tinta = Color(0xFF2A1F2D); // texto
  static const textoSecundario = Color(0xFF5E5463);

  // Neutros — escuro
  static const darkBackground = Color(0xFF1A1220);
  static const darkSurface = Color(0xFF241A2C);
  static const darkPrimary = Color(0xFFC9A2E6);
  static const darkText = Color(0xFFF4EEF5);
}
