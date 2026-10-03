import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/yomi_now_theme.dart';

class YomiNowBottomNav extends StatelessWidget {
  const YomiNowBottomNav({super.key, this.selectedIndex = 0});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = [
      _BottomNavItem(icon: LucideIcons.home, label: 'Home', link: '/home'),
      _BottomNavItem(
        icon: LucideIcons.fileText,
        label: 'Documents',
        link: '/documents',
      ),
      _BottomNavItem(
        icon: LucideIcons.settings,
        label: 'Settings',
        link: '/settings',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (int i = 0; i < items.length; i++) ...[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (items[i].link != null) {
                      // Navigate to the specified link
                      Navigator.pushNamed(context, items[i].link!);
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[i].icon,
                        size: 30,
                        color: i == selectedIndex
                            ? YomiNowPalette.coral
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: i == selectedIndex
                              ? YomiNowPalette.coral
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem {
  const _BottomNavItem({required this.icon, required this.label, this.link});

  final IconData icon;
  final String label;
  final String? link;
}
