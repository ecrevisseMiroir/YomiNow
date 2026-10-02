import 'package:flutter/material.dart';

import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _DocumentItem(
        title: '東京の観光ガイド',
        date: 'Aug 12, 2025',
        time: '10:24',
        asset: 'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
      ),
      _DocumentItem(
        title: '日本の文化',
        date: 'Aug 11, 2025',
        time: '15:17',
        asset: 'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
      ),
      _DocumentItem(
        title: 'レストランメニュー',
        date: 'Aug 10, 2025',
        time: '12:03',
        asset: 'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
      ),
      _DocumentItem(
        title: '電車の時刻表',
        date: 'Aug 8, 2025',
        time: '09:42',
        asset: 'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
      ),
      _DocumentItem(
        title: '桜の写真',
        date: 'Aug 5, 2025',
        time: '18:20',
        asset: 'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
      ),
      _DocumentItem(
        title: '旅行のパンフレット',
        date: 'Aug 2, 2025',
        time: '14:10',
        asset: 'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 18,
            right: 18,
            top: 8,
            bottom: 0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Text(
                'Documents',
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 35,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: YomiNowPalette.ink,
                  letterSpacing: -2.0,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _TabButton(label: 'All', selected: true),
                  const SizedBox(width: 26),
                  _TabButton(label: 'Images'),
                  const SizedBox(width: 26),
                  _TabButton(label: 'Text'),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: Image.asset(item.asset, fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'NotoSansJP',
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: YomiNowPalette.ink,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Wrap(
                                      spacing: 14,
                                      runSpacing: 4,
                                      children: [
                                        Text(
                                          item.date,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 16,
                                            color: YomiNowPalette.ink
                                                .withValues(alpha: 0.72),
                                          ),
                                        ),
                                        Text(
                                          item.time,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            color: YomiNowPalette.ink
                                                .withValues(alpha: 0.72),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuButton<void>(
                                icon: Icon(
                                  Icons.more_vert,
                                  color: YomiNowPalette.ink.withValues(
                                    alpha: 0.7,
                                  ),
                                  size: 32,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                itemBuilder: (_) => const [
                                  PopupMenuItem<int>(
                                    value: 0,
                                    child: Text('Open'),
                                  ),
                                  PopupMenuItem<int>(
                                    value: 1,
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ],
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
      ),
      bottomNavigationBar: null,
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({required this.label, this.selected = false});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: selected
            ? BoxDecoration(
                color: YomiNowPalette.coral,
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: selected
                ? YomiNowPalette.cream
                : YomiNowPalette.ink.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

class _DocumentItem {
  const _DocumentItem({
    required this.title,
    required this.date,
    required this.time,
    required this.asset,
  });

  final String title;
  final String date;
  final String time;
  final String asset;
}
