import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/ocr_result.dart';
import 'package:yominow/services/ocr/tesseract_tsv_parser.dart';

const _header =
    'level\tpage_num\tblock_num\tpar_num\tline_num\tword_num\tleft\ttop\twidth\theight\tconf\ttext\n';

/// Shaped like real Tesseract TSV: header, page/block/paragraph/line rows
/// (levels 1-4), then words (level 5). The two Japanese lines and their word
/// boxes are taken from a real run, where the word boxes of the second line
/// overlap and drift. It also has an empty word, an unscored word (conf -1), a
/// Latin/Japanese line in a second block that reuses line number 1, and a
/// line that only holds a blank word.
const _tsv =
    '$_header'
    '1\t1\t0\t0\t0\t0\t0\t0\t900\t420\t-1\t\n'
    '2\t1\t1\t0\t0\t0\t43\t51\t694\t180\t-1\t\n'
    '3\t1\t1\t1\t0\t0\t43\t51\t694\t180\t-1\t\n'
    '4\t1\t1\t1\t1\t0\t51\t51\t686\t60\t-1\t\n'
    '5\t1\t1\t1\t1\t1\t51\t51\t87\t60\t96.518021\t日\n'
    '5\t1\t1\t1\t1\t2\t170\t53\t24\t58\t93.266273\t本\n'
    '5\t1\t1\t1\t1\t3\t206\t53\t24\t58\t91.417908\t語\n'
    '5\t1\t1\t1\t1\t4\t259\t51\t69\t60\t93.075661\tを\n'
    '5\t1\t1\t1\t1\t5\t363\t51\t59\t60\t50.932121\t勉強\n'
    '5\t1\t1\t1\t1\t6\t420\t55\t0\t0\t0\t\n'
    '5\t1\t1\t1\t1\t7\t439\t55\t103\t54\t96.563751\tし\n'
    '5\t1\t1\t1\t1\t8\t558\t60\t27\t46\t96.876526\tて\n'
    '5\t1\t1\t1\t1\t9\t593\t54\t76\t54\t93.184914\tいま\n'
    '5\t1\t1\t1\t1\t10\t684\t54\t53\t55\t92.782715\tす\n'
    '4\t1\t1\t1\t2\t0\t43\t171\t503\t60\t-1\t\n'
    '5\t1\t1\t1\t2\t1\t43\t171\t308\t60\t96.737671\t東京\n'
    '5\t1\t1\t1\t2\t2\t228\t166\t69\t91\t96.955948\tに\n'
    '5\t1\t1\t1\t2\t3\t372\t174\t43\t54\t-1\t行き\n'
    '5\t1\t1\t1\t2\t4\t439\t174\t107\t55\t96.044434\tまし\n'
    '5\t1\t1\t1\t2\t5\t493\t166\t55\t91\t97.017349\tた\n'
    '2\t1\t2\t0\t0\t0\t43\t290\t500\t50\t-1\t\n'
    '3\t1\t2\t1\t0\t0\t43\t290\t500\t50\t-1\t\n'
    '4\t1\t2\t1\t1\t0\t43\t290\t400\t50\t-1\t\n'
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

  test('emits one word per CJK character and one per non-CJK run', () {
    expect(result.lines[0].words.map((w) => w.text), [
      '日', '本', '語', 'を', '勉', '強', 'し', 'て', 'い', 'ま', 'す', //
    ]);
    expect(result.lines[1].words.map((w) => w.text), [
      '東', '京', 'に', '行', 'き', 'ま', 'し', 'た', //
    ]);
    expect(result.lines[2].words.map((w) => w.text), [
      'Tokyo',
      'Tower',
      'は',
      '高',
      'い',
    ]);
  });

  test('offsets locate each word in its line text', () {
    for (final line in result.lines) {
      for (final word in line.words) {
        expect(line.text.substring(word.start, word.end), word.text);
      }
    }

    expect(
      [for (final w in result.lines[2].words) (w.start, w.end)],
      [(0, 5), (6, 11), (11, 12), (12, 13), (13, 14)],
    );
  });

  test('spreads the line box evenly over CJK characters', () {
    final words = result.lines[0].words;
    const line = Rect.fromLTWH(51, 51, 686, 60);

    expect(words.first.bbox.left, line.left);
    expect(words.last.bbox.right, closeTo(line.right, 1e-9));
    for (final word in words) {
      expect(word.bbox.top, line.top);
      expect(word.bbox.height, line.height);
      expect(word.bbox.width, closeTo(line.width / 11, 1e-9));
    }
    for (var i = 1; i < words.length; i++) {
      expect(words[i].bbox.left, closeTo(words[i - 1].bbox.right, 1e-9));
    }
  });

  test('ignores the word boxes, which overlap in real Tesseract output', () {
    final words = result.lines[1].words;

    for (var i = 1; i < words.length; i++) {
      expect(words[i].bbox.left, greaterThan(words[i - 1].bbox.left));
      expect(words[i].bbox.left, greaterThanOrEqualTo(words[i - 1].bbox.right));
    }
    expect(words.first.bbox.left, 43);
    expect(words.last.bbox.right, closeTo(546, 1e-9));
  });

  test('gives non-CJK characters half the width of CJK ones', () {
    final words = result.lines[2].words;
    // Line box 43..443: Tokyo (2.5 em) + Tower (2.5 em) + は, 高, い (3 em).
    const em = 400 / 8;

    expect(words[0].bbox.left, 43);
    expect(words[0].bbox.width, closeTo(2.5 * em, 1e-9));
    expect(words[1].bbox.width, closeTo(2.5 * em, 1e-9));
    expect(words[2].bbox.width, closeTo(em, 1e-9));
    expect(words[4].bbox.right, closeTo(443, 1e-9));
  });

  test('gives each character the confidence of its word, -1 becoming null', () {
    final first = result.lines[0].words;
    expect(first[0].confidence, closeTo(0.96518021, 1e-9));
    expect(
      [first[4].confidence, first[5].confidence],
      [closeTo(0.50932121, 1e-9), closeTo(0.50932121, 1e-9)],
    );

    final second = result.lines[1].words;
    expect(second[2].confidence, closeTo(0.96955948, 1e-9));
    expect([second[3].text, second[3].confidence], ['行', null]);
    expect([second[4].text, second[4].confidence], ['き', null]);
  });

  test('falls back to the union of the word boxes without a line row', () {
    final parsed = parseTesseractTsv(
      '$_header'
      '5\t1\t1\t1\t1\t1\t100\t50\t30\t20\t90\t日\n'
      '5\t1\t1\t1\t1\t2\t130\t40\t30\t40\t90\t本\n',
    );

    final words = parsed.lines.single.words;
    expect(words[0].bbox, const Rect.fromLTRB(100, 40, 130, 80));
    expect(words[1].bbox, const Rect.fromLTRB(130, 40, 160, 80));
  });

  test('accepts CRLF line endings', () {
    final crlf = parseTesseractTsv(_tsv.replaceAll('\n', '\r\n'));
    expect(crlf.text, result.text);
  });

  test('returns an empty result when there are no words', () {
    expect(parseTesseractTsv('').lines, isEmpty);
    expect(parseTesseractTsv(_header).isEmpty, isTrue);
  });
}
