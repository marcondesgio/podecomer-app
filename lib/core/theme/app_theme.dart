import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'status_colors.dart';

/// Medidas do Design System v2.0.
abstract final class AppSizes {
  static const screenMargin = 20.0;
  static const minTouchTarget = 48.0;
  static const primaryButtonHeight = 60.0;

  static const radiusChip = 999.0;
  static const radiusField = 14.0;
  static const radiusButton = 18.0;
  static const radiusCard = 20.0;
}

abstract final class AppTheme {
  /// Nunito ainda não está empacotada em assets/fonts; até lá o Flutter usa
  /// a fonte padrão do sistema.
  static const _fontFamily = 'Nunito';

  static ThemeData get light => _build(
    brightness: Brightness.light,
    scheme: ColorScheme.fromSeed(
      seedColor: AppColors.jabuticaba,
      brightness: Brightness.light,
      primary: AppColors.jabuticaba,
      onPrimary: Colors.white,
      secondary: AppColors.manga,
      tertiary: AppColors.azulCalmo,
      surface: AppColors.massa,
      onSurface: AppColors.tinta,
      onSurfaceVariant: AppColors.textoSecundario,
      surfaceContainer: AppColors.farinha,
      outline: AppColors.areia,
      secondaryContainer: AppColors.lilas,
    ),
    statusColors: StatusColors.light,
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    scheme: ColorScheme.fromSeed(
      seedColor: AppColors.jabuticaba,
      brightness: Brightness.dark,
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.manga,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkText,
      surfaceContainer: AppColors.darkSurface,
    ),
    statusColors: StatusColors.dark,
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required StatusColors statusColors,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      extensions: [statusColors],
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme, scheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSizes.primaryButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusButton),
          ),
          textStyle: const TextStyle(
            fontFamily: _fontFamily,
            fontSize: 18,
            height: 24 / 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusCard),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusChip),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusField),
        ),
      ),
    );
  }

  /// Escala tipográfica do DS: base 16; nada abaixo de 13.
  static TextTheme _textTheme(TextTheme base, ColorScheme scheme) {
    TextStyle s(double size, double line, FontWeight weight) => TextStyle(
      fontFamily: _fontFamily,
      fontSize: size,
      height: line / size,
      fontWeight: weight,
      color: scheme.onSurface,
    );

    return base.copyWith(
      displaySmall: s(32, 40, FontWeight.w800),
      headlineMedium: s(28, 36, FontWeight.w800),
      headlineSmall: s(22, 30, FontWeight.w700),
      titleLarge: s(18, 26, FontWeight.w700),
      titleMedium: s(16, 24, FontWeight.w700),
      bodyLarge: s(16, 24, FontWeight.w400),
      bodyMedium: s(16, 24, FontWeight.w400),
      labelLarge: s(14, 20, FontWeight.w600),
      bodySmall: s(
        13,
        18,
        FontWeight.w600,
      ).copyWith(color: scheme.onSurfaceVariant),
      labelSmall: s(13, 18, FontWeight.w600),
    );
  }
}
