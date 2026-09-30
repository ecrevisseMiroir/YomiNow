import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/dictionary_entry.dart';
import 'package:yominow/models/ja_token.dart';
import 'package:yominow/models/lookup_result.dart';
import 'package:yominow/models/ocr_result.dart';
import 'package:yominow/screens/image_screen.dart';
import 'package:yominow/services/ocr/ocr_service.dart';
import 'package:yominow/widgets/lookup_sheet.dart';
import 'package:yominow/widgets/tokenized_text.dart';
import 'package:yominow/widgets/word_overlay.dart';

import '../fakes.dart';

const _lineA = '日本語を読む';
const _lineB = '食べます';

// The fake preprocessor produces a 200x100 image; boxes are in its pixels.
const _result = OcrResult(
  lines: [
    OcrLine(
      text: _lineA,
      words: [
        OcrWord(
          text: '日本語',
          bbox: Rect.fromLTRB(10, 10, 60, 30),
          start: 0,
          end: 3,
          confidence: 0.9,
        ),
        OcrWord(
          text: 'を',
          bbox: Rect.fromLTRB(62, 10, 72, 30),
          start: 3,
          end: 4,
        ),
        OcrWord(
          text: '読む',
          bbox: Rect.fromLTRB(74, 10, 110, 30),
          start: 4,
          end: 6,
        ),
      ],
    ),
    OcrLine(
      text: _lineB,
      words: [
        OcrWord(
          text: '食べ',
          bbox: Rect.fromLTRB(10, 50, 50, 70),
          start: 0,
          end: 2,
        ),
        OcrWord(
          text: 'ます',
          bbox: Rect.fromLTRB(52, 50, 90, 70),
          start: 2,
          end: 4,
        ),
      ],
    ),
  ],
);

const _nihongo = DictionaryEntry(
  id: 1,
  kanji: ['日本語'],
  readings: ['にほんご'],
  senses: [
    Sense(pos: ['noun'], glosses: ['Japanese (language)']),
  ],
  common: true,
);
const _yomu = DictionaryEntry(
  id: 2,
  kanji: ['読む'],
  readings: ['よむ'],
  senses: [
    Sense(pos: ['Godan verb'], glosses: ['to read']),
  ],
);
const _taberu = DictionaryEntry(
  id: 3,
  kanji: ['食べる'],
  readings: ['たべる'],
  senses: [
    Sense(pos: ['Ichidan verb'], glosses: ['to eat']),
  ],
);

final _lookups = <(String, int), LookupResult?>{
  (_lineA, 0): const LookupResult(
    matchedText: '日本語',
    start: 0,
    end: 3,
    reading: 'にほんご',
    entries: [_nihongo],
  ),
  (_lineA, 4): const LookupResult(
    matchedText: '読む',
    start: 4,
    end: 6,
    reading: 'よむ',
    entries: [_yomu],
  ),
  // A compound spanning both boxes of the line.
  (_lineB, 0): const LookupResult(
    matchedText: '食べます',
    start: 0,
    end: 4,
    reading: 'たべます',
    entries: [_taberu],
  ),
};

JaToken _token(
  String surface,
  int start, {
  String pos = '名詞',
  String? reading,
}) => JaToken(
  surface: surface,
  basicForm: surface,
  reading: reading,
  pos: pos,
  start: start,
  end: start + surface.length,
);

final _tokens = {
  _lineA: [
    _token('日本語', 0, reading: 'にほんご'),
    _token('を', 3, pos: '助詞', reading: 'を'),
    _token('読む', 4, pos: '動詞', reading: 'よむ'),
  ],
  _lineB: [
    _token('食べ', 0, pos: '動詞', reading: 'たべ'),
    _token('ます', 2, pos: '助動詞', reading: 'ます'),
  ],
};

Key _key(int line, int word) => ValueKey('word-$line-$word');

void main() {
  late FakeOcrService ocr;
  late FakeImagePreprocessor preprocessor;
  late FakeLookupService lookup;

  WordBoxState stateOf(WidgetTester tester, int line, int word) =>
      tester.widget<WordBox>(find.byKey(_key(line, word))).state;

  /// Pumps an [ImageScreen] on fakes, past preprocessing and OCR unless
  /// [ocrDelay] holds OCR back.
  Future<void> pumpScreen(
    WidgetTester tester, {
    OcrResult result = _result,
    Object? ocrError,
    Duration ocrDelay = Duration.zero,
    Object? lookupError,
    Duration lookupDelay = Duration.zero,
  }) async {
    preprocessor = FakeImagePreprocessor();
    addTearDown(preprocessor.deleteFiles);
    ocr = FakeOcrService(result: result, error: ocrError, delay: ocrDelay);
    lookup = FakeLookupService(
      results: _lookups,
      error: lookupError,
      delay: lookupDelay,
    );
    await preloadImage(tester, preprocessor);
    await tester.pumpWidget(
      withServices(
        fakeServices(
          ocr: ocr,
          imagePreprocessor: preprocessor,
          tokenizer: FakeTokenizerService(tokens: _tokens),
          lookup: lookup,
        ),
        const ImageScreen(imagePath: '/photos/sign.jpg'),
      ),
    );
    await tester.pump();
  }

  /// Lets the modal sheet finish its enter animation. Not `pumpAndSettle`:
  /// the sheet's spinner animates forever.
  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  group('pipeline and display', () {
    testWidgets('runs OCR on the prepared image', (tester) async {
      await pumpScreen(tester);

      expect(preprocessor.prepared, ['/photos/sign.jpg']);
      expect(ocr.recognized, [preprocessor.image.path]);
    });

    testWidgets('shows the image contained, with a box over every word', (
      tester,
    ) async {
      await pumpScreen(tester);

      final image = tester.getRect(find.byType(Image));
      expect(image.width / image.height, closeTo(2, 0.001));
      expect(image.width, lessThanOrEqualTo(800));
      expect(image.height, lessThanOrEqualTo(600));
      expect(find.byType(WordBox), findsNWidgets(5));

      final scale = image.width / 200;
      for (final (lineIndex, line) in _result.lines.indexed) {
        for (final (wordIndex, word) in line.words.indexed) {
          final box = tester.getRect(find.byKey(_key(lineIndex, wordIndex)));
          expect(box.left, closeTo(image.left + word.bbox.left * scale, 0.01));
          expect(box.top, closeTo(image.top + word.bbox.top * scale, 0.01));
          expect(box.width, closeTo(word.bbox.width * scale, 0.01));
          expect(box.height, closeTo(word.bbox.height * scale, 0.01));
        }
      }
    });

    testWidgets('boxes stay on their words when zooming', (tester) async {
      await pumpScreen(tester);
      expect(
        find.descendant(
          of: find.byType(InteractiveViewer),
          matching: find.byType(WordBox),
        ),
        findsNWidgets(5),
      );
      final imageBefore = tester.getRect(find.byType(Image));
      final boxBefore = tester.getRect(find.byKey(_key(0, 2)));

      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(imageBefore.center));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, -100)));
      await tester.pump();

      final imageAfter = tester.getRect(find.byType(Image));
      final boxAfter = tester.getRect(find.byKey(_key(0, 2)));
      expect(imageAfter.width, greaterThan(imageBefore.width));
      expect(
        (boxAfter.left - imageAfter.left) / imageAfter.width,
        closeTo((boxBefore.left - imageBefore.left) / imageBefore.width, 0.001),
      );
      expect(
        boxAfter.width / imageAfter.width,
        closeTo(boxBefore.width / imageBefore.width, 0.001),
      );
    });

    testWidgets('shows progress while OCR runs', (tester) async {
      await pumpScreen(tester, ocrDelay: const Duration(seconds: 2));

      expect(find.text('Detecting Japanese text…'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, 0.5);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(WordBox), findsNothing);
      expect(find.text('Text'), findsNothing);
      expect(find.text('Retake'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Detecting Japanese text…'), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(WordBox), findsNWidgets(5));
      expect(find.text('Text'), findsOneWidget);
    });
  });

  group('errors and empty results', () {
    testWidgets('shows the hint when OCR is unavailable', (tester) async {
      await pumpScreen(
        tester,
        ocrError: const OcrUnavailableException(
          'Tesseract is not installed',
          hint: 'sudo apt install tesseract-ocr',
        ),
      );

      expect(find.text('Tesseract is not installed'), findsOneWidget);
      expect(find.text('sudo apt install tesseract-ocr'), findsOneWidget);
      expect(find.text('Detecting Japanese text…'), findsNothing);
      expect(find.byType(WordBox), findsNothing);
      expect(find.text('Text'), findsNothing);
    });

    testWidgets('shows an unavailable engine without a hint', (tester) async {
      await pumpScreen(
        tester,
        ocrError: const OcrUnavailableException('No OCR engine'),
      );

      expect(find.text('No OCR engine'), findsOneWidget);
    });

    testWidgets('shows other failures as "OCR failed"', (tester) async {
      await pumpScreen(tester, ocrError: Exception('boom'));

      expect(find.textContaining('OCR failed:'), findsOneWidget);
      expect(find.textContaining('boom'), findsOneWidget);
      expect(find.text('Detecting Japanese text…'), findsNothing);
      expect(find.byType(WordBox), findsNothing);
    });

    testWidgets('says so when no text was detected', (tester) async {
      await pumpScreen(tester, result: const OcrResult(lines: []));

      expect(find.text('No Japanese text detected.'), findsOneWidget);
      expect(find.byType(WordBox), findsNothing);
      expect(find.text('Text'), findsNothing);
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('looking up words', () {
    testWidgets('tapping a box looks up its word and shows the sheet', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(_key(0, 2)));
      await pumpSheet(tester);

      expect(lookup.calls, [(_lineA, 4)]);
      expect(find.byType(LookupSheet), findsOneWidget);
      expect(find.text('to read'), findsOneWidget);
      expect(
        find.text('Dictionary data: JMdict © EDRDG, CC BY-SA 4.0'),
        findsOneWidget,
      );
      expect(stateOf(tester, 0, 2), WordBoxState.selected);
      expect(stateOf(tester, 0, 0), WordBoxState.normal);
      expect(stateOf(tester, 1, 0), WordBoxState.normal);
    });

    testWidgets('shows a spinner in the sheet while the lookup is pending', (
      tester,
    ) async {
      await pumpScreen(tester, lookupDelay: const Duration(seconds: 1));

      await tester.tap(find.byKey(_key(0, 0)));
      await pumpSheet(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(stateOf(tester, 0, 0), WordBoxState.selected);

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Japanese (language)'), findsOneWidget);
    });

    testWidgets('a compound highlights every box it covers', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(_key(1, 0)));
      await pumpSheet(tester);

      expect(lookup.calls, [(_lineB, 0)]);
      expect(find.text('to eat'), findsOneWidget);
      expect(stateOf(tester, 1, 0), WordBoxState.selected);
      expect(stateOf(tester, 1, 1), WordBoxState.highlighted);
      expect(stateOf(tester, 0, 0), WordBoxState.normal);
      expect(stateOf(tester, 0, 1), WordBoxState.normal);
      expect(stateOf(tester, 0, 2), WordBoxState.normal);
    });

    testWidgets('a slow lookup cannot highlight over a newer one', (
      tester,
    ) async {
      await pumpScreen(tester, lookupDelay: const Duration(seconds: 1));

      // First lookup: the compound, still pending when its sheet is dismissed.
      await tester.tap(find.byKey(_key(1, 0)));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tapAt(const Offset(10, 10)); // the sheet's barrier
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LookupSheet), findsNothing);

      // Second lookup, elsewhere; the first one resolves while it is pending.
      await tester.tap(find.byKey(_key(0, 0)));
      await tester.pump(const Duration(milliseconds: 500));

      expect(stateOf(tester, 0, 0), WordBoxState.selected);
      expect(stateOf(tester, 1, 0), WordBoxState.normal);
      expect(stateOf(tester, 1, 1), WordBoxState.normal);

      // The newer lookup still lands.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      expect(stateOf(tester, 0, 0), WordBoxState.selected);
      expect(find.text('Japanese (language)'), findsOneWidget);
    });

    testWidgets('a failed lookup is reported in the sheet', (tester) async {
      await pumpScreen(tester, lookupError: StateError('dictionary missing'));

      await tester.tap(find.byKey(_key(0, 2)));
      await pumpSheet(tester);

      expect(find.textContaining('Lookup failed'), findsOneWidget);
      expect(find.textContaining('dictionary missing'), findsOneWidget);
      expect(stateOf(tester, 0, 2), WordBoxState.selected);
    });
  });

  group('full text panel', () {
    testWidgets('the Text button shows the lines with furigana', (
      tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byType(TokenizedText), findsNothing);

      await tester.tap(find.text('Text'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Detected text'), findsOneWidget);
      expect(find.byType(TokenizedText), findsNWidgets(2));
      // Readings above the kanji words, none above kana-only ones.
      expect(find.text('にほんご'), findsOneWidget);
      expect(find.text('よむ'), findsOneWidget);
      expect(find.text('たべ'), findsOneWidget);
      expect(find.text('ます'), findsOneWidget);
      expect(find.text('日本語'), findsOneWidget);
    });

    testWidgets('the Text button and the close button hide the panel', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Text'));
      await tester.pump();
      expect(find.byType(TokenizedText), findsNWidgets(2));

      await tester.tap(find.text('Text'));
      await tester.pump();
      expect(find.byType(TokenizedText), findsNothing);

      await tester.tap(find.text('Text'));
      await tester.pump();
      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      expect(find.byType(TokenizedText), findsNothing);
    });

    testWidgets(
      'tapping a word in the panel looks it up and highlights boxes',
      (tester) async {
        await pumpScreen(tester);
        await tester.tap(find.text('Text'));
        await tester.pump();
        await tester.pump();

        await tester.tap(find.text('読む'));
        await pumpSheet(tester);

        expect(lookup.calls, [(_lineA, 4)]);
        expect(find.text('to read'), findsOneWidget);
        // No box was tapped, so none is selected, but the match is marked.
        expect(stateOf(tester, 0, 2), WordBoxState.highlighted);
        expect(stateOf(tester, 0, 0), WordBoxState.normal);
      },
    );
  });

  testWidgets('Retake goes back', (tester) async {
    preprocessor = FakeImagePreprocessor();
    addTearDown(preprocessor.deleteFiles);
    await preloadImage(tester, preprocessor);
    await tester.pumpWidget(
      withServices(
        fakeServices(imagePreprocessor: preprocessor),
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ImageScreen(imagePath: '/photos/a.jpg'),
                ),
              ),
              child: const Text('start'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('start'));
    await tester.pumpAndSettle();
    expect(find.byType(ImageScreen), findsOneWidget);

    await tester.tap(find.text('Retake'));
    await tester.pumpAndSettle();

    expect(find.byType(ImageScreen), findsNothing);
    expect(find.text('start'), findsOneWidget);
  });
}
