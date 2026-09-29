import 'dart:convert';
import 'dart:ui';

import '../../models/ocr_result.dart';

/// A recognized word before its position in the line text is known.
typedef RawOcrWord = ({String text, Rect bbox, double? confidence});

/// Parses Tesseract's TSV output into an [OcrResult].
///
/// Only word rows (level 5) are used; they are grouped into lines by
/// (page, block, paragraph, line). Blank words, malformed rows and lines
/// without words are dropped. A negative confidence becomes null.
OcrResult parseTesseractTsv(String tsv) {
  final groups = <(int, int, int, int), List<RawOcrWord>>{};
  for (final row in const LineSplitter().convert(tsv)) {
    final columns = row.split('\t');
    if (columns.length < 12 || columns[0] != '5') continue;

    final ints = [for (final c in columns.sublist(1, 10)) int.tryParse(c)];
    final conf = double.tryParse(columns[10]);
    if (ints.contains(null) || conf == null) continue;

    final [page, block, par, line, _, left, top, width, height] = ints
        .cast<int>();
    groups.putIfAbsent((page, block, par, line), () => []).add((
      text: columns[11],
      bbox: Rect.fromLTWH(
        left.toDouble(),
        top.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      confidence: conf < 0 ? null : conf / 100,
    ));
  }

  return OcrResult(
    lines: [
      for (final words in groups.values) joinOcrWords(words),
    ].where((line) => line.words.isNotEmpty).toList(),
  );
}

/// Builds a line from [words] in reading order.
///
/// Words that are blank after trimming are skipped. Words are joined without
/// a separator when either neighbouring character is CJK (kanji, kana or
/// fullwidth), and with a single space otherwise, so Japanese text stays
/// contiguous while Latin words stay separated. Each [OcrWord] records its
/// range in the returned [OcrLine.text].
OcrLine joinOcrWords(Iterable<RawOcrWord> words) {
  final text = StringBuffer();
  final result = <OcrWord>[];
  String? previous;
  for (final word in words) {
    final wordText = word.text.trim();
    if (wordText.isEmpty) continue;

    if (previous != null &&
        !_isCjk(previous.runes.last) &&
        !_isCjk(wordText.runes.first)) {
      text.write(' ');
    }
    final start = text.length;
    text.write(wordText);
    result.add(
      OcrWord(
        text: wordText,
        bbox: word.bbox,
        confidence: word.confidence,
        start: start,
        end: text.length,
      ),
    );
    previous = wordText;
  }
  return OcrLine(text: text.toString(), words: result);
}

/// Whether [rune] is kanji, kana, CJK punctuation or a fullwidth/halfwidth
/// form.
bool _isCjk(int rune) =>
    (rune >= 0x3000 && rune <= 0x30FF) || // CJK symbols, hiragana, katakana
    (rune >= 0x31F0 && rune <= 0x31FF) || // katakana phonetic extensions
    (rune >= 0x3400 && rune <= 0x4DBF) || // CJK extension A
    (rune >= 0x4E00 && rune <= 0x9FFF) || // CJK unified ideographs
    (rune >= 0xF900 && rune <= 0xFAFF) || // CJK compatibility ideographs
    (rune >= 0xFF00 && rune <= 0xFFEF) || // fullwidth and halfwidth forms
    (rune >= 0x20000 && rune <= 0x3134F); // CJK extensions B and later
