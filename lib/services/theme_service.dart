import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting theme preference to local storage.
class ThemeService {
  static const String _themeKey = 'theme_mode';

  /// Loads the saved theme mode from persistent storage.
  ///
  /// Returns [ThemeMode.light] if no preference is found.
  static Future<ThemeMode> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey) ?? 'light';

      return themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      print('Error loading theme mode: $e');
      return ThemeMode.light;
    }
  }

  /// Saves the theme mode to persistent storage.
  static Future<void> saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = themeMode == ThemeMode.dark ? 'dark' : 'light';
      await prefs.setString(_themeKey, themeModeString);
    } catch (e) {
      print('Error saving theme mode: $e');
    }
  }
}
