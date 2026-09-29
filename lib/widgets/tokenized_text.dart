import 'package:flutter/material.dart';

import '../models/ja_token.dart';
import '../services/app_services.dart';

/// Japanese text split into tappable words, with furigana over kanji words.
///
/// Tokenizes [text] with the app's tokenizer; the raw text is shown until
/// (or if) tokenization finishes. Tapping a word calls [onTapOffset] with
/// the word's start offset in [text].
class TokenizedText extends StatefulWidget {
  const TokenizedText({
    super.key,
    required this.text,
    required this.onTapOffset,
  });

  final String text;
  final void Function(int offset) onTapOffset;

  @override
  State<TokenizedText> createState() => _TokenizedTextState();
}

class _TokenizedTextState extends State<TokenizedText> {
  late Future<List<JaToken>> _tokens;

  Future<List<JaToken>> _tokenize() =>
      AppServicesScope.of(context).tokenizer.tokenize(widget.text);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tokens = _tokenize();
  }

  @override
  void didUpdateWidget(TokenizedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _tokens = _tokenize();
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge!;
    return FutureBuilder<List<JaToken>>(
      future: _tokens,
      builder: (context, snapshot) {
        final tokens = snapshot.data;
        if (tokens == null) return Text(widget.text, style: style);
        return Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          children: [
            for (final token in tokens)
              _TokenView(
                token: token,
                style: style,
                onTap: token.isWord
                    ? () => widget.onTapOffset(token.start)
                    : null,
              ),
          ],
        );
      },
    );
  }
}

/// One token: its surface, with the reading above when it contains kanji.
class _TokenView extends StatelessWidget {
  const _TokenView({required this.token, required this.style, this.onTap});

  final JaToken token;
  final TextStyle style;

  /// Null for tokens that are not words (punctuation, whitespace).
  final VoidCallback? onTap;

  static final _kanji = RegExp(r'[㐀-䶿一-鿿豈-﫿々]');

  @override
  Widget build(BuildContext context) {
    final ruby = token.isWord && _kanji.hasMatch(token.surface)
        ? token.reading
        : null;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (ruby != null)
          Text(
            ruby,
            style: style.copyWith(fontSize: (style.fontSize ?? 14) * 0.5),
          ),
        Text(token.surface, style: style),
      ],
    );
    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: content,
    );
  }
}
