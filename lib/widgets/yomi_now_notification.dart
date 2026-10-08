import 'dart:async';

import 'package:flutter/material.dart';

import '../services/yomi_now_notification_history.dart';

abstract final class YomiNowNotification {
  static IconData iconFor(YomiNowNotificationKind kind) => switch (kind) {
    YomiNowNotificationKind.success => Icons.check_circle_rounded,
    YomiNowNotificationKind.info => Icons.info_rounded,
    YomiNowNotificationKind.error => Icons.error_rounded,
  };

  static Color accentFor(
    YomiNowNotificationKind kind,
    ColorScheme colorScheme,
  ) => switch (kind) {
    YomiNowNotificationKind.success =>
      colorScheme.brightness == Brightness.dark
          ? const Color(0xFF8BD5A1)
          : const Color(0xFF287A45),
    YomiNowNotificationKind.info => colorScheme.primary,
    YomiNowNotificationKind.error => colorScheme.error,
  };

  static void show(
    BuildContext context, {
    required String title,
    required String message,
    required YomiNowNotificationKind kind,
  }) {
    unawaited(
      YomiNowNotificationHistory.instance.add(
        title: title,
        message: message,
        kind: kind,
      ),
    );
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final icon = iconFor(kind);
    final accent = accentFor(kind, colorScheme);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Semantics(
            liveRegion: true,
            child: Row(
              children: [
                Icon(icon, color: accent, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const ValueKey('yomi-notification-dismiss'),
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  visualDensity: VisualDensity.compact,
                  onPressed: messenger.hideCurrentSnackBar,
                  icon: Icon(
                    Icons.close_rounded,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: colorScheme.surfaceContainerHigh,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      );
  }
}
