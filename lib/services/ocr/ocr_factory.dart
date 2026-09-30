import 'dart:io';

import 'mlkit_ocr_service.dart';
import 'ocr_service.dart';
import 'tesseract_ocr_service.dart';

/// Creates the OCR engine for the current platform: ML Kit on Android and
/// iOS, the Tesseract command-line tool on desktop.
///
/// Throws [UnsupportedError] on other platforms.
OcrService createOcrService() {
  if (Platform.isAndroid || Platform.isIOS) return MlKitOcrService();
  if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
    return TesseractOcrService();
  }
  throw UnsupportedError('No OCR engine for ${Platform.operatingSystem}');
}
