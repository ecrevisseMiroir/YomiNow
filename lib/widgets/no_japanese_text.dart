import 'package:flutter/material.dart';

import '../theme/yomi_now_theme.dart';
import 'package:yominow/l10n/app_localizations.dart';

class NoJapaneseText extends StatelessWidget {
  const NoJapaneseText({super.key, required this.onTryAgain});

  final VoidCallback onTryAgain;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
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
                                    l10n.noJapaneseTextTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.noJapaneseTextMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      height: 1.45,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.noJapaneseTextSuggestion,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      height: 1.4,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: onTryAgain,
                      icon: const Icon(Icons.add_a_photo_outlined),
                      label: Text(l10n.noJapaneseTextButton),
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
