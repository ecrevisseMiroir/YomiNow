import 'dart:ui';

/// A single recognized word (or character run) with its position in the
/// source image and its character range within the parent [OcrLine.text].
class OcrWord {
  const OcrWord({
    required this.text,
    required this.bbox,
    required this.start,
    required this.end,
    this.confidence,
  });

  final String text;

  /// Bounding box in source-image pixel coordinates.
  final Rect bbox;

  /// Confidence in 0..1, or null when the OCR engine does not report one.
  final double? confidence;

  /// Character range of this word inside the parent line's text: [start, end).
  final int start;
  final int end;
}

/// A line of text; [text] is the words joined (without spaces for CJK).
class OcrLine {
  const OcrLine({required this.text, required this.words});

  final String text;
  final List<OcrWord> words;
}

class OcrResult {
  const OcrResult({required this.lines});

  final List<OcrLine> lines;

  /// Full text, one line per [OcrLine].
  String get text => lines.map((l) => l.text).join('\n');

  bool get isEmpty => lines.every((l) => l.words.isEmpty);
}
