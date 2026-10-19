import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/error/app_logger.dart';
import '../core/error/failures.dart';

class ThemePreferencesService {
  static const _darkModeKey = 'dark_mode';

  /// Falls back to light mode if local storage is unreadable.
  Future<ThemeMode> loadThemeMode() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return preferences.getBool(_darkModeKey) == true
          ? ThemeMode.dark
          : ThemeMode.light;
    } catch (error, stackTrace) {
      AppLogger.error('Could not load theme mode',
          error: error, stackTrace: stackTrace, name: 'cache');
      return ThemeMode.light;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_darkModeKey, mode == ThemeMode.dark);
    } catch (error, stackTrace) {
      throw CacheFailure(cause: error, stackTrace: stackTrace);
    }
  }
}
