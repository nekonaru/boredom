import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_theme.dart';

/// Appearance settings: Dark/Light mode plus accent color.
/// Same singleton shape as LanguageProvider.
class ThemeProvider extends ChangeNotifier {
  static final ThemeProvider instance = ThemeProvider._internal();

  ThemeProvider._internal();

  static const _kLight = 'theme_light';
  static const _kAccent = 'theme_accent';

  static const List<Color> accents = [
    Color(0xFF7C6CFF), // signature purple
    Color(0xFF5B9DFF), // blue
    Color(0xFF3ED3A7), // teal
    Color(0xFFFF9E57), // orange
    Color(0xFFFF6C9C), // pink
  ];

  bool isLight = false;
  int accentIndex = 0;

  Color get accent => accents[accentIndex.clamp(0, accents.length - 1)];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLight = prefs.getBool(_kLight) ?? false;
    accentIndex =
        (prefs.getInt(_kAccent) ?? 0).clamp(0, accents.length - 1);
    notifyListeners();
  }

  Future<void> setLight(bool value) async {
    isLight = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLight, value);
  }

  Future<void> setAccent(int index) async {
    accentIndex = index.clamp(0, accents.length - 1);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kAccent, accentIndex);
  }
}

/// Active palette for the current theme and accent.
/// Subscribes to ThemeProvider, so widgets repaint on theme switch.
extension PaletteX on BuildContext {
  AppPalette get palette {
    final t = Provider.of<ThemeProvider>(this, listen: true);
    return t.isLight
        ? AppPalette.light(t.accent)
        : AppPalette.dark(t.accent);
  }
}
