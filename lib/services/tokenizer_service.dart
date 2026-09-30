import '../models/ja_token.dart';

/// Japanese morphological analysis.
abstract class TokenizerService {
  /// Loads the tokenizer dictionary. Safe to call more than once; [tokenize]
  /// calls it implicitly.
  Future<void> init();

  /// Splits [text] into tokens whose [JaToken.start]/[JaToken.end] index into
  /// [text] itself. Tokens cover the text in order; punctuation is included as
  /// tokens with `isWord == false`.
  Future<List<JaToken>> tokenize(String text);
}
