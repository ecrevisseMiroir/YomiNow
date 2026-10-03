import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/screens/camera_scanner.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

import '../fakes.dart';

void main() {
  testWidgets('camera controls follow both themes', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await tester.pumpWidget(
        withServices(
          fakeServices(),
          const CameraScanner(),
          theme: YomiNowTheme.light,
          darkTheme: YomiNowTheme.dark,
          themeMode: mode,
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      final colorScheme = mode == ThemeMode.dark
          ? YomiNowTheme.dark.colorScheme
          : YomiNowTheme.light.colorScheme;

      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        colorScheme.surface,
      );
      expect(
        tester.widget<Text>(find.text('Gallery')).style?.color,
        colorScheme.onSurface,
      );
      expect(
        tester.widget<Text>(find.text('Photo')).style?.color,
        YomiNowPalette.cream,
      );
    }
  });
}
