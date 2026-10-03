import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/ocr_result.dart';
import 'package:yominow/services/ocr/mlkit_ocr_service.dart';
import 'package:yominow/services/ocr/ocr_service.dart';

const _channel = MethodChannel('google_mlkit_text_recognizer');

Map<String, Object?> _rect(double l, double t, double r, double b) => {
  'left': l,
  'top': t,
  'right': r,
  'bottom': b,
};

Map<String, Object?> _symbol(String text, Map<String, Object?> rect) => {
  'text': text,
  'rect': rect,
  'recognizedLanguages': <String>[],
  'points': <Object>[],
  'confidence': null,
  'angle': null,
};

/// An element as ML Kit reports it: with [symbols] on Android, without on iOS.
Map<String, Object?> _element(
  String text,
  Map<String, Object?> rect, {
  double? confidence,
  List<Map<String, Object?>> symbols = const [],
}) => {
  'text': text,
  'rect': rect,
  'recognizedLanguages': <String>[],
  'points': <Object>[],
  'confidence': confidence,
  'angle': null,
  'symbols': symbols,
};

Map<String, Object?> _line(List<Map<String, Object?>> elements) => {
  'text': elements.map((e) => e['text']).join(),
  'rect': _rect(0, 0, 0, 0),
  'recognizedLanguages': <String>[],
  'points': <Object>[],
  'confidence': null,
  'angle': null,
  'elements': elements,
};

Map<String, Object?> _block(List<Map<String, Object?>> lines) => {
  'text': '',
  'rect': _rect(0, 0, 0, 0),
  'recognizedLanguages': <String>[],
  'points': <Object>[],
  'lines': lines,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final calls = <MethodCall>[];
  late Map<String, Object?> response;

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          calls.add(call);
          return call.method == 'vision#startTextRecognizer' ? response : null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  });

  Future<OcrResult> recognize(
    List<Map<String, Object?>> lines, {
    OcrProgress? onProgress,
  }) {
    response = {
      'text': '',
      'blocks': [_block(lines)],
    };
    return MlKitOcrService().recognize(
      '/tmp/photo.jpg',
      onProgress: onProgress,
    );
  }

  test('maps lines and elements, reporting progress', () async {
    final progress = <(double, String)>[];

    final result = await recognize([
      _line([
        _element('Tokyo', _rect(10, 100, 90, 140), confidence: 0.8),
        _element('Tower', _rect(100, 100, 180, 140), confidence: 0.6),
      ]),
      _line([_element(' ', _rect(0, 0, 1, 1))]),
    ], onProgress: (value, status) => progress.add((value, status)));

    expect(result.lines.map((l) => l.text), ['Tokyo Tower']);
    final words = result.lines.single.words;
    expect(words.map((w) => (w.start, w.end)), [(0, 5), (6, 11)]);
    expect(words.map((w) => w.bbox), const [
      Rect.fromLTRB(10, 100, 90, 140),
      Rect.fromLTRB(100, 100, 180, 140),
    ]);
    expect(words.map((w) => w.confidence), [0.8, 0.6]);
    expect(progress, [(0.0, 'loading OCR engine'), (1.0, 'done')]);

    final request = calls.single.arguments as Map;
    expect(request['script'], 3); // TextRecognitionScript.japanese
    expect((request['imageData'] as Map)['path'], '/tmp/photo.jpg');
  });

  test('uses the symbol boxes where ML Kit reports symbols', () async {
    final result = await recognize([
      _line([
        _element(
          '日本語',
          _rect(10, 20, 110, 60),
          confidence: 0.9,
          symbols: [
            _symbol('日', _rect(12, 22, 40, 58)),
            _symbol('本', _rect(46, 21, 74, 59)),
            _symbol('語', _rect(80, 20, 108, 60)),
          ],
        ),
      ]),
    ]);

    final words = result.lines.single.words;
    expect(result.lines.single.text, '日本語');
    expect(words.map((w) => w.text), ['日', '本', '語']);
    expect(words.map((w) => w.bbox), const [
      Rect.fromLTRB(12, 22, 40, 58),
      Rect.fromLTRB(46, 21, 74, 59),
      Rect.fromLTRB(80, 20, 108, 60),
    ]);
    expect(words.map((w) => w.confidence), [0.9, 0.9, 0.9]);
  });

  test('keeps a run of non-CJK symbols as one word', () async {
    final result = await recognize([
      _line([
        _element(
          'Tokyo年',
          _rect(0, 0, 100, 20),
          symbols: [
            _symbol('T', _rect(0, 0, 10, 20)),
            _symbol('o', _rect(10, 4, 20, 20)),
            _symbol('k', _rect(20, 0, 30, 20)),
            _symbol('y', _rect(30, 4, 40, 24)),
            _symbol('o', _rect(40, 4, 50, 20)),
            _symbol('年', _rect(55, 0, 95, 20)),
          ],
        ),
      ]),
    ]);

    final words = result.lines.single.words;
    expect(result.lines.single.text, 'Tokyo年');
    expect(words.map((w) => w.text), ['Tokyo', '年']);
    expect(words[0].bbox, const Rect.fromLTRB(0, 0, 50, 24));
    expect(words[1].bbox, const Rect.fromLTRB(55, 0, 95, 20));
  });

  test('divides the element box among characters without symbols', () async {
    final result = await recognize([
      _line([
        _element('勉強', _rect(142, 20, 222, 60), confidence: 0.75),
        _element('Tokyo', _rect(230, 20, 280, 60)),
      ]),
    ]);

    final line = result.lines.single;
    expect(line.text, '勉強Tokyo');
    expect(line.words.map((w) => w.text), ['勉', '強', 'Tokyo']);
    expect(line.words.map((w) => w.bbox), const [
      Rect.fromLTRB(142, 20, 182, 60),
      Rect.fromLTRB(182, 20, 222, 60),
      Rect.fromLTRB(230, 20, 280, 60),
    ]);
    expect(line.words.map((w) => w.confidence), [0.75, 0.75, null]);
  });

  test('ignores symbols that do not add up to the element text', () async {
    final result = await recognize([
      _line([
        _element(
          '日本',
          _rect(0, 0, 100, 40),
          symbols: [_symbol('日', _rect(0, 0, 10, 40))],
        ),
      ]),
    ]);

    expect(result.lines.single.words.map((w) => w.bbox), const [
      Rect.fromLTRB(0, 0, 50, 40),
      Rect.fromLTRB(50, 0, 100, 40),
    ]);
  });

  test('returns an empty result when nothing is recognized', () async {
    response = {'text': '', 'blocks': <Object>[]};

    final result = await MlKitOcrService().recognize('/tmp/blank.jpg');

    expect(result.isEmpty, isTrue);
  });

  test('dispose closes the recognizer', () async {
    await MlKitOcrService().dispose();

    expect(calls.single.method, 'vision#closeTextRecognizer');
  });
}
