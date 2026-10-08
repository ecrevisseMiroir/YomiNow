import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/app.dart';
import 'package:yominow/screens/home_screen.dart';
import 'package:yominow/screens/splash_screen.dart';
import 'package:yominow/services/app_appearance.dart';
import 'package:yominow/services/app_services.dart';
import 'package:yominow/theme/yomi_now_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  testWidgets('splash fits a landscape viewport', (tester) async {
    tester.view.physicalSize = const Size(800, 400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(YomiNowApp(services: fakeServices()));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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
    expect(app.darkTheme!.colorScheme.onSurface, YomiNowPalette.cream);
    expect(app.themeMode, ThemeMode.system);
    expect(YomiNowPalette.coral, const Color(0xFFFF6B7A));
    expect(YomiNowPalette.indigo, const Color(0xFF3B82F6));
    expect(YomiNowPalette.softBlue, const Color(0xFFE6F0FF));
  });

  testWidgets('applies and persists the selected theme mode', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await AppAppearance.load();
    addTearDown(() => AppAppearance.selected.value = ThemeMode.system);

    await tester.pumpWidget(YomiNowApp(services: fakeServices()));
    await AppAppearance.setThemeMode(ThemeMode.dark);
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('selected_theme_mode'), 'dark');
  });
}
