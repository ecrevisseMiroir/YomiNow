import 'package:flutter/material.dart';

/// Brand colors from the YomiNow palette. Use [Theme.of] for semantic UI
/// colors and these values for intentional brand accents.
abstract final class YomiNowPalette {
  static const coral = Color(0xFFFF6B7A);
  static const indigo = Color(0xFF3B82F6);
  static const softBlue = Color(0xFFE6F0FF);
  static const cream = Color(0xFFFFF9F5);
  static const ink = Color(0xFF142D4E);
  static const darkSurface = Color(0xFF151923);
}

/// Material 3 themes for YomiNow. The app follows the device theme by default.
abstract final class YomiNowTheme {
  static final ThemeData light = _build(Brightness.light);
  static final ThemeData dark = _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: YomiNowPalette.indigo,
          brightness: brightness,
          surface: isDark ? YomiNowPalette.darkSurface : YomiNowPalette.cream,
        ).copyWith(
          tertiary: YomiNowPalette.softBlue,
          onTertiary: YomiNowPalette.ink,
        );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      fontFamilyFallback: const ['NotoSansJP'],
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: YomiNowPalette.coral,
          foregroundColor: YomiNowPalette.ink,
        ),
      ),
    );
  }
}
