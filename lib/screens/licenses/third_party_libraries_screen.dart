import 'package:flutter/material.dart';
import 'package:yominow/l10n/app_localizations.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

class ThirdPartyLibrariesScreen extends StatelessWidget {
  const ThirdPartyLibrariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final libraries = [
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenFlutter,
        purpose: l10n.thirdPartyLibrariesScreenFlutterPurpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenCamera,
        purpose: l10n.thirdPartyLibrariesScreenCameraPurpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenGoogleMlkit,
        purpose: l10n.thirdPartyLibrariesScreenGoogleMlkitPurpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenImagePicker,
        purpose: l10n.thirdPartyLibrariesScreenImagePickerPurpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenKuromoji,
        purpose: l10n.thirdPartyLibrariesScreenKuromojiPurpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenSqlite3,
        purpose: l10n.thirdPartyLibrariesScreenSqlite3Purpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenPathProvider,
        purpose: l10n.thirdPartyLibrariesScreenPathProviderPurpose,
      ),
      _LibraryEntry(
        name: l10n.thirdPartyLibrariesScreenImage,
        purpose: l10n.thirdPartyLibrariesScreenImagePurpose,
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
                    tooltip: l10n.thirdPartyLibrariesScreenBackTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.thirdPartyLibrariesScreenTitle,
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
              Expanded(
                child: ListView.separated(
                  itemCount: libraries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final library = libraries[index];
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
                            library.name,
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: YomiNowPalette.indigo,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            library.purpose,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              height: 1.5,
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

class _LibraryEntry {
  const _LibraryEntry({required this.name, required this.purpose});

  final String name;
  final String purpose;
}
