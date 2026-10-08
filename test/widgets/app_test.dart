import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/app.dart';
import 'package:yominow/screens/home_screen.dart';
import 'package:yominow/services/app_services.dart';

import '../fakes.dart';

void main() {
  testWidgets('starts on the home screen with services in scope', (
    tester,
  ) async {
    final services = fakeServices();
    await tester.pumpWidget(YomiNowApp(services: services));

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      AppServicesScope.of(tester.element(find.byType(HomeScreen))),
      same(services),
    );
  });

  testWidgets('uses a dark theme on a black background', (tester) async {
    await tester.pumpWidget(YomiNowApp(services: fakeServices()));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'YomiNow');
    expect(app.theme!.brightness, Brightness.dark);
    expect(app.theme!.useMaterial3, isTrue);
    expect(app.theme!.scaffoldBackgroundColor, Colors.black);
  });
}
