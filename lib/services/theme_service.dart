import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static const String _darkMode = 'dark';
  static const String _lightMode = 'light';

  // Obtenir le thème actuel
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = prefs.getString(_themeKey) ?? _lightMode; // Mode jour par défaut

    return themeMode == _darkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Changer le thème
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = mode == ThemeMode.dark ? _darkMode : _lightMode;

    // Note: Les couleurs sont maintenant constantes et définies en mode nuit par défaut

    await prefs.setString(_themeKey, themeMode);
  }

  // Basculer entre les modes
  static Future<ThemeMode> toggleThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final currentMode = prefs.getString(_themeKey) ?? _lightMode; // Utiliser le mode par défaut (jour)
    final newMode = currentMode == _darkMode ? _lightMode : _darkMode;

    // Note: Les couleurs sont maintenant constantes et définies en mode nuit par défaut

    await prefs.setString(_themeKey, newMode);
    return newMode == _darkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
