import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/services/kana.dart';

void main() {
  group('katakanaToHiragana', () {
    test('converts the whole katakana range', () {
      expect(katakanaToHiragana('ァアィイゥウ'), 'ぁあぃいぅう');
      expect(katakanaToHiragana('ベンキョウ'), 'べんきょう');
      expect(katakanaToHiragana('ヴヵヶ'), 'ゔゕゖ');
    });

    test('keeps the long-vowel mark and other characters', () {
      expect(katakanaToHiragana('ラーメン'), 'らーめん');
      expect(katakanaToHiragana('ニホン語、abc 123。'), 'にほん語、abc 123。');
      expect(katakanaToHiragana('ひらがな'), 'ひらがな');
    });

    test('handles the empty string', () {
      expect(katakanaToHiragana(''), '');
    });
  });

  group('isKanji', () {
    test('accepts CJK ideographs and 々', () {
      for (final char in ['日', '本', '語', '々', '㐀', '豈']) {
        expect(isKanji(char.codeUnitAt(0)), isTrue, reason: char);
      }
    });

    test('accepts runes outside the BMP', () {
      expect(isKanji('𠮷'.runes.first), isTrue);
    });

    test('rejects kana, latin and punctuation', () {
      for (final char in ['あ', 'ア', 'ー', 'a', '1', '。', '、', ' ', 'ｱ']) {
        expect(isKanji(char.codeUnitAt(0)), isFalse, reason: char);
      }
    });
  });

  group('containsKanji', () {
    test('is true when any character is a kanji', () {
      expect(containsKanji('食べる'), isTrue);
      expect(containsKanji('abc日'), isTrue);
      expect(containsKanji('𠮷野家'), isTrue);
    });

    test('is false without kanji', () {
      expect(containsKanji('たべる'), isFalse);
      expect(containsKanji('タベル'), isFalse);
      expect(containsKanji('abc、。'), isFalse);
      expect(containsKanji(''), isFalse);
    });
  });

  group('isKana', () {
    test('accepts hiragana, katakana and ー', () {
      expect(isKana('ひらがな'), isTrue);
      expect(isKana('カタカナ'), isTrue);
      expect(isKana('ラーメン'), isTrue);
      expect(isKana('ひらカナ'), isTrue);
    });

    test('rejects anything else', () {
      expect(isKana(''), isFalse);
      expect(isKana('食べる'), isFalse);
      expect(isKana('たべる。'), isFalse);
      expect(isKana('abc'), isFalse);
      expect(isKana('た べ'), isFalse);
    });
  });
}
