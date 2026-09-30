import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:yominow/models/ja_token.dart';
import 'package:yominow/models/lookup_result.dart';
import 'package:yominow/models/ocr_result.dart';
import 'package:yominow/services/app_services.dart';
import 'package:yominow/services/image_preprocessor.dart';
import 'package:yominow/services/lookup_service.dart';
import 'package:yominow/services/ocr/ocr_service.dart';
import 'package:yominow/services/tokenizer_service.dart';

/// An [OcrService] that returns a canned result, or throws a canned error,
/// after an optional delay.
class FakeOcrService implements OcrService {
  FakeOcrService({
    this.result = const OcrResult(lines: []),
    this.error,
    this.delay = Duration.zero,
  });

  final OcrResult result;

  /// Thrown instead of returning [result] when set.
  final Object? error;

  /// How long [recognize] takes, after reporting 50% progress.
  final Duration delay;

  /// The image paths passed to [recognize], in call order.
  final recognized = <String>[];

  @override
  Future<OcrResult> recognize(
    String imagePath, {
    OcrProgress? onProgress,
  }) async {
    recognized.add(imagePath);
    onProgress?.call(0.5, 'Recognizing');
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error case final error?) throw error;
    onProgress?.call(1, 'Done');
    return result;
  }

  @override
  Future<void> dispose() async {}
}

/// An [ImagePreprocessor] that ignores the source and returns a small, real
/// PNG written to a temp directory. Call [deleteFiles] when done.
class FakeImagePreprocessor implements ImagePreprocessor {
  FakeImagePreprocessor({this.width = 200, this.height = 100});

  final int width;
  final int height;

  /// The source paths passed to [prepare], in call order.
  final prepared = <String>[];

  Directory? _dir;
  PreparedImage? _image;

  /// The generated image, written on first use. The write is synchronous, so
  /// it completes under the widget tester's fake clock.
  PreparedImage get image => _image ??= _writePng();

  PreparedImage _writePng() {
    final dir = _dir ??= Directory.systemTemp.createTempSync('yominow_test_');
    final file = File(p.join(dir.path, 'prepared.png'))
      ..writeAsBytesSync(
        img.encodePng(
          img.fill(
            img.Image(width: width, height: height),
            color: img.ColorRgb8(90, 90, 90),
          ),
        ),
      );
    return PreparedImage(path: file.path, width: width, height: height);
  }

  @override
  Future<PreparedImage> prepare(String sourcePath) async {
    prepared.add(sourcePath);
    return image;
  }

  /// Removes the temp directory holding the generated PNG.
  void deleteFiles() {
    _dir?.deleteSync(recursive: true);
    _dir = null;
    _image = null;
  }
}

/// A [TokenizerService] that returns fixed tokens for known texts and one
/// token per character otherwise (`。`, `、` and spaces are not words).
class FakeTokenizerService implements TokenizerService {
  FakeTokenizerService({this.tokens = const {}, this.delay = Duration.zero});

  /// Tokens to return for exact texts.
  final Map<String, List<JaToken>> tokens;
  final Duration delay;

  /// The texts passed to [tokenize], in call order.
  final tokenized = <String>[];

  @override
  Future<void> init() async {}

  @override
  Future<List<JaToken>> tokenize(String text) async {
    tokenized.add(text);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    return tokens[text] ??
        [
          for (var i = 0; i < text.length; i++)
            JaToken(
              surface: text[i],
              basicForm: text[i],
              pos: '。、 '.contains(text[i]) ? '記号' : '名詞',
              start: i,
              end: i + 1,
            ),
        ];
  }
}

/// A [LookupService] answering from a map keyed by (text, offset); unknown
/// positions look up as null.
class FakeLookupService implements LookupService {
  FakeLookupService({
    this.results = const {},
    this.error,
    this.delay = Duration.zero,
  });

  final Map<(String, int), LookupResult?> results;

  /// Thrown instead of answering when set.
  final Object? error;
  final Duration delay;

  /// The (text, offset) pairs passed to [lookupAt], in call order.
  final calls = <(String, int)>[];

  @override
  Future<LookupResult?> lookupAt(String text, int offset) async {
    calls.add((text, offset));
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (error case final error?) throw error;
    return results[(text, offset)];
  }
}

/// [AppServices] made of fakes; pass the ones a test wants to inspect.
AppServices fakeServices({
  OcrService? ocr,
  ImagePreprocessor? imagePreprocessor,
  TokenizerService? tokenizer,
  LookupService? lookup,
}) {
  return AppServices(
    ocr: ocr ?? FakeOcrService(),
    imagePreprocessor: imagePreprocessor ?? FakeImagePreprocessor(),
    tokenizer: tokenizer ?? FakeTokenizerService(),
    lookup: lookup ?? FakeLookupService(),
  );
}

/// Wraps [child] in the app's service scope and a dark [MaterialApp], like
/// the real app does.
Widget withServices(AppServices services, Widget child) {
  return AppServicesScope(
    services: services,
    child: MaterialApp(theme: ThemeData.dark(), home: child),
  );
}

/// Decodes [FakeImagePreprocessor.image] up front so that an `Image.file`
/// built later finds it in the image cache and paints synchronously.
///
/// The tester's fake clock does not run real file IO, so an image first
/// requested from a widget would never finish loading. Call this before
/// pumping the widget under test.
Future<void> preloadImage(
  WidgetTester tester,
  FakeImagePreprocessor preprocessor,
) async {
  final provider = FileImage(File(preprocessor.image.path));
  await tester.runAsync(() {
    final decoded = Completer<void>();
    provider
        .resolve(ImageConfiguration.empty)
        .addListener(
          ImageStreamListener(
            (_, _) => decoded.complete(),
            onError: decoded.completeError,
          ),
        );
    return decoded.future;
  });
}
