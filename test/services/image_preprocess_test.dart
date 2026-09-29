import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:yominow/services/image_preprocess.dart';

void main() {
  late Directory temp;
  late DefaultImagePreprocessor preprocessor;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('image_preprocess_test_');
    preprocessor = DefaultImagePreprocessor(
      outputDir: () async => Directory(p.join(temp.path, 'out')),
    );
  });

  tearDown(() => temp.delete(recursive: true));

  /// Writes a white image of the given size to [name] in the temp dir, with a
  /// red 10x10 square in its top-left corner.
  Future<String> writeImage(
    String name,
    int width,
    int height, {
    int? exifOrientation,
  }) async {
    final image = img.Image(width: width, height: height)
      ..clear(img.ColorRgb8(255, 255, 255));
    img.fillRect(
      image,
      x1: 0,
      y1: 0,
      x2: 9,
      y2: 9,
      color: img.ColorRgb8(255, 0, 0),
    );
    if (exifOrientation != null) {
      image.exif.imageIfd.orientation = exifOrientation;
    }
    final path = p.join(temp.path, name);
    await File(path).writeAsBytes(img.encodeJpg(image));
    return path;
  }

  img.Image decode(String path) => img.decodeJpg(File(path).readAsBytesSync())!;

  bool isRed(img.Pixel pixel) => pixel.r > 200 && pixel.g < 80;

  test('applies the EXIF orientation', () async {
    final source = await writeImage('rotated.jpg', 40, 20, exifOrientation: 6);

    final prepared = await preprocessor.prepare(source);

    expect((prepared.width, prepared.height), (20, 40));
    final output = decode(prepared.path);
    expect((output.width, output.height), (20, 40));
    expect(output.exif.imageIfd.hasOrientation, isFalse);
    // Orientation 6 turns the image 90 degrees clockwise, which moves the
    // top-left marker to the top-right corner.
    expect(isRed(output.getPixel(15, 4)), isTrue);
    expect(isRed(output.getPixel(4, 4)), isFalse);
  });

  test('downscales a wide image so the longest side is 2000 px', () async {
    final prepared = await preprocessor.prepare(
      await writeImage('wide.jpg', 4000, 1000),
    );

    expect((prepared.width, prepared.height), (2000, 500));
    final output = decode(prepared.path);
    expect((output.width, output.height), (2000, 500));
  });

  test('downscales a tall image so the longest side is 2000 px', () async {
    final prepared = await preprocessor.prepare(
      await writeImage('tall.jpg', 1500, 3000),
    );

    expect((prepared.width, prepared.height), (1000, 2000));
  });

  test('keeps the size of an image that is small enough', () async {
    final prepared = await preprocessor.prepare(
      await writeImage('small.jpg', 640, 480),
    );

    expect((prepared.width, prepared.height), (640, 480));
  });

  test('writes a distinct file for every call', () async {
    final source = await writeImage('a.jpg', 40, 20);

    final first = await preprocessor.prepare(source);
    final second = await preprocessor.prepare(source);

    expect(first.path, isNot(second.path));
    expect(File(first.path).existsSync(), isTrue);
    expect(File(second.path).existsSync(), isTrue);
  });

  group('throws a FormatException for', () {
    test('a file that is not an image', () async {
      final path = p.join(temp.path, 'notes.txt');
      await File(path).writeAsString('this is not an image');

      expect(preprocessor.prepare(path), throwsFormatException);
    });

    test('a truncated image', () async {
      final path = p.join(temp.path, 'truncated.png');
      final png = img.encodePng(img.Image(width: 20, height: 20));
      await File(path).writeAsBytes(png.sublist(0, 20));

      expect(preprocessor.prepare(path), throwsFormatException);
    });
  });
}
