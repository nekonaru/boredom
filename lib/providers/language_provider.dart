import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app display language (English default, Indonesian optional).
/// Persists the selection so it survives app restarts.
class LanguageProvider extends ChangeNotifier {
  static final LanguageProvider instance = LanguageProvider._internal();

  LanguageProvider._internal();

  static const _prefsKey = 'language_code';

  /// Currently active locale. English is the default.
  Locale locale = const Locale('en');

  String get code => locale.languageCode;

  bool get isIndonesian => code == 'id';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == 'id') {
      locale = const Locale('id');
    } else {
      locale = const Locale('en');
    }
    notifyListeners();
  }

  Future<void> setLocale(Locale value) async {
    final normalized = value.languageCode == 'id' ? 'id' : 'en';
    locale = Locale(normalized);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, normalized);
  }
}
