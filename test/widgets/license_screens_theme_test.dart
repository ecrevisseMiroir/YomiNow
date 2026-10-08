import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/screens/licenses/licenses_screen.dart';
import 'package:yominow/screens/licenses/open_source_screen.dart';
import 'package:yominow/screens/licenses/third_party_libraries_screen.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

import '../fakes.dart';

void main() {
  testWidgets('license screens follow light and dark themes', (tester) async {
    final screens = <({Widget screen, String title})>[
      (screen: const LicensesScreen(), title: 'Licenses & Attribution'),
      (
        screen: const ThirdPartyLibrariesScreen(),
        title: 'Third-party Libraries',
      ),
      (screen: const OpenSourceScreen(), title: 'Open Source'),
    ];

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      final colorScheme = mode == ThemeMode.dark
          ? YomiNowTheme.dark.colorScheme
          : YomiNowTheme.light.colorScheme;
      for (final item in screens) {
        await tester.pumpWidget(
          withServices(
            fakeServices(),
            item.screen,
            theme: YomiNowTheme.light,
            darkTheme: YomiNowTheme.dark,
            themeMode: mode,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          colorScheme.surface,
        );
        expect(
          tester.widget<Text>(find.text(item.title)).style?.color,
          colorScheme.onSurface,
        );
      }
    }
  });
}
