import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  AppLanguage._();

  static final ValueNotifier<String> selected = ValueNotifier<String>(
    'English',
  );

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('ja'),
  ];

  static Locale localeFor(String language) {
    switch (language) {
      case 'Français':
        return const Locale('fr');
      case '日本語':
        return const Locale('ja');
      case 'English':
      default:
        return const Locale('en');
    }
  }

  static Future<void> setLanguage(String language) async {
    if (language == 'English' || language == 'Français' || language == '日本語') {
      selected.value = language;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_language', language);
    }
  }

  static String text(String key) {
    final value = <String, Map<String, String>>{
      'settings': {
        'English': 'Settings',
        'Français': 'Paramètres',
        '日本語': '設定',
      },
      'language': {'English': 'Language', 'Français': 'Langue', '日本語': '言語'},
      'choose_language': {
        'English': 'Choose language',
        'Français': 'Choisir la langue',
        '日本語': '言語を選択',
      },
      'about': {'English': 'About', 'Français': 'À propos', '日本語': '概要'},
    }[key];

    return value?[selected.value] ?? value?['English'] ?? key;
  }
}
