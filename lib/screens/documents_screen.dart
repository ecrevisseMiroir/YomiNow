import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/scanned_document.dart';
import '../services/app_services.dart';
import '../theme/yomi_now_theme.dart';
import '../widgets/yomi_now_bottom_nav.dart';
import '../widgets/error_dialog.dart';
import 'camera_scanner.dart';
import 'image_screen.dart';

import 'package:yominow/l10n/app_localizations.dart';

enum _DocumentFilter { all, images, text }

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key, this.picker});

  final ImagePicker? picker;

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late final ImagePicker _picker = widget.picker ?? ImagePicker();
  List<ScannedDocument> _documents = <ScannedDocument>[];
  _DocumentFilter _selectedFilter = _DocumentFilter.all;
  bool _isLoadingDocuments = true;
  bool _didLoadDocuments = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoadDocuments) return;
    _didLoadDocuments = true;
    unawaited(_loadDocuments());
  }

  Future<void> _loadDocuments() async {
    try {
      final documents = await AppServicesScope.of(context).documents.getAll();
      if (!mounted) return;
      setState(() {
        _documents = documents;
        _isLoadingDocuments = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingDocuments = false);
      await YomiNowErrorDialog.show(context);
    }
  }

  Future<void> _pickDocument(ImageSource source) async {
    final XFile? file;
    try {
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

      final document = await AppServicesScope.of(context).documents
          .addImage(file);
      if (!mounted) return;
      setState(() => _documents.insert(0, document));

      await _openDocument(document);
    } catch (error) {
      if (!mounted) return;
      await YomiNowErrorDialog.show(context);
      return;
    }
  }

  Future<void> _openDocument(ScannedDocument document) async {
    if (!mounted || document.path.isEmpty) return;
    try {
      final hasText = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => ImageScreen(imagePath: document.path),
        ),
      );
      if (!mounted || hasText == null) return;
      await AppServicesScope.of(context).documents
          .updateHasText(document.id, hasText);
      if (!mounted) return;
      setState(() {
        final index = _documents.indexWhere((item) => item.id == document.id);
        if (index >= 0) _documents[index] = document.copyWith(hasText: hasText);
      });
    } catch (_) {
      if (mounted) await YomiNowErrorDialog.show(context);
    }
  }

  Future<void> _deleteDocument(ScannedDocument document) async {
    try {
      await AppServicesScope.of(context).documents.delete(document.id);
      if (!mounted) return;
      setState(() => _documents.removeWhere((item) => item.id == document.id));
    } catch (_) {
      if (mounted) await YomiNowErrorDialog.show(context);
    }
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
    if (_isLoadingDocuments) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
        bottomNavigationBar: const YomiNowBottomNav(selectedIndex: 1),
      );
    }
    if (_documents.isEmpty) {
      return _buildEmptyState();
    }
    final colorScheme = Theme.of(context).colorScheme;
    final visibleDocuments = switch (_selectedFilter) {
      _DocumentFilter.all || _DocumentFilter.images => _documents,
      _DocumentFilter.text =>
        _documents.where((document) => document.hasText).toList(),
    };
    final l10n = AppLocalizations.of(context)!;

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
                AppLocalizations.of(context)!.documentsScreenTitle,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontSize: 35,
                  height: 1,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: -2.0,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  _TabButton(
                    label: l10n.documentsScreenTabAll,
                    selected: _selectedFilter == _DocumentFilter.all,
                    onTap: () =>
                        setState(() => _selectedFilter = _DocumentFilter.all),
                  ),
                  const SizedBox(width: 26),
                  _TabButton(
                    label: l10n.documentsScreenTabImages,
                    selected: _selectedFilter == _DocumentFilter.images,
                    onTap: () => setState(
                      () => _selectedFilter = _DocumentFilter.images,
                    ),
                  ),
                  const SizedBox(width: 26),
                  _TabButton(
                    label: l10n.documentsScreenTabText,
                    selected: _selectedFilter == _DocumentFilter.text,
                    onTap: () =>
                        setState(() => _selectedFilter = _DocumentFilter.text),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: visibleDocuments.isEmpty
                    ? Center(
                        child: Text(
                          l10n.documentsScreenNoTextDocuments,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: visibleDocuments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = visibleDocuments[index];
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
                                      ? Image.file(
                                          File(item.path),
                                          fit: BoxFit.cover,
                                        )
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontFamily: 'NotoSansJP',
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Wrap(
                                            spacing: 14,
                                            runSpacing: 4,
                                            children: [
                                              Text(
                                                '${_monthName(item.createdAt.month)} ${item.createdAt.day}, ${item.createdAt.year}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 16,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                              ),
                                              Text(
                                                '${item.createdAt.hour.toString().padLeft(2, '0')}:${item.createdAt.minute.toString().padLeft(2, '0')}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 15,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
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
                                        color: colorScheme.onSurfaceVariant,
                                        size: 32,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      onSelected: (value) {
                                        if (value == 0) {
                                          unawaited(_openDocument(item));
                                        } else if (value == 1) {
                                          unawaited(_deleteDocument(item));
                                        }
                                      },
                                      itemBuilder: (_) => [
                                        PopupMenuItem<int>(
                                          value: 0,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .documentsScreenPopupOpen,
                                          ),
                                        ),
                                        PopupMenuItem<int>(
                                          value: 1,
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .documentsScreenPopupDelete,
                                          ),
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
        final colorScheme = Theme.of(context).colorScheme;
        final isCompact = constraints.maxWidth < 420;
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final imageWidth = isLandscape ? 180.0 : (isCompact ? 260.0 : 320.0);

        final header = Text(
          AppLocalizations.of(context)!.documentsScreenTitle,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 35,
            height: 1,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
            letterSpacing: -2.0,
          ),
        );

        final title = Text(
          AppLocalizations.of(context)!.documentsScreenEmptyTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isCompact ? 32 : 40,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
            letterSpacing: -1.2,
          ),
        );

        final subtitle = Text(
          AppLocalizations.of(context)!.documentsScreenEmptySubtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: isCompact ? 20 : 24,
            height: 1.3,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: -0.6,
          ),
        );

        final cameraButton = FilledButton.icon(
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
            AppLocalizations.of(context)!.documentsScreenCameraButton,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isCompact ? 24 : 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
              color: YomiNowPalette.cream,
            ),
          ),
        );

        final galleryButton = FilledButton.icon(
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
            AppLocalizations.of(context)!.documentsScreenGalleryButton,
            style: TextStyle(
              fontFamily: 'Fredoka',
              fontSize: isCompact ? 24 : 30,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.8,
              color: YomiNowPalette.indigo,
            ),
          ),
        );

        final columnContent = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const SizedBox(height: 18),
            Center(
              child: Image.asset(
                'assets/03_characters_mascot/cat_empty_state.png',
                width: imageWidth,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 18),
            title,
            const SizedBox(height: 12),
            subtitle,
            const SizedBox(height: 28),
            cameraButton,
            const SizedBox(height: 16),
            galleryButton,
          ],
        );

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 18,
                right: 18,
                top: 8,
                bottom: 0,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: isLandscape
                      ? SingleChildScrollView(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                child: Center(
                                  child: Image.asset(
                                    'assets/03_characters_mascot/cat_empty_state.png',
                                    width: imageWidth,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 22),
                              Flexible(
                                flex: 3,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    header,
                                    const SizedBox(height: 18),
                                    title,
                                    const SizedBox(height: 12),
                                    subtitle,
                                    const SizedBox(height: 24),
                                    cameraButton,
                                    const SizedBox(height: 12),
                                    galleryButton,
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : columnContent,
                ),
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
  const _TabButton({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
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
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
