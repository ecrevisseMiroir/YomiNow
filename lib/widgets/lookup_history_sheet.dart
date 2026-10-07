import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yominow/services/anki_droid_service.dart';
import 'package:yominow/services/yomi_now_notification_history.dart';
import 'package:yominow/widgets/yomi_now_notification.dart';

import '../services/lookup_history.dart';

import 'package:yominow/l10n/app_localizations.dart';

/// Bottom sheet listing recent dictionary lookups.
///
/// Show it with:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   useSafeArea: true,
///   backgroundColor: Colors.transparent,
///   builder: (_) => const LookupHistorySheet(),
/// );
/// ```
class LookupHistorySheet extends StatefulWidget {
  const LookupHistorySheet({super.key});

  @override
  State<LookupHistorySheet> createState() => _LookupHistorySheetState();
}

class _LookupHistorySheetState extends State<LookupHistorySheet> {
  // Created once so rebuilds don't re-trigger load().
  late final Future<void> _loadFuture = _load();

  // Words that are already in Anki.
  final Set<String> _added = {};

  final AnkiDroidService? _anki =
      defaultTargetPlatform == TargetPlatform.android
      ? AnkiDroidService()
      : null;

  final Set<String> _adding = {};

  Future<void> _addToAnki(LookupRecord r) async {
    final anki = _anki;
    if (anki == null || _adding.contains(r.word)) return;

    final l10n = AppLocalizations.of(context)!;

    HapticFeedback.lightImpact();

    setState(() => _adding.add(r.word));

    try {
      final result = await anki.addNote(word: r.word, back: r.gloss);

      if (!mounted) return;

      switch (result) {
        case AnkiDroidAddResult.added:
          setState(() => _added.add(r.word));

          YomiNowNotification.show(
            context,
            title: l10n.ankiNotificationAddedTitle,
            message: l10n.ankiNotificationAddedMessage(r.word),
            kind: YomiNowNotificationKind.success,
          );

        case AnkiDroidAddResult.duplicate:
          setState(() => _added.add(r.word));

          YomiNowNotification.show(
            context,
            title: l10n.ankiNotificationDuplicateTitle,
            message: l10n.ankiNotificationDuplicateMessage(r.word),
            kind: YomiNowNotificationKind.error,
          );

        case AnkiDroidAddResult.shared:
          // AnkiDroid opened for the user to confirm; not added yet.
          break;
      }
    } catch (_) {
      if (!mounted) return;

      YomiNowNotification.show(
        context,
        title: l10n.ankiNotificationFailedTitle,
        message: l10n.ankiNotificationFailedMessage,
        kind: YomiNowNotificationKind.error,
      );
    } finally {
      if (mounted) {
        setState(() => _adding.remove(r.word));
      }
    }
  }

  Future<void> _checkExistingAnkiWords() async {
    final anki = _anki;
    if (anki == null) return;

    final records = LookupHistory.instance.records;

    for (final record in records) {
      try {
        final exists = await anki.isDuplicate(record.word);

        if (exists && mounted) {
          setState(() {
            _added.add(record.word);
          });
        }
      } catch (_) {
        // Ignore individual lookup errors.
      }
    }
  }

  Future<void> _load() async {
    await LookupHistory.instance.load();
    await _checkExistingAnkiWords();
  }

  void _copy(LookupRecord r) {
    final l10n = AppLocalizations.of(context)!;

    Clipboard.setData(ClipboardData(text: r.word));

    HapticFeedback.selectionClick();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(l10n.lookupHistoryCopied(r.word)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: scheme.surfaceContainerLow,
          elevation: 3,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          clipBehavior: Clip.antiAlias,
          child: FutureBuilder<void>(
            future: _loadFuture,
            builder: (context, snapshot) {
              final loading = snapshot.connectionState != ConnectionState.done;

              // Rebuilds live when a new lookup is added elsewhere.
              return ListenableBuilder(
                listenable: LookupHistory.instance,
                builder: (context, _) {
                  final records = LookupHistory.instance.records;

                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(count: loading ? null : records.length),
                      ),

                      if (loading)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (records.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            12,
                            0,
                            12,
                            24 + MediaQuery.of(context).padding.bottom,
                          ),
                          sliver: SliverList.separated(
                            itemCount: records.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final r = records[i];

                              return _LookupTile(
                                record: r,
                                added: _added.contains(r.word),
                                onAdd: () => _addToAnki(r),
                                onCopy: () => _copy(r),
                              );
                            },
                          ),
                        ),
                    ],
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int? count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        const SizedBox(height: 12),

        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: scheme.onSurfaceVariant.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(l10n.lookupHistoryTitle, style: theme.textTheme.titleLarge),
              const Spacer(),
              if (count != null && count! > 0)
                Text(
                  '$count',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LookupTile extends StatelessWidget {
  const _LookupTile({
    required this.record,
    required this.added,
    required this.onAdd,
    required this.onCopy,
  });

  final LookupRecord record;
  final bool added;
  final VoidCallback onAdd;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final showReading =
        record.reading.isNotEmpty && record.reading != record.word;

    return Material(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onLongPress: onCopy,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            record.word,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        if (showReading) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              record.reading,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      record.gloss,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _relativeTime(record.createdAt, l10n),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              IconButton.filledTonal(
                tooltip: added
                    ? l10n.lookupHistoryTooltipAddedToAnki
                    : l10n.lookupHistoryTooltipAddToAnki,
                onPressed: added ? null : onAdd,
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    added ? Icons.library_add_check : Icons.note_add_outlined,
                    key: ValueKey(added),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: scheme.onSurfaceVariant),

          const SizedBox(height: 12),

          Text(
            l10n.lookupHistoryEmptyTitle,
            style: theme.textTheme.titleMedium,
          ),

          const SizedBox(height: 4),

          Text(
            l10n.lookupHistoryEmptySubtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime t, AppLocalizations l10n) {
  final diff = DateTime.now().difference(t);

  if (diff.inMinutes < 1) {
    return l10n.lookupHistoryJustNow;
  }

  if (diff.inMinutes < 60) {
    return l10n.lookupHistoryMinutesAgo(diff.inMinutes);
  }

  if (diff.inHours < 24) {
    final h = diff.inHours;
    return l10n.lookupHistoryHoursAgo(h);
  }

  if (diff.inDays < 7) {
    final d = diff.inDays;
    return l10n.lookupHistoryDaysAgo(d);
  }

  return '${t.year}-${t.month.toString().padLeft(2, '0')}-${t.day.toString().padLeft(2, '0')}';
}
