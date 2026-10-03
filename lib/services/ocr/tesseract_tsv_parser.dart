import 'dart:convert';
import 'dart:ui';

import '../../models/ocr_result.dart';
import 'ocr_line_builder.dart';

/// Parses Tesseract's TSV output into an [OcrResult] with one [OcrWord] per
/// CJK character.
///
/// Words (level 5) are grouped into lines by (page, block, paragraph, line).
/// Blank words, malformed rows and lines without words are dropped, and a
/// negative confidence becomes null. Each character carries the confidence of
/// its Tesseract word.
///
/// The line boxes (level 4) are used to place the characters, not the word
/// boxes: for Japanese, Tesseract's word and character boxes overlap, collapse
/// and drift from the glyphs, while its line boxes hug the ink. Each line box
/// is divided among the line's characters in proportion to their advance width
/// (see [layOutAcross]), which matches the evenly spaced glyphs of Japanese
/// text. A line without a level 4 row falls back to the union of its word
/// boxes.
OcrResult parseTesseractTsv(String tsv) {
  final lineBoxes = <(int, int, int, int), Rect>{};
  final lineWords = <(int, int, int, int), List<RawOcrWord>>{};
  for (final row in const LineSplitter().convert(tsv)) {
    final columns = row.split('\t');
    if (columns.length < 12) continue;
    final level = columns[0];
    if (level != '4' && level != '5') continue;

    final ints = [for (final c in columns.sublist(1, 10)) int.tryParse(c)];
    final conf = double.tryParse(columns[10]);
    if (ints.contains(null) || conf == null) continue;

    final [page, block, par, line, _, left, top, width, height] = ints
        .cast<int>();
    final key = (page, block, par, line);
    final box = Rect.fromLTWH(
      left.toDouble(),
      top.toDouble(),
      width.toDouble(),
      height.toDouble(),
    );
    if (level == '4') {
      lineBoxes[key] = box;
      continue;
    }

    final text = columns[11].trim();
    if (text.isEmpty) continue;
    lineWords.putIfAbsent(key, () => []).add((
      text: text,
      bbox: box,
      confidence: conf < 0 ? null : conf / 100,
    ));
  }

  return OcrResult(
    lines: [
      for (final MapEntry(:key, value: words) in lineWords.entries)
        _buildLine(
          lineBoxes[key] ??
              words.map((w) => w.bbox).reduce((a, b) => a.expandToInclude(b)),
          words,
        ),
    ],
  );
}

/// Spreads [lineBox] over [words] and splits them into characters.
OcrLine _buildLine(Rect lineBox, List<RawOcrWord> words) {
  final boxes = layOutAcross(lineBox, [for (final w in words) w.text]);
  return joinOcrWords([
    for (var i = 0; i < words.length; i++)
      (text: words[i].text, bbox: boxes[i], confidence: words[i].confidence),
  ]);
}
