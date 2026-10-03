import 'package:flutter/material.dart';
import 'package:yominow/screens/licenses/open_source_screen.dart';
import 'package:yominow/screens/licenses/third_party_libraries_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:yominow/l10n/app_localizations.dart';

import 'screens/about_screen.dart';
import 'screens/documents_screen.dart';
import 'screens/home_screen.dart';
import 'screens/licenses/licenses_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/app_appearance.dart';
import 'services/app_language.dart';
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
      child: ListenableBuilder(
        listenable: Listenable.merge([
          AppLanguage.selected,
          AppAppearance.selected,
        ]),
        builder: (context, _) {
          final locale = AppLanguage.localeFor(AppLanguage.selected.value);
          return MaterialApp(
            title: 'YomiNow',
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: YomiNowTheme.light,
            darkTheme: YomiNowTheme.dark,
            themeMode: AppAppearance.selected.value,
            home: const SplashScreen(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/documents': (_) => const DocumentsScreen(),
              '/settings': (_) => const SettingsScreen(),
              '/about': (_) => const AboutScreen(),
              '/licenses': (_) => const LicensesScreen(),
              '/third-party-libraries': (_) =>
                  const ThirdPartyLibrariesScreen(),
              '/open-source': (_) => const OpenSourceScreen(),
            },
          );
        },
      ),
    );
  }
}
