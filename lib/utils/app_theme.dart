import 'package:flutter/material.dart';

/// Palet warna dark-minimal buat Boredom.
/// Sengaja nggak neon/cyberpunk - lebih ke "premium dark app" vibe.
class AppColors {
  static const background = Color(0xFF0E0E12);
  static const surface = Color(0xFF17171D);
  static const surfaceElevated = Color(0xFF1F1F27);
  static const accent = Color(0xFF7C6CFF);
  static const accentSoft = Color(0xFF4C4470);
  static const textPrimary = Color(0xFFF4F4F7);
  static const textSecondary = Color(0xFF9B9BA8);
  static const success = Color(0xFF57D19C);
  static const warning = Color(0xFFE0B457);
  static const danger = Color(0xFFE0637A);
}

ThemeData buildBoredomTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: AppColors.accent,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: 'Roboto',
  );

  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.background,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.accent.withOpacity(0.25),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 11, color: AppColors.textSecondary),
      ),
    ),
  );
}
