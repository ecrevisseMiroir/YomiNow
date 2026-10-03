import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/services/ocr/ocr_line_builder.dart';

RawOcrWord _raw(String text, Rect bbox, [double? confidence]) =>
    (text: text, bbox: bbox, confidence: confidence);

void main() {
  group('layOutAcross', () {
    test('divides the box by advance width: CJK full, other half', () {
      final boxes = layOutAcross(const Rect.fromLTWH(10, 20, 200, 40), [
        'ab', // 1 em
        '日', // 1 em
        'cd', // 1 em
        '本', // 1 em
      ]);

      expect(boxes, const [
        Rect.fromLTRB(10, 20, 60, 60),
        Rect.fromLTRB(60, 20, 110, 60),
        Rect.fromLTRB(110, 20, 160, 60),
        Rect.fromLTRB(160, 20, 210, 60),
      ]);
    });
  });

  group('joinOcrWords', () {
    test('splits CJK words into one word per character', () {
      final line = joinOcrWords([
        _raw('日本語', const Rect.fromLTWH(0, 10, 90, 30), 0.8),
        _raw('を', const Rect.fromLTWH(90, 10, 30, 30), 0.9),
      ]);

      expect(line.text, '日本語を');
      expect(line.words.map((w) => w.text), ['日', '本', '語', 'を']);
      expect(line.words.map((w) => (w.start, w.end)), [
        (0, 1),
        (1, 2),
        (2, 3),
        (3, 4),
      ]);
      expect(line.words.map((w) => w.bbox), const [
        Rect.fromLTWH(0, 10, 30, 30),
        Rect.fromLTWH(30, 10, 30, 30),
        Rect.fromLTWH(60, 10, 30, 30),
        Rect.fromLTWH(90, 10, 30, 30),
      ]);
      expect(line.words.map((w) => w.confidence), [0.8, 0.8, 0.8, 0.9]);
    });

    test('keeps a run of non-CJK characters as one word', () {
      final line = joinOcrWords([
        _raw('Tokyo2024年', const Rect.fromLTWH(0, 0, 100, 20)),
      ]);

      expect(line.words.map((w) => w.text), ['Tokyo2024', '年']);
      // 9 half-width characters and one full-width: 5.5 em in total.
      expect(line.words[0].bbox.width, closeTo(100 * 4.5 / 5.5, 1e-9));
      expect(line.words[1].bbox.left, closeTo(100 * 4.5 / 5.5, 1e-9));
      expect(line.words[1].bbox.right, closeTo(100, 1e-9));
    });

    test('separates words with a space only when neither side is CJK', () {
      final line = joinOcrWords([
        _raw('Tokyo', const Rect.fromLTWH(0, 0, 50, 20)),
        _raw('Tower', const Rect.fromLTWH(50, 0, 50, 20)),
        _raw('は', const Rect.fromLTWH(100, 0, 20, 20)),
        _raw('高い', const Rect.fromLTWH(120, 0, 40, 20)),
      ]);

      expect(line.text, 'Tokyo Towerは高い');
      expect(line.words.map((w) => w.text), ['Tokyo', 'Tower', 'は', '高', 'い']);
      expect(line.words.map((w) => (w.start, w.end)), [
        (0, 5),
        (6, 11),
        (11, 12),
        (12, 13),
        (13, 14),
      ]);
    });

    test('skips blank words and trims the others', () {
      final line = joinOcrWords([
        _raw(' ', const Rect.fromLTWH(0, 0, 10, 10)),
        _raw(' 東京\n', const Rect.fromLTWH(10, 0, 60, 10)),
      ]);

      expect(line.text, '東京');
      expect(line.words.map((w) => w.text), ['東', '京']);
    });

    test('counts characters outside the BMP as one CJK character', () {
      final line = joinOcrWords([
        _raw('𠮷野', const Rect.fromLTWH(0, 0, 60, 20)),
      ]);

      expect(line.words.map((w) => w.text), ['𠮷', '野']);
      expect(line.words.map((w) => (w.start, w.end)), [(0, 2), (2, 3)]);
      expect(line.text.substring(0, 2), '𠮷');
    });

    test('returns an empty line when there is nothing to join', () {
      final line = joinOcrWords(const []);

      expect(line.text, isEmpty);
      expect(line.words, isEmpty);
    });
  });
}
