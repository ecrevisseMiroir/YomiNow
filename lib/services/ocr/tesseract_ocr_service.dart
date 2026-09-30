import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/ocr_result.dart';
import 'ocr_service.dart';
import 'tesseract_tsv_parser.dart';

/// Desktop OCR that runs the `tesseract` command-line tool with the Japanese
/// model bundled in `assets/tessdata`.
class TesseractOcrService implements OcrService {
  /// [executable] is the Tesseract binary (looked up on `PATH` by default).
  /// [tessdataDir] resolves the directory that holds `jpn.traineddata`; by
  /// default the bundled model is copied to the app support directory.
  TesseractOcrService({
    String executable = 'tesseract',
    Future<String> Function()? tessdataDir,
  }) : _executable = executable,
       _tessdataDir = tessdataDir ?? _installBundledTessdata;

  final String _executable;
  final Future<String> Function() _tessdataDir;
  String? _resolvedTessdataDir;

  @override
  Future<OcrResult> recognize(
    String imagePath, {
    OcrProgress? onProgress,
  }) async {
    onProgress?.call(0, 'loading OCR engine');
    final tessdata = _resolvedTessdataDir ??= await _tessdataDir();

    final ProcessResult result;
    try {
      // The `tsv` config only exists in Tesseract's own tessdata directory,
      // so the format is requested through the variable it sets.
      result = await Process.run(
        _executable,
        [
          imagePath,
          'stdout',
          '--tessdata-dir',
          tessdata,
          '-l',
          'jpn',
          '--psm',
          '3',
          '-c',
          'tessedit_create_tsv=1',
        ],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );
    } on ProcessException {
      throw OcrUnavailableException(
        'Tesseract is not installed',
        hint: _installHint(),
      );
    }
    if (result.exitCode != 0) {
      throw Exception(
        'Tesseract failed with exit code ${result.exitCode}: ${result.stderr}',
      );
    }

    final ocr = parseTesseractTsv(result.stdout as String);
    onProgress?.call(1, 'done');
    return ocr;
  }

  @override
  Future<void> dispose() async {}
}

String _installHint() {
  if (Platform.isLinux) {
    return 'Install it with: sudo apt install tesseract-ocr';
  }
  if (Platform.isMacOS) {
    return 'Install it with: brew install tesseract';
  }
  if (Platform.isWindows) {
    return 'Install Tesseract with the UB Mannheim installer '
        '(https://github.com/UB-Mannheim/tesseract/wiki) and add it to PATH';
  }
  return 'Install Tesseract and make sure it is on your PATH';
}

/// Copies the bundled `jpn.traineddata` to the app support directory unless
/// an identically sized copy is already there, and returns its directory.
Future<String> _installBundledTessdata() async {
  const asset = 'assets/tessdata/jpn.traineddata';
  final support = await getApplicationSupportDirectory();
  final dir = Directory(p.join(support.path, 'tessdata'));
  final file = File(p.join(dir.path, 'jpn.traineddata'));

  final data = await rootBundle.load(asset);
  if (!await file.exists() || await file.length() != data.lengthInBytes) {
    await dir.create(recursive: true);
    await file.writeAsBytes(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      flush: true,
    );
  }
  return dir.path;
}
