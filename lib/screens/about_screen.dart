import 'package:flutter/material.dart';

import 'package:yominow/l10n/app_localizations.dart';
import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _AboutItem(
        icon: Icons.description_outlined,
        title: AppLocalizations.of(context)!.aboutScreenLicenses,
        route: '/licenses',
      ),
      _AboutItem(
        icon: Icons.library_books_outlined,
        title: AppLocalizations.of(context)!.aboutScreenThirdPartyLibraries,
        route: '/third-party-libraries',
      ),
      _AboutItem(
        icon: Icons.code_outlined,
        title: AppLocalizations.of(context)!.aboutScreenOpenSource,
        route: '/open-source',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final topSpacing = isLandscape ? 8.0 : 18.0;
        final logoSize = isLandscape ? 120.0 : 180.0;
        final brandSize = isLandscape ? 35.0 : 40.0;
        final subtitleSize = isLandscape ? 18.0 : 22.0;
        final bodyTextSize = isLandscape ? 16.0 : 20.0;
        final rowIconSize = isLandscape ? 22.0 : 28.0;
        final rowTextSize = isLandscape ? 20.0 : 28.0;
        final listSpacing = isLandscape ? 8.0 : 12.0;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 0),
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              AppLocalizations.of(context)!.aboutScreenTitle,
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 35,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: YomiNowPalette.ink,
                                letterSpacing: -2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: topSpacing),
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(38),
                          child: Image.asset(
                            'assets/02_brand_logo/logo_about.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Text(
                        'YomiNow',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: brandSize,
                          fontWeight: FontWeight.w600,
                          color: YomiNowPalette.ink,
                          height: 1,
                          letterSpacing: -3.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.aboutScreenSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: subtitleSize,
                          fontWeight: FontWeight.w500,
                          color: YomiNowPalette.ink.withValues(alpha: 0.8),
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        AppLocalizations.of(context)!.aboutScreenDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: bodyTextSize,
                          height: 1.25,
                          color: YomiNowPalette.ink.withValues(alpha: 0.86),
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Image.asset(
                          'assets/04_scenery_backgrounds/about-background.png',
                          width: isLandscape
                              ? constraints.maxWidth
                              : constraints.maxWidth * 0.9,
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            SizedBox(height: listSpacing),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () =>
                                Navigator.of(context).pushNamed(item.route!),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
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
                                      size: rowIconSize,
                                      color: YomiNowPalette.indigo,
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Text(
                                      item.title,
                                      style: TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: rowTextSize,
                                        fontWeight: FontWeight.w500,
                                        color: YomiNowPalette.ink,
                                        letterSpacing: -0.8,
                                      ),
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
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 2),
        );
      },
    );
  }
}

class _AboutItem {
  const _AboutItem({required this.icon, required this.title, this.route});

  final IconData icon;
  final String title;
  final String? route;
}
