import '../models/dictionary_entry.dart';
import '../models/lookup_result.dart';
import 'dictionary_service.dart';
import 'lookup_service.dart';
import 'tokenizer_service.dart';

/// [LookupService] that tokenizes the text, then searches the dictionary for
/// the token at the tapped position, its dictionary form and the longest
/// dictionary term starting there.
class DefaultLookupService implements LookupService {
  DefaultLookupService({
    required TokenizerService tokenizer,
    required DictionaryService dictionary,
  }) : _tokenizer = tokenizer,
       _dictionary = dictionary;

  final TokenizerService _tokenizer;
  final DictionaryService _dictionary;

  @override
  Future<LookupResult?> lookupAt(String text, int offset) async {
    if (offset < 0 || offset >= text.length) return null;
    final tokens = await _tokenizer.tokenize(text);
    final token = tokens
        .where((t) => t.start <= offset && offset < t.end)
        .firstOrNull;
    if (token == null || !token.isWord) return null;

    // Compounds and expressions the tokenizer splits, e.g. 日本 + 語.
    final longest = await _dictionary.longestMatch(text, token.start);
    final longerThanToken =
        longest != null && longest.term.length > token.surface.length;
    // Inflected forms (食べ → 食べる), and the token itself when a longer
    // match could hide it (今日は "hello" must not hide 今日 "today").
    final base = token.basicForm != token.surface || longerThanToken
        ? await _dictionary.lookup(token.basicForm)
        : const <DictionaryEntry>[];

    final baseFirst = base.isNotEmpty && !longerThanToken;
    final primary = baseFirst ? base : longest?.entries ?? const [];
    final secondary = baseFirst ? longest?.entries ?? const [] : base;

    final tokenReading = token.reading;
    var entries = _merge(primary, secondary);
    var end = token.end;
    var reading = tokenReading;
    if (!baseFirst && longest != null) {
      end = token.start + longest.term.length;
      if (end != token.end) {
        reading = entries.firstOrNull?.readings.firstOrNull;
      }
    }
    // Last resort: the kana spelling, for words the dictionary only lists
    // that way.
    if (entries.isEmpty && tokenReading != null) {
      entries = await _dictionary.lookup(tokenReading);
    }

    return LookupResult(
      matchedText: text.substring(token.start, end),
      start: token.start,
      end: end,
      reading: reading,
      entries: entries,
      token: token,
    );
  }

  /// [first] followed by the entries of [second] not already in it.
  static List<DictionaryEntry> _merge(
    List<DictionaryEntry> first,
    List<DictionaryEntry> second,
  ) {
    final seen = <int>{};
    return [
      for (final entry in [...first, ...second])
        if (seen.add(entry.id)) entry,
    ];
  }
}
