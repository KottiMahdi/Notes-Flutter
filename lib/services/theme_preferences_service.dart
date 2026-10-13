import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferencesService {
  static const _darkModeKey = 'dark_mode';

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_darkModeKey) == true
        ? ThemeMode.dark
        : ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_darkModeKey, mode == ThemeMode.dark);
  }
}
