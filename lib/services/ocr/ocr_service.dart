import '../../models/ocr_result.dart';

/// Reports OCR progress in 0..1 with a short status label.
typedef OcrProgress = void Function(double progress, String status);

/// Japanese text recognition. Implementations: Tesseract CLI on desktop,
/// Google ML Kit on Android/iOS. Obtain one via `createOcrService()` in
/// `ocr_factory.dart`.
abstract class OcrService {
  /// Recognizes Japanese text in the image at [imagePath]. Bounding boxes are
  /// in that image's pixel coordinates.
  Future<OcrResult> recognize(String imagePath, {OcrProgress? onProgress});

  Future<void> dispose();
}

/// Thrown when the OCR engine is missing or cannot start (e.g. `tesseract`
/// is not installed). [hint] tells the user how to fix it.
class OcrUnavailableException implements Exception {
  const OcrUnavailableException(this.message, {this.hint});

  final String message;
  final String? hint;

  @override
  String toString() => hint == null
      ? 'OcrUnavailableException: $message'
      : 'OcrUnavailableException: $message ($hint)';
}
