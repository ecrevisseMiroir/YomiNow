/// A morpheme produced by the Japanese tokenizer.
class JaToken {
  const JaToken({
    required this.surface,
    required this.basicForm,
    required this.pos,
    required this.start,
    required this.end,
    this.reading,
  });

  /// Text exactly as it appears in the source string.
  final String surface;

  /// Dictionary (lemma) form, e.g. 食べ → 食べる. Equals [surface] when the
  /// tokenizer has no better answer.
  final String basicForm;

  /// Reading in hiragana, or null when unknown.
  final String? reading;

  /// Top-level IPADIC part of speech (名詞, 動詞, 助詞, 記号, ...).
  final String pos;

  /// Character range inside the tokenized string: [start, end).
  final int start;
  final int end;

  /// False for punctuation/symbols and whitespace.
  bool get isWord => pos != '記号' && surface.trim().isNotEmpty;
}
