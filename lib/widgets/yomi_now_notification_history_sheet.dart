import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yominow/l10n/app_localizations.dart';

import '../services/yomi_now_notification_history.dart';
import 'yomi_now_notification.dart';

Future<void> showYomiNowNotificationHistory(BuildContext context) async {
  final history = YomiNowNotificationHistory.instance;
  await history.load();
  if (!context.mounted) return;
  await history.markAllRead();
  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.94,
      builder: (context, scrollController) => _NotificationHistorySheet(
        history: history,
        scrollController: scrollController,
      ),
    ),
  );
}

class _NotificationHistorySheet extends StatelessWidget {
  const _NotificationHistorySheet({
    required this.history,
    required this.scrollController,
  });

  final YomiNowNotificationHistory history;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: 34,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.notificationHistoryTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontFamily: 'Fredoka',
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: history,
                    builder: (context, _) => history.records.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            key: const ValueKey('notification-history-clear'),
                            tooltip: l10n.notificationHistoryClearTooltip,
                            onPressed: () => unawaited(history.clear()),
                            icon: const Icon(Icons.delete_sweep_outlined),
                          ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: AnimatedBuilder(
                animation: history,
                builder: (context, _) {
                  final records = history.records;
                  if (records.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none_rounded,
                            size: 42,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.notificationHistoryEmpty,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(color: colorScheme.onSurface),
                          ),
                        ],
                      ),
                    );
                  }

                  final materialLocalizations = MaterialLocalizations.of(
                    context,
                  );
                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: records.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: colorScheme.outlineVariant),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final timestamp =
                          '${materialLocalizations.formatShortDate(record.createdAt)}, '
                          '${materialLocalizations.formatTimeOfDay(TimeOfDay.fromDateTime(record.createdAt))}';
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        leading: Icon(
                          YomiNowNotification.iconFor(record.kind),
                          color: YomiNowNotification.accentFor(
                            record.kind,
                            colorScheme,
                          ),
                        ),
                        title: Text(
                          record.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: record.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                record.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timestamp,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
