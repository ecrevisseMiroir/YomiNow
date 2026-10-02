import 'package:flutter/material.dart';

import '../theme/yomi_now_theme.dart';

class NoJapaneseText extends StatelessWidget {
  const NoJapaneseText({super.key, required this.onTryAgain});

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxHeight < 520 ? 180.0 : 250.0;
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/03_characters_mascot/cat_empty_state.png',
                    width: imageSize,
                    height: imageSize,
                    fit: BoxFit.contain,
                    semanticLabel: 'YomiNow cat reading a book',
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Japanese text found',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: YomiNowPalette.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "We couldn't find readable Japanese in this image.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      height: 1.45,
                      color: YomiNowPalette.ink.withValues(alpha: 0.72),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Try a sharper photo with the text in view.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      height: 1.4,
                      color: YomiNowPalette.ink.withValues(alpha: 0.62),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onTryAgain,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: const Text('Choose another image'),
                      style: FilledButton.styleFrom(
                        backgroundColor: YomiNowPalette.coral,
                        foregroundColor: YomiNowPalette.cream,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
