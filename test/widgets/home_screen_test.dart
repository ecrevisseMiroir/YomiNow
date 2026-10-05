import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yominow/screens/home_screen.dart';
import 'package:yominow/screens/image_screen.dart';
import 'package:yominow/services/yomi_now_notification_history.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

import '../fakes.dart';

/// An [ImagePicker] that returns [file], or throws [error], and records the
/// sources it was asked for.
class FakePicker extends Fake implements ImagePicker {
  FakePicker({this.file, this.error});

  final XFile? file;
  final Object? error;
  final sources = <ImageSource>[];

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    sources.add(source);
    if (error case final error?) throw error;
    return file;
  }
}

final _desktop = TargetPlatformVariant.only(TargetPlatform.linux);
final _mobile = TargetPlatformVariant({
  TargetPlatform.android,
  TargetPlatform.iOS,
});

void main() {
  setUpAll(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pumpHomeWithTheme(WidgetTester tester, ThemeMode mode) {
    return tester.pumpWidget(
      withServices(
        fakeServices(),
        const HomeScreen(),
        theme: YomiNowTheme.light,
        darkTheme: YomiNowTheme.dark,
        themeMode: mode,
      ),
    );
  }

  Future<void> pumpHome(
    WidgetTester tester, {
    ImagePicker? picker,
    FakeImagePreprocessor? preprocessor,
  }) {
    return tester.pumpWidget(
      withServices(
        fakeServices(imagePreprocessor: preprocessor),
        HomeScreen(picker: picker),
      ),
    );
  }

  testWidgets('shows the app name and a hint', (tester) async {
    await pumpHome(tester);

    expect(find.text('YomiNow'), findsOneWidget);
    expect(find.textContaining('tap any word'), findsOneWidget);
  });

  testWidgets('notification bell opens and clears notification history', (
    tester,
  ) async {
    final history = YomiNowNotificationHistory.instance;
    await history.clear();
    await history.add(
      title: 'Added to AnkiDroid',
      message: '日本語 was added to the YomiNow deck.',
      kind: YomiNowNotificationKind.success,
    );
    await pumpHome(tester);
    await tester.pumpAndSettle();

    expect(history.unreadCount, 1);
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();

    expect(find.text('Added to AnkiDroid'), findsOneWidget);
    expect(find.text('日本語 was added to the YomiNow deck.'), findsOneWidget);
    expect(history.unreadCount, 0);

    await tester.tap(find.byKey(const ValueKey('notification-history-clear')));
    await tester.pumpAndSettle();

    expect(find.text("You're all caught up"), findsOneWidget);
    await history.clear();
  });

  testWidgets('home text follows light and dark theme colors', (tester) async {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      await pumpHomeWithTheme(tester, mode);
      await tester.pumpAndSettle();
      final colorScheme = mode == ThemeMode.dark
          ? YomiNowTheme.dark.colorScheme
          : YomiNowTheme.light.colorScheme;

      expect(
        tester.widget<Text>(find.text('Welcome!')).style?.color,
        colorScheme.onSurface,
      );
      expect(
        tester.widget<Text>(find.textContaining('tap any word')).style?.color,
        colorScheme.onSurfaceVariant,
      );
    }
  });

  testWidgets('desktop offers only "Open image"', variant: _desktop, (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Open image'), findsOneWidget);
    expect(find.text('Take photo'), findsNothing);
    expect(find.text('Choose from gallery'), findsNothing);
  });

  testWidgets('mobile offers camera and gallery', variant: _mobile, (
    tester,
  ) async {
    await pumpHome(tester);

    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
    expect(find.text('Open image'), findsNothing);
  });

  testWidgets('picking an image opens the image screen', variant: _desktop, (
    tester,
  ) async {
    final preprocessor = FakeImagePreprocessor();
    addTearDown(preprocessor.deleteFiles);
    await preloadImage(tester, preprocessor);
    final picker = FakePicker(file: XFile('/photos/menu.jpg'));
    await pumpHome(tester, picker: picker, preprocessor: preprocessor);

    await tester.tap(find.text('Open image'));
    await tester.pumpAndSettle();

    expect(picker.sources, [ImageSource.gallery]);
    final screen = tester.widget<ImageScreen>(find.byType(ImageScreen));
    expect(screen.imagePath, '/photos/menu.jpg');
    expect(preprocessor.prepared, ['/photos/menu.jpg']);
  });

  testWidgets(
    '"Take photo" uses the camera and "Choose from gallery" the gallery',
    variant: _mobile,
    (tester) async {
      final picker = FakePicker();
      await pumpHome(tester, picker: picker);

      await tester.tap(find.text('Take photo'));
      await tester.pump();
      await tester.tap(find.text('Choose from gallery'));
      await tester.pump();

      expect(picker.sources, [ImageSource.camera, ImageSource.gallery]);
    },
  );

  testWidgets(
    'cancelling the picker stays on the home screen',
    variant: _desktop,
    (tester) async {
      await pumpHome(tester, picker: FakePicker());

      await tester.tap(find.text('Open image'));
      await tester.pumpAndSettle();

      expect(find.byType(ImageScreen), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    },
  );

  testWidgets(
    'a picker error shows the shared error dialog',
    variant: _mobile,
    (tester) async {
      final picker = FakePicker(
        error: PlatformException(code: 'camera_access_denied'),
      );
      await pumpHome(tester, picker: picker);

      await tester.tap(find.text('Take photo'));
      await tester.pump();

      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.byType(ImageScreen), findsNothing);
    },
  );
}
