import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/lookup_result.dart';
import '../models/ocr_result.dart';
import '../services/anki_droid_service.dart';
import '../services/app_services.dart';
import '../services/image_preprocessor.dart';
import '../services/ocr/ocr_service.dart';
import '../services/yomi_now_notification_history.dart';
import '../widgets/lookup_sheet.dart';
import '../widgets/no_japanese_text.dart';
import '../widgets/yomi_now_notification.dart';
import '../widgets/word_overlay.dart';
import 'loading_screen.dart';

import 'package:yominow/l10n/app_localizations.dart';

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
  bool _isRecognizing = true;
  int _processingStep = 0;

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
      setState(() {
        _image = image;
        _processingStep = 1;
      });

      final result = await services.ocr.recognize(
        image.path,
        onProgress: (progress, _) {
          if (!mounted) return;
          final step = progress >= 1 ? 4 : 1;
          if (_processingStep != step) {
            setState(() => _processingStep = step);
          }
        },
      );
      if (mounted) {
        setState(() {
          _result = result;
          _isRecognizing = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _error = error;
          _isRecognizing = false;
        });
      }
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
    final ankiService = defaultTargetPlatform == TargetPlatform.android
        ? AnkiDroidService()
        : null;
    // Show the lookup sheet and clear the selected word when the sheet is dismissed.
    LookupSheet.show(
      context,
      result,
      onAddToAnki: ankiService == null ? null : _addToAnki,
      isAlreadyInAnki: ankiService?.isDuplicate,
    ).then((_) {
      if (!mounted) return;
      // After the sheet is closed, keep the highlighted words but clear the selection.
      setState(() => _selected = null);
    });
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

  void _addToAnki(LookupResult result) async {
    final l10n = AppLocalizations.of(context)!;
    final meanings = result.entries
        .expand((entry) => entry.senses)
        .expand((sense) => sense.glosses)
        .toSet()
        .take(5)
        .join('; ');
    final back = [
      result.reading,
      meanings,
    ].whereType<String>().where((value) => value.isNotEmpty).join('\n');
    try {
      final outcome = await AnkiDroidService().addNote(
        word: result.matchedText,
        back: back,
      );
      if (!mounted) return;
      final (title, message, kind) = switch (outcome) {
        AnkiDroidAddResult.added => (
          l10n.ankiNotificationAddedTitle,
          l10n.ankiNotificationAddedMessage(result.matchedText),
          YomiNowNotificationKind.success,
        ),
        AnkiDroidAddResult.duplicate => (
          l10n.ankiNotificationDuplicateTitle,
          l10n.ankiNotificationDuplicateMessage(result.matchedText),
          YomiNowNotificationKind.info,
        ),
        AnkiDroidAddResult.shared => (
          l10n.ankiNotificationOpenedTitle,
          l10n.ankiNotificationOpenedMessage(result.matchedText),
          YomiNowNotificationKind.info,
        ),
      };
      YomiNowNotification.show(
        context,
        title: title,
        message: message,
        kind: kind,
      );
    } on MissingPluginException {
      if (!mounted) return;
      YomiNowNotification.show(
        context,
        title: l10n.ankiNotificationErrorTitle,
        message: l10n.ankiNotificationRestartMessage,
        kind: YomiNowNotificationKind.error,
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      YomiNowNotification.show(
        context,
        title: l10n.ankiNotificationErrorTitle,
        message: error.message ?? l10n.ankiNotificationErrorMessage,
        kind: YomiNowNotificationKind.error,
      );
    }
  }

  void _close() {
    Navigator.of(context).pop(_result?.isEmpty == false);
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    final result = _result;
    final hasText = result != null && !result.isEmpty;
    final isLoading = _isRecognizing;
    final colorScheme = Theme.of(context).colorScheme;
    return PopScope<bool>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _DetectedTextHeader(onBack: _close),
              if (isLoading)
                Expanded(child: LoadingScreen(currentStep: _processingStep))
              else if (hasText) ...[
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _buildImageView(image!, result),
                  ),
                ),
                const _LookupHint(),
              ] else
                Expanded(
                  child: Center(
                    child: _error == null
                        ? NoJapaneseText(onTryAgain: _close)
                        : _StatusBanner(result: result, error: _error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageView(PreparedImage image, OcrResult result) {
    return Padding(
      key: const ValueKey('detected-image'),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: _Photo(
          image: image,
          overlay: WordOverlay(
            result: result,
            imageSize: Size(image.width.toDouble(), image.height.toDouble()),
            selected: _selected,
            highlighted: _highlighted,
            onWordTap: (lineIndex, wordIndex) =>
                _lookupWord(result, lineIndex, wordIndex),
          ),
        ),
      ),
    );
  }
}

class _DetectedTextHeader extends StatelessWidget {
  const _DetectedTextHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          IconButton(
            tooltip: AppLocalizations.of(context)!.imageScreenBackButtonTooltip,
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: colorScheme.onSurface,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.imageScreenDetectedTextTitle,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LookupHint extends StatelessWidget {
  const _LookupHint();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 54),
      margin: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(Icons.touch_app_rounded, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.imageScreenLookupHint,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
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

/// An error or empty-result message shown when there are no detected lines.
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.result, required this.error});

  final OcrResult? result;
  final Object? error;

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
    if (result == null || result.isEmpty) {
      final colorScheme = Theme.of(context).colorScheme;
      return _Banner(
        color: colorScheme.surfaceContainerHigh,
        child: Text(
          AppLocalizations.of(context)!.imageScreenNoJapaneseDetected,
          style: TextStyle(color: colorScheme.onSurface),
        ),
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
