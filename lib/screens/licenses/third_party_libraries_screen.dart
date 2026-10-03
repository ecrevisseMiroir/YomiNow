import 'package:flutter/material.dart';
import 'package:yominow/theme/yomi_now_theme.dart';

class ThirdPartyLibrariesScreen extends StatelessWidget {
  const ThirdPartyLibrariesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final libraries = [
      _LibraryEntry(
        name: 'Flutter',
        purpose: 'Cross-platform app framework and UI toolkit.',
      ),
      _LibraryEntry(
        name: 'camera',
        purpose: 'Custom mobile camera capture flow on Android and iOS.',
      ),
      _LibraryEntry(
        name: 'google_mlkit_text_recognition',
        purpose: 'Japanese OCR backend for mobile scanning.',
      ),
      _LibraryEntry(
        name: 'image_picker',
        purpose: 'Gallery and camera image selection support.',
      ),
      _LibraryEntry(
        name: 'kuromoji',
        purpose: 'Japanese morphological tokenization and word analysis.',
      ),
      _LibraryEntry(
        name: 'sqlite3',
        purpose: 'Offline dictionary database access.',
      ),
      _LibraryEntry(
        name: 'path_provider',
        purpose: 'Filesystem access for app data and local assets.',
      ),
      _LibraryEntry(
        name: 'image',
        purpose: 'Image preprocessing and EXIF orientation handling.',
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
                      'Third-party Libraries',
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
