import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/services/ocr/mlkit_ocr_service.dart';

const _channel = MethodChannel('google_mlkit_text_recognizer');

Map<String, Object?> _rect(double l, double t, double r, double b) => {
  'left': l,
  'top': t,
  'right': r,
  'bottom': b,
};

Map<String, Object?> _element(
  String text,
  Map<String, Object?> rect, [
  double? confidence,
]) => {
  'text': text,
  'rect': rect,
  'recognizedLanguages': <String>[],
  'points': <Object>[],
  'confidence': confidence,
  'angle': null,
  'symbols': <Object>[],
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

  test('maps blocks, lines and elements to an OcrResult', () async {
    response = {
      'text': '',
      'blocks': [
        _block([
          _line([
            _element('日本語', _rect(10, 20, 110, 60), 0.9),
            _element('を', _rect(112, 22, 140, 58)),
            _element('勉強', _rect(142, 20, 220, 60), 0.75),
          ]),
        ]),
        _block([
          _line([
            _element('Tokyo', _rect(10, 100, 90, 140), 0.8),
            _element('Tower', _rect(100, 100, 180, 140), 0.8),
          ]),
          _line([_element(' ', _rect(0, 0, 1, 1))]),
        ]),
      ],
    };
    final service = MlKitOcrService();
    final progress = <(double, String)>[];

    final result = await service.recognize(
      '/tmp/photo.jpg',
      onProgress: (value, status) => progress.add((value, status)),
    );

    expect(result.lines.map((l) => l.text), ['日本語を勉強', 'Tokyo Tower']);
    final first = result.lines.first.words;
    expect(first.map((w) => (w.start, w.end)), [(0, 3), (3, 4), (4, 6)]);
    expect(first[0].bbox, const Rect.fromLTRB(10, 20, 110, 60));
    expect(first.map((w) => w.confidence), [0.9, null, 0.75]);
    expect(result.lines.last.words.map((w) => (w.start, w.end)), [
      (0, 5),
      (6, 11),
    ]);
    expect(progress, [(0.0, 'loading OCR engine'), (1.0, 'done')]);

    final request = calls.single.arguments as Map;
    expect(request['script'], 3); // TextRecognitionScript.japanese
    expect((request['imageData'] as Map)['path'], '/tmp/photo.jpg');
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
