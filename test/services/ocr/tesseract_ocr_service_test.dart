import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:yominow/services/ocr/ocr_service.dart';
import 'package:yominow/services/ocr/tesseract_ocr_service.dart';

bool get _hasTesseract {
  try {
    return Process.runSync('tesseract', ['--version']).exitCode == 0;
  } on ProcessException {
    return false;
  }
}

/// Intersection over union of two boxes.
double _iou(Rect a, Rect b) {
  final overlap = a.intersect(b);
  if (overlap.width <= 0 || overlap.height <= 0) return 0;
  final intersection = overlap.width * overlap.height;
  return intersection /
      (a.width * a.height + b.width * b.height - intersection);
}

void main() {
  final tessdata = p.absolute('assets', 'tessdata');
  final sample = p.absolute('test', 'fixtures', 'ja_sample.png');

  test('recognizes Japanese text in the sample image', () async {
    final service = TesseractOcrService(tessdataDir: () async => tessdata);
    final progress = <(double, String)>[];

    final result = await service.recognize(
      sample,
      onProgress: (value, status) => progress.add((value, status)),
    );
    await service.dispose();

    expect(result.lines, isNotEmpty);
    expect(result.text, anyOf(contains('日本語'), contains('東京')));
    for (final line in result.lines) {
      for (final word in line.words) {
        expect(line.text.substring(word.start, word.end), word.text);
        expect(word.bbox.right, lessThanOrEqualTo(900));
        expect(word.bbox.bottom, lessThanOrEqualTo(260));
      }
    }
    expect(progress, [(0.0, 'loading OCR engine'), (1.0, 'done')]);
  }, skip: _hasTesseract ? false : 'tesseract is not installed');

  test(
    'gives every character of a line its own box, in reading order',
    () async {
      final service = TesseractOcrService(tessdataDir: () async => tessdata);

      final result = await service.recognize(sample);

      for (final text in ['日本語を勉強しています', '東京に行きました']) {
        final line = result.lines.firstWhere(
          (l) => l.text == text,
          orElse: () => fail('"$text" not found in "${result.text}"'),
        );
        final characters = [...text.runes.map(String.fromCharCode)];
        expect(line.words.map((w) => w.text), characters);

        final boxes = [for (final word in line.words) word.bbox];
        for (var i = 1; i < boxes.length; i++) {
          expect(boxes[i].left, greaterThan(boxes[i - 1].left));
          expect(_iou(boxes[i - 1], boxes[i]), lessThan(0.2));
        }
        // The sample is set in 64 px type starting at x = 40, so character i
        // is centered near 72 + 64 * i.
        for (var i = 0; i < boxes.length; i++) {
          expect(boxes[i].center.dx, closeTo(72 + 64 * i, 16));
        }
      }
    },
    skip: _hasTesseract ? false : 'tesseract is not installed',
  );

  test('reports a missing binary as OcrUnavailableException', () {
    final service = TesseractOcrService(
      executable: 'yominow-no-such-tesseract',
      tessdataDir: () async => tessdata,
    );

    expect(
      service.recognize(sample),
      throwsA(
        isA<OcrUnavailableException>()
            .having((e) => e.message, 'message', 'Tesseract is not installed')
            .having((e) => e.hint, 'hint', isNotEmpty),
      ),
    );
  });

  test('includes stderr when Tesseract fails', () {
    final service = TesseractOcrService(tessdataDir: () async => tessdata);

    expect(
      service.recognize(p.absolute('test', 'fixtures', 'missing.png')),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          allOf(contains('exit code 1'), contains('cannot read input file')),
        ),
      ),
    );
  }, skip: _hasTesseract ? false : 'tesseract is not installed');
}
