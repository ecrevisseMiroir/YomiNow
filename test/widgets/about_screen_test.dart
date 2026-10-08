import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/screens/about_screen.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

import '../fakes.dart';

void main() {
  testWidgets('about screen shows the brand and links', (tester) async {
    await tester.pumpWidget(withServices(fakeServices(), const AboutScreen()));

    expect(find.text('YomiNow'), findsOneWidget);
    expect(find.text('Read Japanese Instantly'), findsOneWidget);
    expect(find.text('Licenses & Attribution'), findsOneWidget);
    expect(find.text('Third-party Libraries'), findsOneWidget);
    expect(find.text('Open Source'), findsOneWidget);
  });

  testWidgets('about text follows both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        withServices(
          fakeServices(),
          const AboutScreen(),
          theme: YomiNowTheme.light,
          darkTheme: YomiNowTheme.dark,
          themeMode: mode,
        ),
      );
      await tester.pumpAndSettle();
      final colorScheme = mode == ThemeMode.dark
          ? YomiNowTheme.dark.colorScheme
          : YomiNowTheme.light.colorScheme;

      expect(
        tester.widget<Text>(find.text('YomiNow')).style?.color,
        colorScheme.onSurface,
      );
      expect(
        tester.widget<Text>(find.text('Read Japanese Instantly')).style?.color,
        colorScheme.onSurfaceVariant,
      );
    }
  });
}
