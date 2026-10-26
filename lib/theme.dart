import 'package:flutter/material.dart';

class ThemePalette {
  final Color background, primary, number, tile;
  const ThemePalette(this.background, this.primary, this.number, this.tile);
  static const warm = ThemePalette(
    Color(0xFFFFF5E6),
    Color(0xFFD94730),
    Color(0xFF006E70),
    Color(0xFFFFFCF5),
  );
  static const night = ThemePalette(
    Color(0xFF101A32),
    Color(0xFFC0A4FF),
    Color(0xFF91E8CD),
    Color(0xFF24314D),
  );
  ThemeData build(Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: primary,
          brightness: brightness,
        ).copyWith(
          primary: primary,
          secondary: number,
          surface: tile,
          secondaryContainer: brightness == Brightness.light
              ? const Color(0xFFDCEDE7)
              : const Color(0xFF21453F),
          primaryContainer: brightness == Brightness.light
              ? const Color(0xFFFFDFCE)
              : const Color(0xFF453763),
          surfaceContainerLow: tile,
        );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(backgroundColor: background, centerTitle: true),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 64),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
