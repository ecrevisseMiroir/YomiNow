import 'package:flutter/material.dart';

import '../models/dictionary_entry.dart';
import '../models/lookup_result.dart';

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
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.5,
      minChildSize: 0.25,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Material(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 24),
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
        width: 32,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          'Dictionary data: JMdict © EDRDG, CC BY-SA 4.0',
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Picks what the sheet shows for the state of the lookup future.
class _SheetBody extends StatelessWidget {
  const _SheetBody({
    super.key,
    required this.snapshot,
    this.onAddToAnki,
    this.isAlreadyInAnki,
  });

  final AsyncSnapshot<LookupResult?> snapshot;
  final AddToAnkiCallback? onAddToAnki;
  final Future<bool> Function(String word)? isAlreadyInAnki;

  @override
  Widget build(BuildContext context) {
    if (snapshot.hasError) {
      return _Message('Lookup failed: ${snapshot.error}');
    }
    if (snapshot.connectionState != ConnectionState.done) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final result = snapshot.data;
    if (result == null) return const _Message('No word to look up here.');
    return _ResultView(
      result: result,
      onAddToAnki: onAddToAnki,
      isAlreadyInAnki: isAlreadyInAnki,
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        text,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
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
    final muted = TextStyle(color: theme.colorScheme.onSurfaceVariant);
    final reading = result.reading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.matchedText,
                    style: theme.textTheme.headlineLarge,
                  ),
                  if (reading != null)
                    Text(
                      reading,
                      style: theme.textTheme.titleMedium?.merge(muted),
                    ),
                ],
              ),
            ),
            if (onAddToAnki != null)
              _AnkiAddButton(
                result: result,
                onAddToAnki: onAddToAnki!,
                isAlreadyInAnki: isAlreadyInAnki,
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (result.isEmpty)
          _Message('No dictionary entry for 「${result.matchedText}」')
        else
          for (final entry in result.entries) ...[
            const Divider(),
            _EntryView(entry: entry),
          ],
        const SizedBox(height: 16),
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
    return ElevatedButton.icon(
      onPressed: canAdd
          ? () {
              widget.onAddToAnki(widget.result);
              Navigator.of(context).pop();
            }
          : null,
      icon: isChecking
          ? const Icon(Icons.hourglass_empty)
          : Icon(alreadyAdded ? Icons.check_rounded : Icons.add),
      label: Text(label ?? l10n.ankiAddAction, maxLines: 1),
    );
  }
}

class _EntryView extends StatelessWidget {
  const _EntryView({required this.entry});

  final DictionaryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final otherForms = entry.kanji.skip(1);
    final readings = entry.readings.where((r) => r != entry.headword);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
          if (otherForms.isNotEmpty) Text(otherForms.join('、'), style: muted),
          if (readings.isNotEmpty) Text(readings.join('、'), style: muted),
          const SizedBox(height: 8),
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
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Text('$number.', style: TextStyle(color: muted)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sense.pos.isNotEmpty)
                  Text(
                    sense.pos.join(', '),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: muted,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                Text(
                  sense.glosses.join('; '),
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
