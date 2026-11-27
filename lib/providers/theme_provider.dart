import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

/// Appearance mode. [system] follows the platform brightness, [black] is a
/// true black AMOLED theme. [isLight] is kept as a compatibility getter so
/// older call sites keep working while the UI migrates to [themeMode].
enum ThemeModeKind { system, light, dark, black }

/// Appearance settings: theme mode, accent color, font scale, and motion.
/// Same singleton shape as LanguageProvider.
class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider instance = ThemeProvider._internal();

  ThemeProvider._internal();

  static const _kLight = 'theme_light';
  static const _kMode = 'theme_mode';
  static const _kAccent = 'theme_accent';
  static const _kFontScale = 'theme_font_scale';
  static const _kReduceMotion = 'theme_reduce_motion';

  static const List<Color> accents = [
    Color(0xFF7C6CFF), // signature purple
    Color(0xFF5B9DFF), // blue
    Color(0xFF3ED3A7), // teal
    Color(0xFFFF9E57), // orange
    Color(0xFFFF6C9C), // pink
  ];

  ThemeModeKind themeMode = ThemeModeKind.dark;
  int accentIndex = 0;
  double fontScale = 1.0;
  bool reduceMotion = false;

  Color get accent => accents[accentIndex.clamp(0, accents.length - 1)];

  /// Kept for call sites that only need a boolean. System mode resolves to
  /// dark here because the provider has no [BuildContext]; [PaletteX] and
  /// [main.dart] resolve the system brightness properly.
  bool get isLight => themeMode == ThemeModeKind.light;

  ThemeMode get materialThemeMode => switch (themeMode) {
        ThemeModeKind.system => ThemeMode.system,
        ThemeModeKind.light => ThemeMode.light,
        ThemeModeKind.dark || ThemeModeKind.black => ThemeMode.dark,
      };

  bool isEffectivelyLight(Brightness platform) => switch (themeMode) {
        ThemeModeKind.system => platform == Brightness.light,
        ThemeModeKind.light => true,
        ThemeModeKind.dark || ThemeModeKind.black => false,
      };

  AppPalette paletteFor(Brightness platform) {
    final light = isEffectivelyLight(platform);
    if (themeMode == ThemeModeKind.black && !light) {
      return AppPalette.black(accent);
    }
    return light ? AppPalette.light(accent) : AppPalette.dark(accent);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Migrate the old boolean key once, so existing installs keep their
    // chosen look instead of snapping back to dark.
    final storedMode = prefs.getString(_kMode);
    if (storedMode == null) {
      themeMode =
          (prefs.getBool(_kLight) ?? false) ? ThemeModeKind.light : ThemeModeKind.dark;
      await prefs.setString(_kMode, themeMode.name);
    } else {
      themeMode = ThemeModeKind.values.firstWhere(
        (m) => m.name == storedMode,
        orElse: () => ThemeModeKind.dark,
      );
    }
    accentIndex =
        (prefs.getInt(_kAccent) ?? 0).clamp(0, accents.length - 1);
    fontScale = (prefs.getDouble(_kFontScale) ?? 1.0).clamp(0.85, 1.3);
    reduceMotion = prefs.getBool(_kReduceMotion) ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeModeKind value) async {
    themeMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kMode, value.name);
  }

  /// Compatibility setter used by older UI. Maps to the explicit light and
  /// dark modes so the old two-way switch keeps its exact behavior.
  Future<void> setLight(bool value) =>
      setThemeMode(value ? ThemeModeKind.light : ThemeModeKind.dark);

  Future<void> setAccent(int index) async {
    accentIndex = index.clamp(0, accents.length - 1);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAccent, accentIndex);
  }

  Future<void> setFontScale(double value) async {
    fontScale = value.clamp(0.85, 1.3);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontScale, fontScale);
  }

  Future<void> setReduceMotion(bool value) async {
    reduceMotion = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReduceMotion, value);
  }
}

/// Active palette for the current theme, accent, and platform brightness.
/// Subscribes to ThemeProvider, so widgets repaint on theme switch.
extension PaletteX on BuildContext {
  AppPalette get palette {
    final t = Provider.of<ThemeProvider>(this, listen: true);
    final brightness =
        MediaQuery.maybeOf(this)?.platformBrightness ?? Brightness.dark;
    return t.paletteFor(brightness);
  }

  /// True when the app or platform asked for gentler motion.
  bool get motionReduced {
    // Read, do not subscribe. This getter is also used from button handlers,
    // where Provider forbids a listening read. Theme changes already rebuild
    // the tree through Consumer2 in main.dart.
    final t = Provider.of<ThemeProvider>(this, listen: false);
    return t.reduceMotion ||
        (MediaQuery.maybeOf(this)?.disableAnimations ?? false);
  }
}
