import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();

  Future<void> _pick(ImageSource source) async {
    final XFile? file;
    try {
      file = await _picker.pickImage(source: source);
    } on Exception catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not pick an image: $error')),
      );
      return;
    }
    if (file == null || !mounted) return;
    final path = file.path;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => ImageScreen(imagePath: path)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 0),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth > 480
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
                        _buildHeaderRow(),
                        const SizedBox(height: 18),
                        _buildWelcomeText(),
                        const SizedBox(height: 22),
                        if (isMobile) ...[
                          _buildActionTile(
                            backgroundColor: YomiNowPalette.coral,
                            icon: LucideIcons.camera,
                            title: 'Scan with Camera',
                            subtitle: 'Take a photo',
                            textColor: YomiNowPalette.cream,
                            iconColor: YomiNowPalette.cream,
                            onTap: () => _pick(ImageSource.camera),
                          ),
                          const SizedBox(height: 12),
                          _buildActionTile(
                            backgroundColor: YomiNowPalette.softBlue,
                            icon: LucideIcons.image,
                            title: 'Choose from Gallery',
                            subtitle: 'Pick an image',
                            textColor: YomiNowPalette.ink,
                            iconColor: YomiNowPalette.indigo,
                            onTap: () => _pick(ImageSource.gallery),
                          ),
                        ] else
                          _buildActionTile(
                            backgroundColor: YomiNowPalette.coral,
                            icon: LucideIcons.folderOpen,
                            title: 'Open image',
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

  Widget _buildHeaderRow() {
    return Row(
      children: [
        SizedBox(
          width: 44,
          height: 44,
          child: Tooltip(
            message: 'Settings',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.pushNamed(context, '/settings');
                },
                child: Center(
                  child: Icon(
                    LucideIcons.settings,
                    size: 28,
                    color: YomiNowPalette.indigo.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'YomiNow',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 35,
              fontWeight: FontWeight.w600,
              color: YomiNowPalette.ink,
              letterSpacing: -1.4,
            ),
          ),
        ),
        SizedBox(
          width: 44,
          height: 44,
          child: Tooltip(
            message: 'Notifications',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
                child: Center(
                  child: Image.asset(
                    'assets/03_characters_mascot/cat_home_face_notification.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'こんにちは!',
          style: TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 36,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: YomiNowPalette.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Point your camera at Japanese text,\ntap a word, and read it now.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 17,
            height: 1.4,
            color: YomiNowPalette.ink.withValues(alpha: 0.72),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Scans',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 34,
            fontWeight: FontWeight.w700,
            color: YomiNowPalette.ink,
          ),
        ),
        Text(
          'See all',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: YomiNowPalette.ink.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentScansGrid() {
    final scanCards = [
      _ScanCard(
        title: '東京の桜',
        subtitle: 'Today, 10:24',
        accent: const Color(0xFFB6E1F5),
      ),
      _ScanCard(
        title: 'レストランメニュー',
        subtitle: 'Yesterday, 16:03',
        accent: const Color(0xFFCBE0F8),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 18) / 2;
        return SizedBox(
          height: 250,
          child: Row(
            children: [
              for (int i = 0; i < scanCards.length; i++) ...[
                if (i > 0) const SizedBox(width: 18),
                Expanded(
                  child: SizedBox(width: cardWidth, child: scanCards[i]),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.85),
                  const Color(0xFFDBF1FF),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 18,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.32),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                Positioned(
                  left: 36,
                  bottom: 24,
                  child: Container(
                    width: 90,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'NotoSansJP',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: YomiNowPalette.ink,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: YomiNowPalette.ink.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
