// End-to-end check on a desktop device: real Tesseract OCR, kuromoji and the
// bundled JMdict on test/fixtures/ja_sample.png ("日本語を勉強しています" /
// "東京に行きました").
//
//   xvfb-run flutter test integration_test -d linux
//
// Pass --dart-define=SCREENSHOT=/path/shot.png to save the final frame.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:yominow/app.dart';
import 'package:yominow/screens/image_screen.dart';
import 'package:yominow/services/app_services.dart';
import 'package:yominow/services/default_lookup_service.dart';
import 'package:yominow/services/image_preprocess.dart';
import 'package:yominow/services/kuromoji_tokenizer_service.dart';
import 'package:yominow/services/ocr/tesseract_ocr_service.dart';
import 'package:yominow/services/sqlite_dictionary_service.dart';

const _screenshot = String.fromEnvironment('SCREENSHOT');

/// Pumps frames until [finder] matches, or fails after [timeout].
Future<void> _pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 90),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      fail('Timed out waiting for $finder');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _saveScreenshot(GlobalKey key, String path) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final image = await boundary.toImage();
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  await File(path).writeAsBytes(png!.buffer.asUint8List());
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OCR a photo, tap a word, see its JMdict entry', (tester) async {
    final fixture = File('test/fixtures/ja_sample.png').absolute.path;
    expect(File(fixture).existsSync(), isTrue, reason: 'run from repo root');

    final tokenizer = KuromojiTokenizerService();
    final services = AppServices(
      ocr: TesseractOcrService(),
      imagePreprocessor: DefaultImagePreprocessor(),
      tokenizer: tokenizer,
      lookup: DefaultLookupService(
        tokenizer: tokenizer,
        dictionary: SqliteDictionaryService(),
      ),
    );
    final boundary = GlobalKey();

    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: AppServicesScope(
          services: services,
          child: MaterialApp(
            theme: yomiNowTheme(),
            home: ImageScreen(imagePath: fixture),
          ),
        ),
      ),
    );

    // Tap 日 in the first line; the word there is 日本語.
    final firstChar = find.byKey(const ValueKey('word-0-0'));
    await _pumpUntil(tester, firstChar);
    await tester.tap(firstChar);

    await _pumpUntil(tester, find.textContaining('Japanese (language)'));
    expect(find.text('日本語'), findsWidgets);
    expect(find.textContaining('JMdict'), findsOneWidget);

    if (_screenshot.isNotEmpty) await _saveScreenshot(boundary, _screenshot);
  });
}
