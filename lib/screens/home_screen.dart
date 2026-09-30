import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    final theme = Theme.of(context);
    final isMobile = switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: 12,
                children: [
                  Icon(
                    Icons.translate,
                    size: 72,
                    color: theme.colorScheme.primary,
                  ),
                  Text(
                    'YomiNow',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Pick a photo of Japanese text, then tap any word to '
                    'look it up.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (isMobile) ...[
                    FilledButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera),
                      label: const Text('Take photo'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose from gallery'),
                    ),
                  ] else
                    FilledButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.folder_open),
                      label: const Text('Open image'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
