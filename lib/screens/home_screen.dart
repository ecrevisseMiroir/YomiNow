import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/yomi_now_theme.dart';
import '../models/scanned_document.dart';
import '../services/app_route_observer.dart';
import '../services/app_services.dart';
import '../services/yomi_now_notification_history.dart';

import 'package:yominow/l10n/app_localizations.dart';

import '../widgets/yomi_now_bottom_nav.dart';
import '../widgets/error_dialog.dart';
import '../widgets/yomi_now_notification_history_sheet.dart';
import 'camera_scanner.dart';
import 'image_screen.dart';

/// The start screen: pick or take a photo of Japanese text.
///
/// Phones offer the camera and the gallery; desktops open a file dialog.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.picker});

  /// The image picker to use; defaults to a real [ImagePicker].
  final ImagePicker? picker;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  List<ScannedDocument> _recentScans = <ScannedDocument>[];
  bool _isLoadingScans = true;
  bool _didLoadScans = false;
  bool _didSubscribeToRoute = false;

  @override
  void initState() {
    super.initState();
    unawaited(YomiNowNotificationHistory.instance.load());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didSubscribeToRoute) {
      final route = ModalRoute.of<dynamic>(context);
      if (route != null) {
        appRouteObserver.subscribe(this, route);
        _didSubscribeToRoute = true;
      }
    }
    if (!_didLoadScans) {
      _didLoadScans = true;
      unawaited(_loadRecentScans());
    }
  }

  @override
  void didPopNext() => unawaited(_loadRecentScans());

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadRecentScans() async {
    try {
      final documents = await AppServicesScope.of(context).documents.getAll();
      if (!mounted) return;
      setState(() {
        _recentScans = documents.take(2).toList();
        _isLoadingScans = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingScans = false);
    }
  }

  Future<void> _pick(ImageSource source) async {
    try {
      final XFile? file;
      if (source == ImageSource.camera &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS) &&
          widget.picker == null) {
        file = await Navigator.of(
          context,
        ).push<XFile>(MaterialPageRoute(builder: (_) => const CameraScanner()));
      } else {
        file = await _picker.pickImage(source: source);
      }
      if (file == null || !mounted) return;

      final repository = AppServicesScope.of(context).documents;
      final document = await repository.addImage(file);
      if (!mounted) return;
      setState(() {
        _recentScans = [
          document,
          ..._recentScans.where((item) => item.id != document.id),
        ].take(2).toList();
        _isLoadingScans = false;
      });

      final hasText = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ImageScreen(imagePath: document.path),
        ),
      );
      if (!mounted) return;
      if (hasText != null) {
        await repository.updateHasText(document.id, hasText);
      }
      await _loadRecentScans();
    } catch (_) {
      if (mounted) await YomiNowErrorDialog.show(context);
    }
  }

  Future<void> _openRecentScan(ScannedDocument document) async {
    final repository = AppServicesScope.of(context).documents;
    final hasText = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => ImageScreen(imagePath: document.path),
      ),
    );
    if (!mounted || hasText == null) return;
    await repository.updateHasText(document.id, hasText);
    await _loadRecentScans();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: _buildHeaderBar(context),
      bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final maxWidth = isLandscape
                ? constraints.maxWidth
                : constraints.maxWidth > 480
                ? 430.0
                : constraints.maxWidth;
            final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 22.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 12,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 4),
                        const SizedBox(height: 18),
                        _buildWelcomeText(),
                        const SizedBox(height: 22),
                        if (isMobile) ...[
                          _buildActionTile(
                            backgroundColor: YomiNowPalette.coral,
                            icon: LucideIcons.camera,
                            title: AppLocalizations.of(context)!
                                .homeScreenTitleTakePhoto,
                            subtitle: '',
                            textColor: YomiNowPalette.cream,
                            iconColor: YomiNowPalette.cream,
                            onTap: () => _pick(ImageSource.camera),
                          ),
                          const SizedBox(height: 12),
                          _buildActionTile(
                            backgroundColor: YomiNowPalette.softBlue,
                            icon: LucideIcons.image,
                            title: AppLocalizations.of(context)!
                                .homeScreenTitleChooseFromGallery,
                            subtitle: '',
                            textColor: YomiNowPalette.ink,
                            iconColor: YomiNowPalette.indigo,
                            onTap: () => _pick(ImageSource.gallery),
                          ),
                        ] else
                          _buildActionTile(
                            backgroundColor: YomiNowPalette.coral,
                            icon: LucideIcons.folderOpen,
                            title: AppLocalizations.of(context)!
                                .homeScreenTitleOpenImage,
                            subtitle: '',
                            textColor: YomiNowPalette.ink,
                            iconColor: YomiNowPalette.ink,
                            onTap: () => _pick(ImageSource.gallery),
                          ),
                        const SizedBox(height: 28),
                        _buildRecentScansHeader(),
                        const SizedBox(height: 12),
                        _buildRecentScansGrid(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.homeScreenGreeting,
          style: TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 36,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.homeScreenSubtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            height: 1.4,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required Color backgroundColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color textColor = YomiNowPalette.ink,
    Color iconColor = YomiNowPalette.ink,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 108),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(96),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: LayoutBuilder(
                builder: (context, textConstraints) {
                  final compact = textConstraints.maxWidth < 180;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: compact ? 20 : 24,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                          height: 1.15,
                        ),
                      ),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: compact ? 14 : 16,
                            color: textColor.withValues(alpha: 0.7),
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScansHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppLocalizations.of(context)!.homeScreenRecentScans,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed('/documents'),
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocalizations.of(context)!.homeScreenSeeAll,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScansGrid() {
    if (_isLoadingScans) {
      return const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_recentScans.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Text(
          AppLocalizations.of(context)!.homeScreenNoRecentScans,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = _recentScans.length == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - 18) / 2;
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              for (int i = 0; i < _recentScans.length; i++) ...[
                if (i > 0) const SizedBox(width: 18),
                Expanded(
                  child: SizedBox(
                    width: cardWidth,
                    child: _ScanCard(
                      document: _recentScans[i],
                      onTap: () => _openRecentScan(_recentScans[i]),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

PreferredSizeWidget _buildHeaderBar(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return AppBar(
    automaticallyImplyLeading: false,
    backgroundColor: colorScheme.surface,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    leading: Tooltip(
      message: AppLocalizations.of(context)!.homeScreenSettingsTooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => Navigator.pushNamed(context, '/settings'),
        child: Icon(
          LucideIcons.settings,
          size: 28,
          color: YomiNowPalette.indigo.withValues(alpha: 0.8),
        ),
      ),
    ),
    title: Text(
      AppLocalizations.of(context)!.appName,
      style: TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 35,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
        letterSpacing: -1.4,
      ),
    ),
    actions: [
      Tooltip(
        message: AppLocalizations.of(context)!.homeScreenNotificationsTooltip,
        child: AnimatedBuilder(
          animation: YomiNowNotificationHistory.instance,
          builder: (context, _) {
            final unreadCount = YomiNowNotificationHistory.instance.unreadCount;
            return Semantics(
              button: true,
              label: AppLocalizations.of(context)!
                  .homeScreenNotificationsTooltip,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => unawaited(showYomiNowNotificationHistory(context)),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Badge(
                    isLabelVisible: unreadCount > 0,
                    label: Text(unreadCount > 99 ? '99+' : '$unreadCount'),
                    backgroundColor: YomiNowPalette.coral,
                    textColor: YomiNowPalette.ink,
                    child: Image.asset(
                      Theme.of(context).brightness == Brightness.dark
                          ? 'assets/03_characters_mascot/cat_notification_dark_mode_icon.png'
                          : 'assets/03_characters_mascot/cat_notification_light_mode_icon.png',
                      width: 32,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      const SizedBox(width: 8),
    ],
  );
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.document, required this.onTap});

  final ScannedDocument document;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final date = document.createdAt;
    final subtitle = '${_monthName(date.month)} ${date.day}, ${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 150,
              width: double.infinity,
              child: Image.file(
                File(document.path),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: YomiNowPalette.softBlue,
                  child: Icon(
                    Icons.image_outlined,
                    size: 44,
                    color: YomiNowPalette.indigo.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            document.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'NotoSansJP',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

String _monthName(int month) => const [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month - 1];
