import 'package:flutter/material.dart';

import '../models/ocr_result.dart';

/// Identifies one word of an [OcrResult]: its line and its index in that line.
typedef WordId = ({int line, int word});

/// How a [WordBox] is drawn.
enum WordBoxState {
  /// A recognized word nobody has touched.
  normal,

  /// Part of the looked-up span (e.g. one half of a compound) but not the
  /// word that was tapped.
  highlighted,

  /// The word that was tapped.
  selected,
}

const _sky = Color(0xFF38BDF8);
const _emerald = Color(0xFF34D399);

/// A tappable translucent box drawn over one recognized word.
class WordBox extends StatelessWidget {
  const WordBox({
    super.key,
    required this.label,
    required this.onTap,
    this.state = WordBoxState.normal,
  });

  /// The recognized text; used as the accessibility label.
  final String label;
  final WordBoxState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (border, fill) = switch (state) {
      WordBoxState.normal => (
        _sky.withValues(alpha: 0.7),
        _sky.withValues(alpha: 0.2),
      ),
      WordBoxState.highlighted => (
        _emerald.withValues(alpha: 0.7),
        _emerald.withValues(alpha: 0.2),
      ),
      WordBoxState.selected => (_emerald, _emerald.withValues(alpha: 0.4)),
    };
    return Semantics(
      button: true,
      selected: state == WordBoxState.selected,
      label: label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: fill,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lays one [WordBox] per recognized word over an image.
///
/// Word boxes are in image pixels ([imageSize]); they are scaled to whatever
/// size this widget is given, which must show the whole image stretched to
/// fit. Each box has the key `ValueKey('word-$lineIndex-$wordIndex')`.
class WordOverlay extends StatelessWidget {
  const WordOverlay({
    super.key,
    required this.result,
    required this.imageSize,
    required this.onWordTap,
    this.selected,
    this.highlighted = const {},
  });

  final OcrResult result;

  /// Size in pixels of the image that [OcrWord.bbox] refers to.
  final Size imageSize;

  /// The tapped word, drawn as [WordBoxState.selected].
  final WordId? selected;

  /// Other words drawn as [WordBoxState.highlighted].
  final Set<WordId> highlighted;

  final void Function(int lineIndex, int wordIndex) onWordTap;

  WordBoxState _stateOf(WordId id) {
    if (id == selected) return WordBoxState.selected;
    if (highlighted.contains(id)) return WordBoxState.highlighted;
    return WordBoxState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scaleX = constraints.maxWidth / imageSize.width;
        final scaleY = constraints.maxHeight / imageSize.height;
        return Stack(
          fit: StackFit.expand,
          children: [
            for (final (lineIndex, line) in result.lines.indexed)
              for (final (wordIndex, word) in line.words.indexed)
                Positioned.fromRect(
                  rect: Rect.fromLTRB(
                    word.bbox.left * scaleX,
                    word.bbox.top * scaleY,
                    word.bbox.right * scaleX,
                    word.bbox.bottom * scaleY,
                  ),
                  child: WordBox(
                    key: ValueKey('word-$lineIndex-$wordIndex'),
                    label: word.text,
                    state: _stateOf((line: lineIndex, word: wordIndex)),
                    onTap: () => onWordTap(lineIndex, wordIndex),
                  ),
                ),
          ],
        );
      },
    );
  }
}
