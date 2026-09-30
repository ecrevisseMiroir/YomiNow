import '../models/dictionary_entry.dart';

/// A dictionary term found in text, with its entries.
class DictionaryMatch {
  const DictionaryMatch({required this.term, required this.entries});

  final String term;
  final List<DictionaryEntry> entries;
}

/// Read-only access to the bundled JMdict database.
abstract class DictionaryService {
  /// Opens the database (extracting the bundled asset on first run). Safe to
  /// call more than once; the lookup methods call it implicitly.
  Future<void> open();

  /// Entries whose kanji or kana form equals [term] exactly, common and
  /// higher-priority entries first.
  Future<List<DictionaryEntry>> lookup(String term, {int limit = 10});

  /// The longest term that is a prefix of `text.substring(from)` (at most
  /// [maxLength] characters) and exists in the dictionary, or null.
  Future<DictionaryMatch?> longestMatch(
    String text,
    int from, {
    int maxLength = 12,
  });

  Future<void> close();
}
