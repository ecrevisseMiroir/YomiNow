import '../models/lookup_result.dart';

/// Combines tokenization and dictionary search to answer "what word is at
/// this position?".
abstract class LookupService {
  /// Looks up the word at character [offset] of [text] (typically an OCR line).
  /// Returns null when [offset] is on punctuation/whitespace or out of range.
  Future<LookupResult?> lookupAt(String text, int offset);
}
