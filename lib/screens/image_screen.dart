import 'dart:io';

import 'package:flutter/material.dart';

import '../models/lookup_result.dart';
import '../models/ocr_result.dart';
import '../services/app_services.dart';
import '../services/image_preprocessor.dart';
import '../services/ocr/ocr_service.dart';
import '../widgets/lookup_sheet.dart';
import '../widgets/tokenized_text.dart';
import '../widgets/word_overlay.dart';

/// Shows a photo, runs OCR on it and lets the user tap the detected words to
/// look them up.
class ImageScreen extends StatefulWidget {
  const ImageScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  bool _started = false;
  PreparedImage? _image;
  OcrResult? _result;
  Object? _error;
  double _progress = 0;

  bool _showText = false;
  WordId? _selected;
  Set<WordId> _highlighted = const {};

  /// Counts lookups so a slow one cannot highlight over a newer one.
  int _lookupCount = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _recognize(AppServicesScope.of(context));
  }

  Future<void> _recognize(AppServices services) async {
    try {
      final image = await services.imagePreprocessor.prepare(widget.imagePath);
      if (!mounted) return;
      setState(() => _image = image);
      final result = await services.ocr.recognize(
        image.path,
        onProgress: (progress, _) {
          if (mounted) setState(() => _progress = progress);
        },
      );
      if (mounted) setState(() => _result = result);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  /// Opens the dictionary sheet for the word at [offset] in [line] and
  /// highlights every word of the line that the match covers.
  void _lookup(OcrLine line, int lineIndex, int offset, {WordId? selected}) {
    final lookup = AppServicesScope.of(context).lookup;
    final result = lookup.lookupAt(line.text, offset);
    final id = ++_lookupCount;
    setState(() {
      _selected = selected;
      _highlighted = {?selected};
    });
    result.then((match) {
      if (match == null || !mounted || id != _lookupCount) return;
      setState(() => _highlighted = _wordsCovered(line, lineIndex, match));
    }).ignore(); // The sheet reports failures.
    LookupSheet.show(context, result);
  }

  void _lookupWord(OcrResult result, int lineIndex, int wordIndex) {
    final line = result.lines[lineIndex];
    _lookup(
      line,
      lineIndex,
      line.words[wordIndex].start,
      selected: (line: lineIndex, word: wordIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final result = _result;
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (image != null)
                  Positioned.fill(
                    child: _Photo(
                      image: image,
                      overlay: result == null
                          ? null
                          : WordOverlay(
                              result: result,
                              imageSize: Size(
                                image.width.toDouble(),
                                image.height.toDouble(),
                              ),
                              selected: _selected,
                              highlighted: _highlighted,
                              onWordTap: (lineIndex, wordIndex) =>
                                  _lookupWord(result, lineIndex, wordIndex),
                            ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _StatusBanner(
                    result: result,
                    error: _error,
                    progress: _progress,
                  ),
                ),
                if (_showText && result != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: SafeArea(
                      bottom: false,
                      child: _FullTextPanel(
                        lines: result.lines,
                        onTapOffset: (lineIndex, offset) =>
                            _lookup(result.lines[lineIndex], lineIndex, offset),
                        onClose: () => setState(() => _showText = false),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _BottomBar(
            onRetake: () => Navigator.of(context).pop(),
            onToggleText: result == null || result.isEmpty
                ? null
                : () => setState(() => _showText = !_showText),
          ),
        ],
      ),
    );
  }
}

/// The ids of the words in [line] whose text overlaps the span matched by
/// [match].
Set<WordId> _wordsCovered(OcrLine line, int lineIndex, LookupResult match) => {
  for (final (wordIndex, word) in line.words.indexed)
    if (word.start < match.end && word.end > match.start)
      (line: lineIndex, word: wordIndex),
};

/// The photo, contained in the viewport, with [overlay] on top of it.
/// Zooming and panning move both together.
class _Photo extends StatelessWidget {
  const _Photo({required this.image, required this.overlay});

  final PreparedImage image;

  /// Stretched over the photo; null while OCR is still running.
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      maxScale: 8,
      child: Center(
        child: AspectRatio(
          aspectRatio: image.width / image.height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(File(image.path), fit: BoxFit.fill),
              ?overlay,
            ],
          ),
        ),
      ),
    );
  }
}

/// The banner across the top: progress, an error, or "no text"; nothing when
/// text was found.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.result,
    required this.error,
    required this.progress,
  });

  final OcrResult? result;
  final Object? error;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    final result = this.result;
    if (error != null) {
      return _Banner(
        color: Colors.red.shade900.withValues(alpha: 0.85),
        child: _ErrorMessage(error: error),
      );
    }
    if (result == null) {
      return _Banner(
        color: Colors.black.withValues(alpha: 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            const Text('Detecting Japanese text…'),
            SizedBox(
              width: 256,
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      );
    }
    if (result.isEmpty) {
      return _Banner(
        color: Colors.black.withValues(alpha: 0.7),
        child: const Text('No Japanese text detected.'),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(child: child),
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    final error = this.error;
    if (error is! OcrUnavailableException) {
      return Text('OCR failed: $error', textAlign: TextAlign.center);
    }
    final hint = error.hint;
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        Text(
          error.message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        if (hint != null)
          SelectableText(
            hint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
      ],
    );
  }
}

/// The "Retake" and "Text" pill buttons.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onRetake, required this.onToggleText});

  final VoidCallback onRetake;

  /// Null while there is no text to show, which hides the button.
  final VoidCallback? onToggleText;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            FilledButton.tonalIcon(
              onPressed: onRetake,
              icon: const Icon(Icons.replay),
              label: const Text('Retake'),
            ),
            if (onToggleText != null)
              FilledButton.tonalIcon(
                onPressed: onToggleText,
                icon: const Icon(Icons.document_scanner_outlined),
                label: const Text('Text'),
              ),
          ],
        ),
      ),
    );
  }
}

/// The full detected text, one [TokenizedText] per line.
class _FullTextPanel extends StatelessWidget {
  const _FullTextPanel({
    required this.lines,
    required this.onTapOffset,
    required this.onClose,
  });

  final List<OcrLine> lines;
  final void Function(int lineIndex, int offset) onTapOffset;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHigh.withValues(alpha: 0.95),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detected text',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    for (final (index, line) in lines.indexed)
                      TokenizedText(
                        text: line.text,
                        onTapOffset: (offset) => onTapOffset(index, offset),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
