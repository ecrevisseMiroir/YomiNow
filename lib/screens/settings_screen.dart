import 'package:flutter/material.dart';

import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const items = [
      _SettingsItem(
        icon: Icons.document_scanner_outlined,
        title: 'OCR Settings',
        subtitle: 'Tesseract / ML Kit',
      ),
      _SettingsItem(
        icon: Icons.menu_book_outlined,
        title: 'Dictionary',
        subtitle: 'JMdict (offline)',
      ),
      _SettingsItem(
        icon: Icons.light_mode_outlined,
        title: 'Appearance',
        subtitle: 'System theme',
      ),
      _SettingsItem(
        icon: Icons.language_outlined,
        title: 'Language',
        subtitle: 'English',
      ),
      _SettingsItem(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'Version 0.1.0',
      ),
    ];

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Settings')),
      bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 2),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 64,
          color: YomiNowPalette.indigo.withValues(alpha: 0.12),
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            leading: Icon(item.icon, size: 30, color: YomiNowPalette.ink),
            title: Text(
              item.title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: YomiNowPalette.ink,
              ),
            ),
            subtitle: Text(
              item.subtitle,
              style: TextStyle(
                fontFamily: 'Inter',
                color: YomiNowPalette.ink.withValues(alpha: 0.65),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
