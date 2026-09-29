import 'dart:ui' show Rect;

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../models/ocr_result.dart';
import 'ocr_line_builder.dart';
import 'ocr_service.dart';

/// Mobile OCR backed by Google ML Kit's on-device Japanese recognizer.
class MlKitOcrService implements OcrService {
  final _recognizer = TextRecognizer(script: TextRecognitionScript.japanese);

  @override
  Future<OcrResult> recognize(
    String imagePath, {
    OcrProgress? onProgress,
  }) async {
    onProgress?.call(0, 'loading OCR engine');
    final recognized = await _recognizer.processImage(
      InputImage.fromFilePath(imagePath),
    );

    final lines = [
      for (final block in recognized.blocks)
        for (final line in block.lines)
          joinOcrWords([
            for (final element in line.elements) ..._rawWords(element),
          ]),
    ].where((line) => line.words.isNotEmpty).toList();

    onProgress?.call(1, 'done');
    return OcrResult(lines: lines);
  }

  @override
  Future<void> dispose() => _recognizer.close();
}

/// Splits [element] at symbol level where ML Kit reports symbols (Android): a
/// CJK symbol keeps its own box and a run of other symbols becomes one word.
///
/// Where it does not (iOS), the element is returned whole and [joinOcrWords]
/// divides its box among the characters. Every piece keeps the confidence of
/// the element, as ML Kit reports it on Android only.
List<RawOcrWord> _rawWords(TextElement element) {
  final symbols = element.symbols;
  if (symbols.isEmpty || symbols.map((s) => s.text).join() != element.text) {
    return [
      (
        text: element.text,
        bbox: element.boundingBox,
        confidence: element.confidence,
      ),
    ];
  }

  RawOcrWord word(String text, Rect box) =>
      (text: text, bbox: box, confidence: element.confidence);

  final words = <RawOcrWord>[];
  for (final symbol in symbols.where((s) => s.text.isNotEmpty)) {
    final previous = words.lastOrNull;
    if (previous != null &&
        !isCjk(previous.text.runes.last) &&
        !isCjk(symbol.text.runes.first)) {
      words[words.length - 1] = word(
        previous.text + symbol.text,
        previous.bbox.expandToInclude(symbol.boundingBox),
      );
    } else {
      words.add(word(symbol.text, symbol.boundingBox));
    }
  }
  return words;
}
