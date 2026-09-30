import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/app.dart';
import 'package:yominow/screens/home_screen.dart';
import 'package:yominow/screens/splash_screen.dart';
import 'package:yominow/services/app_services.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

import '../fakes.dart';

void main() {
  testWidgets(
    'shows the splash screen then opens home with services in scope',
    (tester) async {
      final services = fakeServices();
      await tester.pumpWidget(YomiNowApp(services: services));

      expect(find.byType(SplashScreen), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1800));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        AppServicesScope.of(tester.element(find.byType(HomeScreen))),
        same(services),
      );
    },
  );

  testWidgets('uses the brand themes and follows the system setting', (
    tester,
  ) async {
    await tester.pumpWidget(YomiNowApp(services: fakeServices()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'YomiNow');
    expect(app.theme!.brightness, Brightness.light);
    expect(app.theme!.useMaterial3, isTrue);
    expect(app.theme!.scaffoldBackgroundColor, YomiNowPalette.cream);
    expect(app.darkTheme!.brightness, Brightness.dark);
    expect(app.themeMode, ThemeMode.system);
    expect(YomiNowPalette.coral, const Color(0xFFFF6B7A));
    expect(YomiNowPalette.indigo, const Color(0xFF3B82F6));
    expect(YomiNowPalette.softBlue, const Color(0xFFE6F0FF));
  });
}
