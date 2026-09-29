import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/ocr_result.dart';
import 'package:yominow/services/ocr/tesseract_tsv_parser.dart';

/// Shaped like real `tesseract ... tsv` output: header, page/block/paragraph/
/// line rows (levels 1-4), then words (level 5). It has two Japanese lines,
/// an empty word, an unscored word (conf -1), a Latin/Japanese line in a second
/// block that reuses line number 1, and a line that only holds a blank word.
const _tsv =
    'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\tleft\ttop\twidth\theight\tconf\ttext\n'
    '1\t1\t0\t0\t0\t0\t0\t0\t900\t420\t-1\t\n'
    '2\t1\t1\t0\t0\t0\t43\t51\t694\t180\t-1\t\n'
    '3\t1\t1\t1\t0\t0\t43\t51\t694\t180\t-1\t\n'
    '4\t1\t1\t1\t1\t0\t51\t51\t686\t60\t-1\t\n'
    '5\t1\t1\t1\t1\t1\t51\t51\t190\t60\t96.518021\t日本語\n'
    '5\t1\t1\t1\t1\t2\t250\t55\t50\t54\t93.266273\tを\n'
    '5\t1\t1\t1\t1\t3\t310\t51\t120\t60\t50.932121\t勉強\n'
    '5\t1\t1\t1\t1\t4\t440\t60\t0\t0\t0\t\n'
    '5\t1\t1\t1\t1\t5\t445\t55\t100\t54\t96.563751\tして\n'
    '5\t1\t1\t1\t1\t6\t560\t54\t170\t55\t92.782715\tいます\n'
    '4\t1\t1\t1\t2\t0\t43\t171\t503\t60\t-1\t\n'
    '5\t1\t1\t1\t2\t1\t43\t171\t190\t60\t96.737671\t東京\n'
    '5\t1\t1\t1\t2\t2\t240\t166\t69\t91\t96.955948\tに\n'
    '5\t1\t1\t1\t2\t3\t320\t174\t100\t55\t-1\t行き\n'
    '5\t1\t1\t1\t2\t4\t430\t174\t116\t55\t96.044434\tました\n'
    '2\t1\t2\t0\t0\t0\t43\t290\t500\t50\t-1\t\n'
    '3\t1\t2\t1\t0\t0\t43\t290\t500\t50\t-1\t\n'
    '4\t1\t2\t1\t1\t0\t43\t290\t500\t50\t-1\t\n'
    '5\t1\t2\t1\t1\t1\t43\t290\t160\t50\t91.0\tTokyo\n'
    '5\t1\t2\t1\t1\t2\t215\t290\t160\t50\t90.5\tTower\n'
    '5\t1\t2\t1\t1\t3\t385\t290\t50\t50\t88.0\tは\n'
    '5\t1\t2\t1\t1\t4\t440\t290\t100\t50\t87.0\t高い\n'
    '4\t1\t3\t1\t1\t0\t43\t380\t50\t30\t-1\t\n'
    '5\t1\t3\t1\t1\t1\t43\t380\t50\t30\t10.0\t \n';

void main() {
  late OcrResult result;

  setUp(() => result = parseTesseractTsv(_tsv));

  test(
    'builds one line per (page, block, paragraph, line), dropping blank ones',
    () {
      expect(result.lines.map((l) => l.text), [
        '日本語を勉強しています',
        '東京に行きました',
        'Tokyo Towerは高い',
      ]);
      expect(result.text, '日本語を勉強しています\n東京に行きました\nTokyo Towerは高い');
      expect(result.isEmpty, isFalse);
    },
  );

  test('skips words that are blank after trimming', () {
    expect(result.lines.first.words.map((w) => w.text), [
      '日本語',
      'を',
      '勉強',
      'して',
      'います',
    ]);
  });

  test('offsets locate each word in its line text', () {
    for (final line in result.lines) {
      for (final word in line.words) {
        expect(line.text.substring(word.start, word.end), word.text);
      }
    }

    final words = result.lines.last.words;
    expect(
      [for (final w in words) (w.start, w.end)],
      [(0, 5), (6, 11), (11, 12), (12, 14)],
    );
  });

  test('separates words with a space only when neither side is CJK', () {
    expect(result.lines[2].text, 'Tokyo Towerは高い');
  });

  test('uses the word boxes in image pixels', () {
    final words = result.lines.first.words;
    expect(words[0].bbox, const Rect.fromLTWH(51, 51, 190, 60));
    expect(words[1].bbox, const Rect.fromLTWH(250, 55, 50, 54));
    expect(
      result.lines[1].words.last.bbox,
      const Rect.fromLTWH(430, 174, 116, 55),
    );
  });

  test('scales confidence to 0..1 and maps conf -1 to null', () {
    final first = result.lines.first.words;
    expect(first[0].confidence, closeTo(0.96518021, 1e-9));
    expect(first[2].confidence, closeTo(0.50932121, 1e-9));

    final second = result.lines[1].words;
    expect(second[2].text, '行き');
    expect(second[2].confidence, isNull);
    expect(second[0].confidence, closeTo(0.96737671, 1e-9));
  });

  test('accepts CRLF line endings', () {
    final crlf = parseTesseractTsv(_tsv.replaceAll('\n', '\r\n'));
    expect(crlf.text, result.text);
  });

  test('returns an empty result when there are no words', () {
    final header = _tsv.split('\n').first;
    expect(parseTesseractTsv('').lines, isEmpty);
    expect(parseTesseractTsv('$header\n').isEmpty, isTrue);
  });
}
