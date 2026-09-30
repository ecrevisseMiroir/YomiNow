import 'dart:ui';

import '../../models/ocr_result.dart';

/// A recognized run of text with its box and confidence, before it is split
/// into per-character [OcrWord]s.
typedef RawOcrWord = ({String text, Rect bbox, double? confidence});

/// Builds a line from [words] in reading order.
///
/// Every CJK character becomes its own [OcrWord]; a run of other characters
/// (Latin letters, digits) stays one. The box of a raw word is divided among
/// its pieces in proportion to their advance width, so the pieces get
/// contiguous boxes that do not overlap, and each piece keeps the confidence
/// of the raw word.
///
/// Raw words that are blank after trimming are skipped. Raw words are joined
/// without a separator when either neighbouring character is CJK, and with a
/// single space otherwise, so Japanese text stays contiguous while Latin words
/// stay separated. Each [OcrWord] records its range in the returned
/// [OcrLine.text].
OcrLine joinOcrWords(Iterable<RawOcrWord> words) {
  final text = StringBuffer();
  final result = <OcrWord>[];
  String? previous;
  for (final word in words) {
    final wordText = word.text.trim();
    if (wordText.isEmpty) continue;

    if (previous != null &&
        !isCjk(previous.runes.last) &&
        !isCjk(wordText.runes.first)) {
      text.write(' ');
    }
    final pieces = _split(wordText);
    final boxes = layOutAcross(word.bbox, pieces);
    for (var i = 0; i < pieces.length; i++) {
      final start = text.length;
      text.write(pieces[i]);
      result.add(
        OcrWord(
          text: pieces[i],
          bbox: boxes[i],
          confidence: word.confidence,
          start: start,
          end: text.length,
        ),
      );
    }
    previous = wordText;
  }
  return OcrLine(text: text.toString(), words: result);
}

/// Divides [box] horizontally among [texts], left to right, giving each a
/// share in proportion to its advance width: a CJK character is a full em and
/// any other character half an em. Every returned box has the height of
/// [box]; neighbours touch but do not overlap.
List<Rect> layOutAcross(Rect box, List<String> texts) {
  final advances = [for (final text in texts) _advance(text)];
  final total = advances.fold(0.0, (sum, advance) => sum + advance);
  final boxes = <Rect>[];
  var covered = 0.0;
  var left = box.left;
  for (final advance in advances) {
    covered += advance;
    final right = box.left + box.width * covered / total;
    boxes.add(Rect.fromLTRB(left, box.top, right, box.bottom));
    left = right;
  }
  return boxes;
}

/// Whether [rune] is kanji, kana, CJK punctuation or a fullwidth/halfwidth
/// form.
bool isCjk(int rune) =>
    (rune >= 0x3000 && rune <= 0x30FF) || // CJK symbols, hiragana, katakana
    (rune >= 0x31F0 && rune <= 0x31FF) || // katakana phonetic extensions
    (rune >= 0x3400 && rune <= 0x4DBF) || // CJK extension A
    (rune >= 0x4E00 && rune <= 0x9FFF) || // CJK unified ideographs
    (rune >= 0xF900 && rune <= 0xFAFF) || // CJK compatibility ideographs
    (rune >= 0xFF00 && rune <= 0xFFEF) || // fullwidth and halfwidth forms
    (rune >= 0x20000 && rune <= 0x3134F); // CJK extensions B and later

/// Splits [text] into single CJK characters and runs of other characters.
List<String> _split(String text) {
  final pieces = <String>[];
  final run = StringBuffer();
  for (final rune in text.runes) {
    if (isCjk(rune)) {
      if (run.isNotEmpty) {
        pieces.add(run.toString());
        run.clear();
      }
      pieces.add(String.fromCharCode(rune));
    } else {
      run.writeCharCode(rune);
    }
  }
  if (run.isNotEmpty) pieces.add(run.toString());
  return pieces;
}

double _advance(String text) =>
    text.runes.fold(0.0, (sum, rune) => sum + (isCjk(rune) ? 1.0 : 0.5));
