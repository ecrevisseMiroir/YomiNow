import 'package:flutter/material.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

class OpenSourceScreen extends StatelessWidget {
  const OpenSourceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      _OpenSourceItem(
        title: 'Project source',
        detail:
            'The app code is kept in the project workspace and organized by feature, service, and UI screen.',
      ),
      _OpenSourceItem(
        title: 'Contribution model',
        detail:
            'Improvements can be made to OCR, dictionary matching, UI polish, and accessibility without changing the core workflow.',
      ),
      _OpenSourceItem(
        title: 'Project mindset',
        detail:
            'YomiNow is designed to be transparent, offline-first, and easy to extend for future language-learning features.',
      ),
    ];

    return Scaffold(
      backgroundColor: YomiNowPalette.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
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
                      'Open Source',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 32,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: YomiNowPalette.ink,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: YomiNowPalette.softBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'YomiNow is built to stay open, modular, and easy to improve together.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    height: 1.55,
                    color: YomiNowPalette.ink.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: YomiNowPalette.indigo.withValues(alpha: 0.14),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: YomiNowPalette.indigo,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.detail,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              height: 1.55,
                              color: YomiNowPalette.ink.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenSourceItem {
  const _OpenSourceItem({required this.title, required this.detail});

  final String title;
  final String detail;
}
