import 'dictionary_entry.dart';
import 'ja_token.dart';

/// Result of looking up the word at a position in a piece of text.
class LookupResult {
  const LookupResult({
    required this.matchedText,
    required this.start,
    required this.end,
    required this.entries,
    this.reading,
    this.token,
  });

  /// The span of the source text that was matched: text.substring(start, end).
  final String matchedText;
  final int start;
  final int end;

  /// Reading of [matchedText] in hiragana, if known.
  final String? reading;

  /// Dictionary entries, best match first. Empty when nothing was found.
  final List<DictionaryEntry> entries;

  /// Tokenizer token at the looked-up position, if any.
  final JaToken? token;

  bool get isEmpty => entries.isEmpty;
}
