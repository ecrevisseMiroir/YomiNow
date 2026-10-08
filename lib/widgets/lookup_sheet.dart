import 'package:flutter/material.dart';
import 'package:yominow/services/tts_service.dart';

import '../models/dictionary_entry.dart';
import '../models/lookup_result.dart';
import '../services/lookup_history.dart';

import 'package:yominow/l10n/app_localizations.dart';

/// Callback for when the user wants to add the looked-up word to Anki.
typedef AddToAnkiCallback = void Function(LookupResult result);

/// A draggable bottom sheet with the dictionary entries for one lookup.
///
/// Shows a loading indicator until [result] completes. A null result means
/// there was no word at the tapped position.
class LookupSheet extends StatelessWidget {
  const LookupSheet({
    super.key,
    required this.result,
    this.onAddToAnki,
    this.isAlreadyInAnki,
  });

  final Future<LookupResult?> result;
  final AddToAnkiCallback? onAddToAnki;
  final Future<bool> Function(String word)? isAlreadyInAnki;

  /// Shows a [LookupSheet] for [result] as a modal bottom sheet.
  /// Optional [onAddToAnki] callback is invoked when the user taps the
  /// "Add to Anki" button.
  static Future<void> show(
    BuildContext context,
    Future<LookupResult?> result, {
    AddToAnkiCallback? onAddToAnki,
    Future<bool> Function(String word)? isAlreadyInAnki,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      // The DraggableScrollableSheet handles dragging (and closes at its
      // minimum size), so the modal route must not compete for the gesture.
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => LookupSheet(
        result: result,
        onAddToAnki: onAddToAnki,
        isAlreadyInAnki: isAlreadyInAnki,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Material(
        color: scheme.surfaceContainerLow,
        elevation: 3,
        shadowColor: Colors.black54,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const _DragHandle(),
                  FutureBuilder<LookupResult?>(
                    future: result,
                    builder: (context, snapshot) => _SheetBody(
                      snapshot: snapshot,
                      onAddToAnki: onAddToAnki,
                      isAlreadyInAnki: isAlreadyInAnki,
                    ),
                  ),
                ],
              ),
            ),
            const _Attribution(),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant
              .withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Attribution extends StatelessWidget {
  const _Attribution();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              l10n.lookupAttribution,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Picks what the sheet shows for the state of the lookup future.
class _SheetBody extends StatelessWidget {
  const _SheetBody({
    required this.snapshot,
    this.onAddToAnki,
    this.isAlreadyInAnki,
  });

  final AsyncSnapshot<LookupResult?> snapshot;
  final AddToAnkiCallback? onAddToAnki;
  final Future<bool> Function(String word)? isAlreadyInAnki;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (snapshot.hasError) {
      return _Message(
        l10n.lookupFailedMessage(snapshot.error?.toString() ?? ''),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    }
    if (snapshot.connectionState != ConnectionState.done) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final result = snapshot.data;
    if (result == null) {
      return _Message(l10n.lookupNoWordMessage, icon: Icons.search_off_rounded);
    }
    return _ResultView(
      result: result,
      onAddToAnki: onAddToAnki,
      isAlreadyInAnki: isAlreadyInAnki,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text, {this.icon, this.isError = false});

  final String text;
  final IconData? icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isError
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: color,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The matched text and reading, followed by its dictionary entries.
class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    this.onAddToAnki,
    this.isAlreadyInAnki,
  });

  final LookupResult result;
  final AddToAnkiCallback? onAddToAnki;
  final Future<bool> Function(String word)? isAlreadyInAnki;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final reading = result.reading;
    // Save to recent lookups history
    LookupHistory.instance.add(
      LookupRecord(
        word: result.matchedText,
        reading: reading ?? '',
        gloss: result.entries.isNotEmpty
            ? result.entries.first.senses.first.glosses.join(', ')
            : '',
        createdAt: DateTime.now(),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.matchedText,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                    ),
                  ),
                  if (reading != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      reading,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onAddToAnki != null) ...[
              const SizedBox(width: 12),
              _AnkiAddButton(
                result: result,
                onAddToAnki: onAddToAnki!,
                isAlreadyInAnki: isAlreadyInAnki,
              ),
            ],
            IconButton(
              icon: const Icon(Icons.volume_up_outlined),
              onPressed: () {
                TtsService.instance.speak(result.pronunciationText);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (result.isEmpty)
          _Message(
            l10n.lookupNoEntryMessage(result.matchedText),
            icon: Icons.menu_book_outlined,
          )
        else
          for (final entry in result.entries) ...[
            _EntryView(entry: entry),
            const SizedBox(height: 12),
          ],
        const SizedBox(height: 8),
      ],
    );
  }
}

class _AnkiAddButton extends StatefulWidget {
  const _AnkiAddButton({
    required this.result,
    required this.onAddToAnki,
    this.isAlreadyInAnki,
  });

  final LookupResult result;
  final AddToAnkiCallback onAddToAnki;
  final Future<bool> Function(String word)? isAlreadyInAnki;

  @override
  State<_AnkiAddButton> createState() => _AnkiAddButtonState();
}

class _AnkiAddButtonState extends State<_AnkiAddButton> {
  late final Future<bool>? _duplicateCheck = widget.isAlreadyInAnki?.call(
    widget.result.matchedText,
  );

  @override
  Widget build(BuildContext context) {
    final duplicateCheck = _duplicateCheck;
    if (duplicateCheck == null) return _buildButton(context);

    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<bool>(
      future: duplicateCheck,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _buildButton(context, label: l10n.ankiAddChecking);
        }
        if (snapshot.data == true) {
          return _buildButton(
            context,
            alreadyAdded: true,
            label: l10n.ankiAddAlreadyAdded,
          );
        }
        return _buildButton(context, label: l10n.ankiAddAction);
      },
    );
  }

  Widget _buildButton(
    BuildContext context, {
    String? label,
    bool alreadyAdded = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isChecking = label == l10n.ankiAddChecking;
    final canAdd = !alreadyAdded && !isChecking;
    final onPressed = canAdd
        ? () {
            widget.onAddToAnki(widget.result);
            Navigator.of(context).pop();
          }
        : null;
    final icon = isChecking
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(alreadyAdded ? Icons.check_rounded : Icons.add_rounded);
    final text = Text(label ?? l10n.ankiAddAction, maxLines: 1);

    // Primary action when the card can be added, quiet tonal otherwise.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: canAdd
          ? FilledButton.icon(
              key: const ValueKey('add'),
              onPressed: onPressed,
              icon: icon,
              label: text,
            )
          : FilledButton.tonalIcon(
              key: ValueKey(alreadyAdded ? 'added' : 'checking'),
              onPressed: onPressed,
              icon: icon,
              label: text,
            ),
    );
  }
}

class _EntryView extends StatelessWidget {
  const _EntryView({required this.entry});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final otherForms = entry.kanji.skip(1);
    final readings = entry.readings.where((r) => r != entry.headword);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                entry.headword,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (entry.common) const _CommonChip(),
            ],
          ),
          if (otherForms.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(otherForms.join('、'), style: muted),
          ],
          if (readings.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(readings.join('、'), style: muted),
          ],
          const SizedBox(height: 12),
          for (final (index, sense) in entry.senses.indexed)
            _SenseView(number: index + 1, sense: sense),
        ],
      ),
    );
  }
}

class _CommonChip extends StatelessWidget {
  const _CommonChip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Chip(
      label: const Text('common'),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      backgroundColor: scheme.primaryContainer,
      labelStyle: Theme.of(context).textTheme.labelSmall
          ?.copyWith(color: scheme.onPrimaryContainer),
    );
  }
}

class _SenseView extends StatelessWidget {
  const _SenseView({required this.number, required this.sense});

  final int number;
  final Sense sense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 12, top: 1),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.secondaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: theme.textTheme.labelSmall?.copyWith(
                color: scheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sense.pos.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      sense.pos.join(', '),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                Text(
                  sense.glosses.join('; '),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
