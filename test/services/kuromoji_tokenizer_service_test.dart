import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/ja_token.dart';
import 'package:yominow/services/kuromoji_tokenizer_service.dart';

const _sentence = '私は日本語を勉強しています。東京に行きました、そして帰った。\n猫';

Map<String, JaToken> _bySurface(Iterable<JaToken> tokens) => {
  for (final t in tokens) t.surface: t,
};

/// Asserts that [tokens] tile [text] exactly, in order.
void _expectCovers(String text, List<JaToken> tokens) {
  var cursor = 0;
  for (final t in tokens) {
    expect(t.start, cursor, reason: 'gap or overlap before "${t.surface}"');
    expect(t.end, greaterThan(t.start));
    expect(text.substring(t.start, t.end), t.surface);
    cursor = t.end;
  }
  expect(cursor, text.length);
  expect(tokens.map((t) => t.surface).join(), text);
}

void main() {
  final service = KuromojiTokenizerService();

  setUpAll(service.init);

  group('tokenize', () {
    test('produces tokens that tile the text with exact offsets', () async {
      final tokens = await service.tokenize(_sentence);
      _expectCovers(_sentence, tokens);
      expect(
        tokens.map((t) => t.surface).join('|'),
        '私|は|日本語|を|勉強|し|て|い|ます|。|東京|に|行き|まし|た|、|そして|帰っ|た|。|\n|猫',
      );
    });

    test('returns punctuation and newlines as non-word tokens', () async {
      final tokens = await service.tokenize(_sentence);
      for (final surface in ['。', '、', '\n']) {
        final matches = tokens.where((t) => t.surface == surface);
        expect(matches, isNotEmpty, reason: surface);
        for (final t in matches) {
          expect(t.isWord, isFalse, reason: surface);
          expect(t.pos, '記号');
          expect(t.basicForm, surface);
          expect(t.reading, isNull);
        }
      }
      final punctuation = tokens.where((t) => t.surface == '。').toList();
      expect(punctuation.map((t) => t.start), [
        _sentence.indexOf('。'),
        _sentence.lastIndexOf('。'),
      ]);
      expect(tokens.where((t) => t.surface == '猫').single.isWord, isTrue);
    });

    test('reports dictionary forms of inflected words', () async {
      final tokens = _bySurface(await service.tokenize(_sentence));
      expect(tokens['行き']!.basicForm, '行く');
      expect(tokens['帰っ']!.basicForm, '帰る');
      expect(tokens['し']!.basicForm, 'する');
      expect(tokens['日本語']!.basicForm, '日本語');
    });

    test('reports readings in hiragana', () async {
      final tokens = await service.tokenize(_sentence);
      final byText = _bySurface(tokens);
      expect(byText['勉強']!.reading, 'べんきょう');
      expect(byText['日本語']!.reading, 'にほんご');
      expect(byText['帰っ']!.reading, 'かえっ');
      for (final t in tokens.where((t) => t.reading != null)) {
        expect(t.reading, matches(RegExp(r'^[ぁ-ゖー]+$')), reason: t.surface);
      }
    });

    test('uses the surface and no reading for unknown words', () async {
      final unknown = (await service.tokenize('ｱｲｳ')).single;
      expect(unknown.basicForm, 'ｱｲｳ');
      expect(unknown.reading, isNull);
      expect(unknown.pos, '名詞');
    });

    test('returns no tokens for empty text', () async {
      expect(await service.tokenize(''), isEmpty);
    });

    test('covers text made of or ending in separators', () async {
      for (final text in ['。', '、。', '猫。', '。猫', '猫。。犬、', '「猫」。']) {
        _expectCovers(text, await service.tokenize(text));
      }
      final tokens = await service.tokenize('。。');
      expect(tokens.map((t) => t.surface), ['。。']);
      expect(tokens.single.isWord, isFalse);
    });

    test('returns NUL as a non-word token', () async {
      final nul = String.fromCharCode(0);
      final text = '猫$nul犬';
      final tokens = await service.tokenize(text);
      _expectCovers(text, tokens);
      expect(tokens.map((t) => t.surface), ['猫', nul, '犬']);
      expect(tokens[1].isWord, isFalse);
    });

    test('covers whitespace and full-width characters', () async {
      final ideographicSpace = String.fromCharCode(0x3000);
      final texts = [
        '  猫  犬',
        'ＡＢＣ 123${ideographicSpace}abc',
        '\n\n',
        '猫\n犬\n',
      ];
      for (final text in texts) {
        final tokens = await service.tokenize(text);
        _expectCovers(text, tokens);
        expect(
          tokens.where((t) => t.surface.trim().isEmpty),
          everyElement(predicate<JaToken>((t) => !t.isWord)),
        );
      }
    });

    test(
      'returns characters outside the BMP whole as non-word tokens',
      () async {
        const text = '𠮷野家を食べる😀😀。猫😀';
        final tokens = await service.tokenize(text);
        _expectCovers(text, tokens);
        expect(
          tokens.map((t) => t.surface).join('|'),
          '𠮷|野家|を|食べる|😀😀。|猫|😀',
        );
        expect(tokens.where((t) => !t.isWord).length, 3);
      },
    );
  });

  group('init', () {
    test('is idempotent', () async {
      final fresh = KuromojiTokenizerService();
      final first = fresh.init();
      expect(fresh.init(), same(first));
      await Future.wait([first, fresh.init()]);
      expect(await fresh.tokenize('猫'), hasLength(1));
    });

    test('is implied by tokenize', () async {
      final fresh = KuromojiTokenizerService();
      expect(await fresh.tokenize('猫'), hasLength(1));
      await fresh.init();
    });
  });
}
