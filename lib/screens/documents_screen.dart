import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.picker});

  final ImagePicker? picker;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  final List<_DocumentItem> _documents = <_DocumentItem>[];

  Future<void> _pickDocument(ImageSource source) async {
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
    final now = DateTime.now();
    final title = file.name.isNotEmpty ? file.name : 'Scanned Image';

    setState(() {
      _documents.insert(
        0,
        _DocumentItem(
          title: title,
          date: '${_monthName(now.month)} ${now.day}, ${now.year}',
          time:
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          path: path.isEmpty ? '' : path,
        ),
      );
    });
  }

  void _deleteDocument(int index) {
    setState(() {
      _documents.removeAt(index);
    });
  }

  String _monthName(int month) {
    const months = <String>[
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
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (_documents.isEmpty) {
      return _buildEmptyState();
    }

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
                  itemCount: _documents.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _documents[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child:
                                item.path.isNotEmpty &&
                                    File(item.path).existsSync()
                                ? Image.file(File(item.path), fit: BoxFit.cover)
                                : Image.asset(
                                    'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
                                    fit: BoxFit.cover,
                                  ),
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
                              PopupMenuButton<int>(
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
                                onSelected: (value) {
                                  if (value == 1) {
                                    _deleteDocument(index);
                                  }
                                },
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
      bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildEmptyState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final imageWidth = isCompact ? 260.0 : 320.0;

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
                  const Spacer(flex: 1),
                  Center(
                    child: Image.asset(
                      'assets/03_characters_mascot/cat_empty_state.png',
                      width: imageWidth,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'No Documents Yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isCompact ? 32 : 40,
                      fontWeight: FontWeight.w700,
                      color: YomiNowPalette.ink,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Scan your first image or import\nan existing one to get started.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Fredoka',
                      fontSize: isCompact ? 20 : 24,
                      height: 1.3,
                      color: YomiNowPalette.ink.withValues(alpha: 0.75),
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 28),
                  FilledButton.icon(
                    onPressed: () async {
                      await _pickDocument(ImageSource.camera);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: YomiNowPalette.coral,
                      foregroundColor: YomiNowPalette.ink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      Icons.camera_alt_rounded,
                      size: isCompact ? 26 : 32,
                      color: YomiNowPalette.cream,
                    ),
                    label: Text(
                      'Scan with Camera',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isCompact ? 24 : 30,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        color: YomiNowPalette.cream,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () async {
                      await _pickDocument(ImageSource.gallery);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: YomiNowPalette.softBlue,
                      foregroundColor: YomiNowPalette.ink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    icon: Icon(
                      Icons.photo_library_rounded,
                      size: isCompact ? 26 : 32,
                      color: YomiNowPalette.indigo,
                    ),
                    label: Text(
                      'Choose from Gallery',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isCompact ? 24 : 30,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        color: YomiNowPalette.indigo,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ),
          bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 1),
        );
      },
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
    required this.path,
  });

  final String title;
  final String date;
  final String time;
  final String path;
}
