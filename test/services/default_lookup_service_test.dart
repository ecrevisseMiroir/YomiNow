import 'package:flutter_test/flutter_test.dart';
import 'package:yominow/models/dictionary_entry.dart';
import 'package:yominow/models/ja_token.dart';
import 'package:yominow/services/default_lookup_service.dart';
import 'package:yominow/services/dictionary_service.dart';
import 'package:yominow/services/kuromoji_tokenizer_service.dart';
import 'package:yominow/services/tokenizer_service.dart';

DictionaryEntry _entry(int id, String headword, String reading) =>
    DictionaryEntry(
      id: id,
      kanji: headword == reading ? const [] : [headword],
      readings: [reading],
      senses: [
        Sense(pos: const [], glosses: ['gloss $id']),
      ],
    );

JaToken _token(
  String text,
  String surface, {
  String? basicForm,
  String? reading,
  String pos = '名詞',
}) {
  final start = text.indexOf(surface);
  return JaToken(
    surface: surface,
    basicForm: basicForm ?? surface,
    reading: reading,
    pos: pos,
    start: start,
    end: start + surface.length,
  );
}

/// Returns a fixed token list, so tests can pin down the tokenizer's output.
class _FakeTokenizer implements TokenizerService {
  _FakeTokenizer(this.tokens);

  final List<JaToken> tokens;

  @override
  Future<void> init() async {}

  @override
  Future<List<JaToken>> tokenize(String text) async => tokens;
}

/// In-memory dictionary keyed by exact term.
class _FakeDictionary implements DictionaryService {
  _FakeDictionary(this.terms);

  final Map<String, List<DictionaryEntry>> terms;
  final lookups = <String>[];

  @override
  Future<void> open() async {}

  @override
  Future<List<DictionaryEntry>> lookup(String term, {int limit = 10}) async {
    lookups.add(term);
    return terms[term] ?? const [];
  }

  @override
  Future<DictionaryMatch?> longestMatch(
    String text,
    int from, {
    int maxLength = 12,
  }) async {
    final longest = (text.length - from).clamp(0, maxLength);
    for (var length = longest; length > 0; length--) {
      final term = text.substring(from, from + length);
      final entries = terms[term];
      if (entries != null) {
        return DictionaryMatch(term: term, entries: entries);
      }
    }
    return null;
  }

  @override
  Future<void> close() async {}
}

void main() {
  final kuromoji = KuromojiTokenizerService();

  setUpAll(kuromoji.init);

  group('with the real tokenizer', () {
    final taberu = _entry(1, '食べる', 'たべる');
    final shoku = _entry(2, '食', 'しょく');
    final nihon = _entry(3, '日本', 'にほん');
    final nihongo = _entry(4, '日本語', 'にほんご');

    DefaultLookupService serviceFor(Map<String, List<DictionaryEntry>> terms) =>
        DefaultLookupService(
          tokenizer: kuromoji,
          dictionary: _FakeDictionary(terms),
        );

    test('looks up the dictionary form of an inflected word', () async {
      final service = serviceFor({
        '食べる': [taberu],
        '食': [shoku],
      });
      const text = '食べました';
      final result = await service.lookupAt(text, text.indexOf('食'));

      expect(result, isNotNull);
      expect(result!.entries.map((e) => e.id), [1, 2]);
      expect(result.entries.first.headword, '食べる');
      expect(result.matchedText, '食べ');
      expect([result.start, result.end], [0, 2]);
      expect(result.reading, 'たべ');
      expect(result.token!.surface, '食べ');
      expect(result.token!.basicForm, '食べる');
      expect(result.isEmpty, isFalse);
    });

    test('resolves any offset inside a token to that token', () async {
      final service = serviceFor({
        '食べる': [taberu],
      });
      const text = '猫が食べました';
      final atSecondChar = await service.lookupAt(text, text.indexOf('べ'));

      expect(atSecondChar!.matchedText, '食べ');
      expect([atSecondChar.start, atSecondChar.end], [2, 4]);
    });

    test('matches a compound spanning the whole token', () async {
      final service = serviceFor({
        '日本': [nihon],
        '日本語': [nihongo],
      });
      const text = '日本語を勉強する';
      final result = await service.lookupAt(text, 1);

      expect(result!.matchedText, '日本語');
      expect([result.start, result.end], [0, 3]);
      expect(result.entries.map((e) => e.id), [4]);
      expect(result.reading, 'にほんご');
    });

    test('returns null on punctuation, whitespace and out of range', () async {
      final service = serviceFor({
        '猫': [_entry(5, '猫', 'ねこ')],
      });
      const text = '猫です。 猫\n';

      expect(await service.lookupAt(text, text.indexOf('。')), isNull);
      expect(await service.lookupAt(text, text.indexOf(' ')), isNull);
      expect(await service.lookupAt(text, text.indexOf('\n')), isNull);
      expect(await service.lookupAt(text, -1), isNull);
      expect(await service.lookupAt(text, text.length), isNull);
      expect(await service.lookupAt('', 0), isNull);
      expect(await service.lookupAt(text, 0), isNotNull);
    });

    test('returns an empty result for an unknown word', () async {
      final service = serviceFor({});
      const text = 'ｱｲｳです';
      final result = await service.lookupAt(text, 1);

      expect(result, isNotNull);
      expect(result!.isEmpty, isTrue);
      expect(result.entries, isEmpty);
      expect(result.matchedText, 'ｱｲｳ');
      expect([result.start, result.end], [0, 3]);
      expect(result.reading, isNull);
      expect(result.token!.surface, 'ｱｲｳ');
    });
  });

  group('with a scripted tokenizer', () {
    DefaultLookupService serviceFor(
      List<JaToken> tokens,
      Map<String, List<DictionaryEntry>> terms,
    ) => DefaultLookupService(
      tokenizer: _FakeTokenizer(tokens),
      dictionary: _FakeDictionary(terms),
    );

    test('prefers a compound the tokenizer split', () async {
      const text = '日本語を';
      final nihon = _entry(1, '日本', 'にほん');
      final nihongo = _entry(2, '日本語', 'にほんご');
      final service = serviceFor(
        [
          _token(text, '日本', reading: 'にほん'),
          _token(text, '語', reading: 'ご'),
          _token(text, 'を', pos: '助詞', reading: 'を'),
        ],
        {
          '日本': [nihon],
          '日本語': [nihongo],
        },
      );
      final result = await service.lookupAt(text, 0);

      expect(result!.matchedText, '日本語');
      expect([result.start, result.end], [0, 3]);
      expect(result.entries.map((e) => e.id), [2]);
      expect(result.reading, 'にほんご');
      expect(result.token!.surface, '日本');
    });

    test('puts a longer match before the dictionary form', () async {
      const text = '食べ物';
      final taberu = _entry(1, '食べる', 'たべる');
      final tabemono = _entry(2, '食べ物', 'たべもの');
      final service = serviceFor(
        [
          _token(text, '食べ', basicForm: '食べる', pos: '動詞', reading: 'たべ'),
          _token(text, '物', reading: 'もの'),
        ],
        {
          '食べる': [taberu],
          '食べ物': [tabemono],
        },
      );
      final result = await service.lookupAt(text, 0);

      expect(result!.entries.map((e) => e.id), [2, 1]);
      expect(result.matchedText, '食べ物');
      expect(result.reading, 'たべもの');
    });

    test('takes the reading of a shorter match from its entry', () async {
      const text = '勉強する';
      final ben = _entry(1, '勉', 'べん');
      final service = serviceFor(
        [
          _token(text, '勉強', reading: 'べんきょう'),
          _token(text, 'する', pos: '動詞', reading: 'する'),
        ],
        {
          '勉': [ben],
        },
      );
      final result = await service.lookupAt(text, 0);

      expect(result!.matchedText, '勉');
      expect([result.start, result.end], [0, 1]);
      expect(result.reading, 'べん');
      expect(result.entries.map((e) => e.id), [1]);
    });

    test('removes duplicate entries, keeping order', () async {
      const text = '食べた';
      final taberu = _entry(1, '食べる', 'たべる');
      final other = _entry(2, '食べる', 'くべる');
      final noun = _entry(3, '食べ', 'たべ');
      final service = serviceFor(
        [
          _token(text, '食べ', basicForm: '食べる', pos: '動詞', reading: 'たべ'),
          _token(text, 'た', pos: '助動詞', reading: 'た'),
        ],
        {
          '食べる': [taberu, other],
          '食べ': [noun, taberu],
        },
      );
      final result = await service.lookupAt(text, 0);

      expect(result!.entries.map((e) => e.id), [1, 2, 3]);
      expect(result.matchedText, '食べ');
    });

    test(
      'falls back to the reading when the written form is missing',
      () async {
        const text = '綺麗だ';
        final kirei = _entry(1, 'きれい', 'きれい');
        final dictionary = _FakeDictionary({
          'きれい': [kirei],
        });
        final service = DefaultLookupService(
          tokenizer: _FakeTokenizer([
            _token(text, '綺麗', reading: 'きれい'),
            _token(text, 'だ', pos: '助動詞', reading: 'だ'),
          ]),
          dictionary: dictionary,
        );
        final result = await service.lookupAt(text, 0);

        expect(dictionary.lookups, ['きれい']);
        expect(result!.entries.map((e) => e.id), [1]);
        expect(result.matchedText, '綺麗');
        expect([result.start, result.end], [0, 2]);
        expect(result.reading, 'きれい');
      },
    );

    test('does not use the reading when the written form is found', () async {
      const text = '猫';
      final dictionary = _FakeDictionary({
        '猫': [_entry(1, '猫', 'ねこ')],
        'ねこ': [_entry(2, 'ねこ', 'ねこ')],
      });
      final service = DefaultLookupService(
        tokenizer: _FakeTokenizer([_token(text, '猫', reading: 'ねこ')]),
        dictionary: dictionary,
      );
      final result = await service.lookupAt(text, 0);

      expect(result!.entries.map((e) => e.id), [1]);
      expect(dictionary.lookups, isEmpty);
    });

    test('returns an empty result when the reading is missing too', () async {
      const text = 'ｱｲｳ';
      final dictionary = _FakeDictionary({});
      final service = DefaultLookupService(
        tokenizer: _FakeTokenizer([_token(text, 'ｱｲｳ')]),
        dictionary: dictionary,
      );
      final result = await service.lookupAt(text, 0);

      expect(result!.isEmpty, isTrue);
      expect(dictionary.lookups, isEmpty);
    });

    test(
      'keeps the token reading when the dictionary form is not found',
      () async {
        const text = '食べた';
        final service = serviceFor([
          _token(text, '食べ', basicForm: '食べる', pos: '動詞', reading: 'たべ'),
          _token(text, 'た', pos: '助動詞', reading: 'た'),
        ], {});
        final result = await service.lookupAt(text, 0);

        expect(result!.isEmpty, isTrue);
        expect(result.matchedText, '食べ');
        expect(result.reading, 'たべ');
      },
    );
  });
}
