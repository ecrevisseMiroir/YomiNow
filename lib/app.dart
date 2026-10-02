import 'package:flutter/material.dart';

import 'screens/about_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_services.dart';
import 'theme/yomi_now_theme.dart';

/// The root widget provides app services and the system-aware theme to screens.
class YomiNowApp extends StatelessWidget {
  const YomiNowApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: services,
      child: MaterialApp(
        title: 'YomiNow',
        theme: YomiNowTheme.light,
        darkTheme: YomiNowTheme.dark,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/documents': (_) => const DocumentsScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/about': (_) => const AboutScreen(),
        },
      ),
    );
  }
}
