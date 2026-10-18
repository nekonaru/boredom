import 'package:flutter/material.dart';

/// App version shown in the Profile footer. Keep in sync with `version:`
/// in pubspec.yaml on every release.
const String kAppVersion = '2.6.0';

/// Semantic color set. Widgets must read these through `context.palette`
/// (never hardcode AppPalette.dark/light) so Dark/Light mode and the
/// accent picker apply everywhere at once.
class AppPalette {
  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color emptyBar;

  const AppPalette({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.emptyBar,
  });

  static AppPalette dark(Color accent) => AppPalette(
        background: const Color(0xFF0E0E12),
        surface: const Color(0xFF17171D),
        surfaceElevated: const Color(0xFF1F1F27),
        accent: accent,
        textPrimary: const Color(0xFFF4F4F7),
        textSecondary: const Color(0xFF9B9BA8),
        success: const Color(0xFF57D19C),
        warning: const Color(0xFFE0B457),
        danger: const Color(0xFFE0637A),
        emptyBar: const Color(0xFF2A2A33),
      );

  static AppPalette light(Color accent) => AppPalette(
        background: const Color(0xFFF1F1F4),
        surface: const Color(0xFFFFFFFF),
        surfaceElevated: const Color(0xFFE7E7EC),
        accent: accent,
        textPrimary: const Color(0xFF16161B),
        textSecondary: const Color(0xFF62626E),
        success: const Color(0xFF1F9D66),
        warning: const Color(0xFFB07E1F),
        danger: const Color(0xFFC93A56),
        emptyBar: const Color(0xFFDCDCE1),
      );
}

ThemeData buildBoredomTheme({required bool light, required Color accent}) {
  final pal = light ? AppPalette.light(accent) : AppPalette.dark(accent);
  final base = ThemeData(
    useMaterial3: true,
    brightness: light ? Brightness.light : Brightness.dark,
    colorSchemeSeed: accent,
    scaffoldBackgroundColor: pal.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: accent,
      surface: pal.surface,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: pal.textPrimary,
      displayColor: pal.textPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: pal.background,
      foregroundColor: pal.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: pal.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: pal.surface,
      indicatorColor: accent.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.all(
        TextStyle(fontSize: 11, color: pal.textSecondary),
      ),
    ),
  );
}
