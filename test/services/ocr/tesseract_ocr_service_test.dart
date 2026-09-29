import 'dart:io';

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
