import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/yomi_now_theme.dart';

import 'package:yominow/l10n/app_localizations.dart';

class CameraScanner extends StatefulWidget {
  const CameraScanner({super.key});

  @override
  State<CameraScanner> createState() => _CameraScannerState();
}

class _CameraScannerState extends State<CameraScanner> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _isInitializing = true;
  bool _isBusy = false;
  bool _flashEnabled = false;
  Object? _cameraError;

  @override
  void initState() {
    super.initState();
    unawaited(_initializeCamera());
  }

  Future<void> _initializeCamera([CameraDescription? preferredCamera]) async {
    CameraController? controller;
    try {
      final cameras = await availableCameras();
      if (!mounted) return;
      if (cameras.isEmpty) throw StateError('No cameras are available.');

      final description =
          preferredCamera ??
          cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => cameras.first,
          );
      controller = CameraController(
        description,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      if (_flashEnabled) {
        try {
          await controller.setFlashMode(FlashMode.torch);
        } on CameraException {
          _flashEnabled = false;
        }
      }
      _cameras = cameras;
      _controller = controller;
      setState(() {
        _isInitializing = false;
        _cameraError = null;
      });
    } catch (error) {
      await controller?.dispose();
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _cameraError = error;
      });
    }
  }

  Future<void> _switchCamera() async {
    final controller = _controller;
    if (controller == null || _cameras.length < 2 || _isBusy) return;

    final currentIndex = _cameras.indexOf(controller.description);
    final nextCamera = _cameras[(currentIndex + 1) % _cameras.length];
    setState(() {
      _isInitializing = true;
      _cameraError = null;
    });
    _controller = null;
    await controller.dispose();
    if (mounted) await _initializeCamera(nextCamera);
  }

  Future<void> _toggleFlash() async {
    final controller = _controller;
    if (controller == null || _isBusy) return;

    final nextEnabled = !_flashEnabled;
    try {
      await controller.setFlashMode(
        nextEnabled ? FlashMode.torch : FlashMode.off,
      );
      if (!mounted) return;
      setState(() => _flashEnabled = nextEnabled);
    } on CameraException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.cameraScannerFlashUnavailable,
          ),
        ),
      );
    }
  }

  Future<void> _takePhoto() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized || _isBusy) {
      return;
    }

    setState(() => _isBusy = true);
    try {
      final photo = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(photo);
    } on CameraException {
      if (!mounted) return;
      setState(() => _isBusy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.cameraScannerCaptureFailed,
          ),
        ),
      );
    }
  }

  Future<void> _openGallery() async {
    if (_isBusy) return;
    try {
      final photo = await _picker.pickImage(source: ImageSource.gallery);
      if (photo != null && mounted) Navigator.of(context).pop(photo);
    } on PlatformException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.cameraScannerOpenGalleryFailed,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    final controller = _controller;
    if (controller != null) unawaited(controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: YomiNowPalette.darkSurface,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildPreview()),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 58,
      child: Row(
        children: [
          _roundIconButton(
            icon: Icons.close_rounded,
            label: AppLocalizations.of(context)!.cameraScannerCloseCamera,
            onPressed: () => Navigator.of(context).pop(),
            backgroundColor: Colors.transparent,
          ),
          const Spacer(),
          _roundIconButton(
            icon: _flashEnabled
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            label: _flashEnabled
                ? AppLocalizations.of(context)!.cameraScannerTurnFlashOff
                : AppLocalizations.of(context)!.cameraScannerTurnFlashOn,
            onPressed: _toggleFlash,
            backgroundColor: Colors.transparent,
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final controller = _controller;
    if (_isInitializing) {
      return const Center(
        child: CircularProgressIndicator(color: YomiNowPalette.indigo),
      );
    }
    if (_cameraError != null || controller == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.no_photography_outlined,
                color: Colors.white70,
                size: 42,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.cameraScannerCameraUnavailable,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.cameraScannerAccessInstructions,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _isInitializing = true);
                  unawaited(_initializeCamera());
                },
                icon: const Icon(Icons.refresh_rounded),
                label: Text(
                  AppLocalizations.of(context)!.cameraScannerTryAgain,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final aspectRatio = constraints.maxHeight > constraints.maxWidth
            ? 1 / controller.value.aspectRatio
            : controller.value.aspectRatio;
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxWidth / aspectRatio,
              child: CameraPreview(controller),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFF0C1420),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _modeButton(
                  label: AppLocalizations.of(context)!.cameraScannerModePhoto,
                  selected: true,
                  onTap: () {},
                ),
                _modeButton(
                  label: AppLocalizations.of(context)!.cameraScannerModeGallery,
                  onTap: _openGallery,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _roundIconButton(
                icon: Icons.photo_library_outlined,
                label: AppLocalizations.of(context)!
                    .cameraScannerChooseFromGallery,
                onPressed: _openGallery,
              ),
              Semantics(
                button: true,
                label: AppLocalizations.of(context)!.cameraScannerTakePhoto,
                child: GestureDetector(
                  onTap: _isBusy ? null : _takePhoto,
                  child: Container(
                    width: 86,
                    height: 86,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _isBusy ? Colors.white70 : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              _roundIconButton(
                icon: Icons.cameraswitch_outlined,
                label: AppLocalizations.of(context)!.cameraScannerSwitchCamera,
                onPressed: _switchCamera,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modeButton({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minWidth: 110, minHeight: 42),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? YomiNowPalette.indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _roundIconButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFF263447),
  }) {
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,
        fixedSize: const Size(58, 58),
      ),
      icon: Icon(icon, size: 29),
    );
  }
}
