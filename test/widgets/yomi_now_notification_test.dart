import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/services/yomi_now_notification_history.dart';
import 'package:yominow/theme/yomi_now_theme.dart';
import 'package:yominow/widgets/yomi_now_notification.dart';

void main() {
  testWidgets('success notification matches light and dark themes', (
    tester,
  ) async {
    for (final theme in [YomiNowTheme.light, YomiNowTheme.dark]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => YomiNowNotification.show(
                  context,
                  title: 'Added to AnkiDroid',
                  message: '日本語 was added to the YomiNow deck.',
                  kind: YomiNowNotificationKind.success,
                ),
                child: const Text('Show notification'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show notification'));
      await tester.pumpAndSettle();

      expect(find.text('Added to AnkiDroid'), findsOneWidget);
      expect(find.text('日本語 was added to the YomiNow deck.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, theme.colorScheme.surfaceContainerHigh);
      expect(snackBar.behavior, SnackBarBehavior.floating);

      await tester.tap(find.byKey(const ValueKey('yomi-notification-dismiss')));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
