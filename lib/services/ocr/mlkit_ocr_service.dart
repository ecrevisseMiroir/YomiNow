import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../models/ocr_result.dart';
import 'ocr_service.dart';
import 'tesseract_tsv_parser.dart' show joinOcrWords;

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
            for (final element in line.elements)
              (
                text: element.text,
                bbox: element.boundingBox,
                // Reported on Android only.
                confidence: element.confidence,
              ),
          ]),
    ].where((line) => line.words.isNotEmpty).toList();

    onProgress?.call(1, 'done');
    return OcrResult(lines: lines);
  }

  @override
  Future<void> dispose() => _recognizer.close();
}
