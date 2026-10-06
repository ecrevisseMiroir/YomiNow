import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/screens/loading_screen.dart';

void main() {
  testWidgets('loading screen fits portrait and landscape layouts', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: LoadingScreen()));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Processing Image...'), findsOneWidget);
        expect(find.text('Running OCR...'), findsOneWidget);
    expect(tester.takeException(), isNull);

    tester.view.physicalSize = const Size(844, 390);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Processing Image...'), findsOneWidget);
        expect(find.text('Running OCR...'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
