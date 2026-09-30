import 'dart:isolate';

import 'package:kuromoji/kuromoji.dart';

import '../models/ja_token.dart';
import 'kana.dart';
import 'tokenizer_service.dart';

typedef _Tokenize = List<Map<String, dynamic>> Function(String text);

/// [TokenizerService] backed by the pure-Dart kuromoji port (IPADIC).
class KuromojiTokenizerService implements TokenizerService {
  Future<_Tokenize>? _tokenize;

  // The runs of text handed to kuromoji. It drops 、 and 。, never returns for
  // an empty sentence or a NUL, and throws on some characters outside the BMP
  // (emoji, rare kanji), so all of those are kept out and become symbol tokens.
  static final _runs = RegExp(
    r'[^、。\u0000\u{10000}-\u{10FFFF}]+',
    unicode: true,
  );

  @override
  Future<void> init() => _load();

  @override
  Future<List<JaToken>> tokenize(String text) async {
    final tokenize = await _load();
    final tokens = <JaToken>[];
    var cursor = 0;

    // Emits the text skipped since [cursor] as one symbol token, then moves
    // [cursor] to [end].
    void skipTo(int end) {
      if (end > cursor) {
        tokens.add(_symbol(text, cursor, end));
      }
      cursor = end;
    }

    for (final run in _runs.allMatches(text)) {
      for (final raw in tokenize(run[0]!)) {
        final surface = raw['surface_form'] as String;
        final start = text.indexOf(surface, cursor);
        if (start < 0) continue; // Not in the text; stays in the gap.
        skipTo(start);
        tokens.add(_token(raw, surface, start));
        cursor = start + surface.length;
      }
    }
    skipTo(text.length);
    return tokens;
  }

  Future<_Tokenize> _load() => _tokenize ??= _build();

  // Decoding the dictionary is heavy, so do it off the calling isolate.
  static Future<_Tokenize> _build() async {
    final tokenizer = await Isolate.run(() => TokenizerBuilder().build());
    return tokenizer.tokenize;
  }

  static JaToken _token(Map<String, dynamic> raw, String surface, int start) {
    final reading = _field(raw['reading']);
    return JaToken(
      surface: surface,
      basicForm: _field(raw['basic_form']) ?? surface,
      reading: reading == null ? null : katakanaToHiragana(reading),
      pos: raw['pos'] as String,
      start: start,
      end: start + surface.length,
    );
  }

  static JaToken _symbol(String text, int start, int end) {
    final surface = text.substring(start, end);
    return JaToken(
      surface: surface,
      basicForm: surface,
      pos: '記号',
      start: start,
      end: end,
    );
  }

  /// kuromoji reports missing IPADIC fields as `*`, or omits them entirely.
  static String? _field(Object? value) =>
      value == '*' ? null : value as String?;
}
