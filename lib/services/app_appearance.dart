import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppAppearance {
  static const _preferenceKey = 'selected_theme_mode';

  static final ValueNotifier<ThemeMode> selected = ValueNotifier<ThemeMode>(
    ThemeMode.system,
  );

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    selected.value = switch (prefs.getString(_preferenceKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    selected.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_preferenceKey, mode.name);
  }
}
