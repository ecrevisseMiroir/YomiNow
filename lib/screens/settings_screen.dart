import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

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
      _SettingsItem(
        icon: Icons.document_scanner_outlined,
        title: AppLocalizations.of(context)!.settingsScreenOCRTitle,
        subtitle: AppLocalizations.of(context)!.settingsScreenOCRSubtitle,
      ),
      _SettingsItem(
        icon: Icons.menu_book_outlined,
        title: AppLocalizations.of(context)!.settingsScreenDictionaryTitle,
        subtitle: AppLocalizations.of(context)!.settingsScreenDictionarySubtitle,
      ),
      _SettingsItem(
        icon: Icons.light_mode_outlined,
        title: AppLocalizations.of(context)!.settingsScreenAppearanceTitle,
        subtitle: AppLocalizations.of(context)!.settingsScreenAppearanceSubtitle,
      ),
      _SettingsItem(
        icon: Icons.language_outlined,
        title: AppLocalizations.of(context)!.settingsScreenLanguageTitle,
        subtitle: _selectedLanguage,
        isAction: true,
      ),
      _SettingsItem(
        icon: Icons.info_outline,
        title: AppLocalizations.of(context)!.settingsScreenAboutTitle,
        subtitle: '${AppLocalizations.of(context)!.settingsScreenVersionLabel} $_appVersion',
        route: '/about',
      ),
    ];
  }

  void _showLanguagePicker() {
    final options = ['English', 'Français', '日本語'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: YomiNowPalette.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
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
                    color: YomiNowPalette.ink,
                    letterSpacing: -0.8,
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
                        color: YomiNowPalette.ink,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            Icons.check_rounded,
                            color: YomiNowPalette.indigo,
                          )
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

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();

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
                        AppLocalizations.of(context)!.settingsScreenTitle,
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
                            ? (item.isAction ? _showLanguagePicker : null)
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
                              if (item.route != null || item.isAction)
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
    this.isAction = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? route;
  final bool isAction;
}
