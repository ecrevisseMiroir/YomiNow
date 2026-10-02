import 'package:flutter/material.dart';

import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        subtitle: 'Light theme',
      ),
      _SettingsItem(
        icon: Icons.language_outlined,
        title: 'Language',
        subtitle: 'English',
      ),
      _SettingsItem(
        icon: Icons.info_outline,
        title: 'About',
        subtitle: 'Version 1.0.0',
        route: '/about',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 2),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/04_scenery_backgrounds/background.png'),
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 18,
              top: 8,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 30,
                      ),
                      color: YomiNowPalette.ink,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          color: YomiNowPalette.ink,
                          letterSpacing: -1.2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(top: 8, bottom: 12),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return InkWell(
                        onTap: item.route == null
                            ? null
                            : () =>
                                  Navigator.of(context).pushNamed(item.route!),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border: Border.all(
                                    color: YomiNowPalette.indigo.withValues(
                                      alpha: 0.8,
                                    ),
                                    width: 3,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  item.icon,
                                  size: 28,
                                  color: YomiNowPalette.indigo,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 28,
                                        fontWeight: FontWeight.w500,
                                        color: YomiNowPalette.ink,
                                        letterSpacing: -0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        color: YomiNowPalette.ink.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                size: 30,
                                color: YomiNowPalette.ink.withValues(
                                  alpha: 0.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
}
