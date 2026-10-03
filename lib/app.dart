import 'package:flutter/material.dart';
import 'package:yominow/screens/licenses/open_source_screen.dart';
import 'package:yominow/screens/licenses/third_party_libraries_screen.dart';

import 'screens/about_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/home_screen.dart';
import 'screens/licenses/licenses_screen.dart';
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
          '/licenses': (_) => const LicensesScreen(),
          '/third-party-libraries': (_) => const ThirdPartyLibrariesScreen(),
          '/open-source': (_) => const OpenSourceScreen(),
        },
      ),
    );
  }
}
