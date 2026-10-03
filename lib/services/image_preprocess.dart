import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'image_preprocessor.dart';

/// Longest side, in pixels, of a prepared image.
const _maxSide = 2000;
const _jpegQuality = 90;

/// Decodes, orients, downscales and re-encodes images off the UI isolate.
class DefaultImagePreprocessor implements ImagePreprocessor {
  /// Prepared images are written to [outputDir], which defaults to the
  /// temporary directory.
  DefaultImagePreprocessor({Future<Directory> Function()? outputDir})
    : _outputDir = outputDir ?? getTemporaryDirectory;

  final Future<Directory> Function() _outputDir;
  int _count = 0;

  /// Throws a [FormatException] if the file is not a decodable image.
  @override
  Future<PreparedImage> prepare(String sourcePath) async {
    final dir = await _outputDir();
    await dir.create(recursive: true);
    final name =
        'prepared_${DateTime.now().microsecondsSinceEpoch}_${_count++}';
    final outputPath = p.join(dir.path, '$name.jpg');

    final (width, height) = await Isolate.run(
      () => _prepareSync(sourcePath, outputPath),
    );
    return PreparedImage(path: outputPath, width: width, height: height);
  }
}

img.Image _decode(String path) {
  final bytes = File(path).readAsBytesSync();
  try {
    final image = img.decodeImage(bytes);
    if (image != null) return image;
  } catch (_) {
    // Truncated or corrupt data can fail with any decoder error; it is
    // reported as undecodable below.
  }
  throw FormatException('Cannot decode image: $path');
}

(int, int) _prepareSync(String sourcePath, String outputPath) {
  var image = img.bakeOrientation(_decode(sourcePath));
  if (image.width > _maxSide || image.height > _maxSide) {
    image = image.width >= image.height
        ? img.copyResize(
            image,
            width: _maxSide,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            image,
            height: _maxSide,
            interpolation: img.Interpolation.average,
          );
  }

  File(outputPath)
      .writeAsBytesSync(img.encodeJpg(image, quality: _jpegQuality));
  return (image.width, image.height);
}
