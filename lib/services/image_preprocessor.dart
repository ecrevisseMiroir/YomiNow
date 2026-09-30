/// An image normalized for OCR and display: EXIF orientation applied,
/// downscaled, re-encoded as JPEG. OCR boxes and the displayed image share
/// this pixel space.
class PreparedImage {
  const PreparedImage({
    required this.path,
    required this.width,
    required this.height,
  });

  final String path;
  final int width;
  final int height;
}

abstract class ImagePreprocessor {
  /// Normalizes the image at [sourcePath] and returns the prepared copy.
  Future<PreparedImage> prepare(String sourcePath);
}
