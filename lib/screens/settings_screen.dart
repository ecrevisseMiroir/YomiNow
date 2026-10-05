import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../services/app_appearance.dart';
import '../services/app_language.dart';
import '../theme/yomi_now_theme.dart';

import 'package:yominow/l10n/app_localizations.dart';

import '../widgets/yomi_now_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '0.0.0';

  String get _selectedLanguage => AppLanguage.selected.value;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = packageInfo.version);
  }

  List<_SettingsItem> _buildItems() {
    return [
      // TODO: Replace the beta placeholder with a real OCR settings picker.
      _SettingsItem(
        icon: Icons.document_scanner_outlined,
        title: AppLocalizations.of(context)!.settingsScreenOCRTitle,
        subtitle: AppLocalizations.of(context)!.settingsScreenOCRSubtitle,
      ),
      // TODO: Add dictionary selection flow with saved preference and custom source handling.
      _SettingsItem(
        icon: Icons.menu_book_outlined,
        title: AppLocalizations.of(context)!.settingsScreenDictionaryTitle,
        subtitle: AppLocalizations.of(context)!.settingsScreenDictionarySubtitle,
      ),
      _SettingsItem(
        icon: Icons.light_mode_outlined,
        title: AppLocalizations.of(context)!.settingsScreenAppearanceTitle,
        subtitle: _appearanceLabel(AppAppearance.selected.value),
        action: _SettingsAction.appearance,
      ),
      _SettingsItem(
        icon: Icons.language_outlined,
        title: AppLocalizations.of(context)!.settingsScreenLanguageTitle,
        subtitle: _selectedLanguage,
        action: _SettingsAction.language,
      ),
      _SettingsItem(
        icon: Icons.info_outline,
        title: AppLocalizations.of(context)!.settingsScreenAboutTitle,
        subtitle:
            '${AppLocalizations.of(context)!.settingsScreenVersionLabel} $_appVersion',
        route: '/about',
      ),
    ];
  }

  String _appearanceLabel(ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    return switch (mode) {
      ThemeMode.system => l10n.settingsScreenThemeSystem,
      ThemeMode.light => l10n.settingsScreenThemeLight,
      ThemeMode.dark => l10n.settingsScreenThemeDark,
    };
  }

  void _showAppearancePicker() {
    final l10n = AppLocalizations.of(context)!;
    final options = <({ThemeMode mode, String label})>[
      (mode: ThemeMode.system, label: l10n.settingsScreenThemeSystem),
      (mode: ThemeMode.light, label: l10n.settingsScreenThemeLight),
      (mode: ThemeMode.dark, label: l10n.settingsScreenThemeDark),
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.settingsScreenAppearanceTitle,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  final isSelected =
                      option.mode == AppAppearance.selected.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(option.label),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: theme.colorScheme.primary,
                          )
                        : null,
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await AppAppearance.setThemeMode(option.mode);
                      if (!mounted) return;
                      navigator.pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguagePicker() {
    final options = ['English', 'Français', '日本語'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.settingsScreenChooseLanguage,
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                ...options.map((option) {
                  final isSelected = option == _selectedLanguage;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      option,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_rounded, color: colorScheme.primary)
                        : null,
                    onTap: () async {
                      final navigator = Navigator.of(context);
                      await AppLanguage.setLanguage(option);
                      if (!mounted) return;
                      navigator.pop();
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleItemTap(_SettingsItem item) {
    if (item.route != null) {
      Navigator.of(context).pushNamed(item.route!);
      return;
    }

    switch (item.action) {
      case _SettingsAction.appearance:
        _showAppearancePicker();
      case _SettingsAction.language:
        _showLanguagePicker();
      case null:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.settingsScreenFeatureComingSoon,
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    final colorScheme = Theme.of(context).colorScheme;

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
                      color: colorScheme.onSurface,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)!.settingsScreenTitle,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 35,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
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
                        onTap: () => _handleItemTap(item),
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
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 18,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (item.route != null || item.action != null)
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 30,
                                  color: colorScheme.onSurfaceVariant,
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

enum _SettingsAction { appearance, language }

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.route,
    this.action,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final _SettingsAction? action;
}
