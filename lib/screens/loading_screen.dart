import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:yominow/l10n/app_localizations.dart';
import 'package:yominow/l10n/app_localizations_en.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, this.currentStep = 1});

  /// Zero-based index of the processing stage currently in progress.
  final int currentStep;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();

  // Stages will be built dynamically based on localization

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context) ?? AppLocalizationsEn();
    final stages = <String>[
      l10n.loadingStageImagePreprocessing,
      l10n.loadingStageRunningOCR,
    ];

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final activeStep = widget.currentStep.clamp(0, stages.length - 1);
            final ringSize = isLandscape ? 156.0 : 190.0;

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: constraints.maxHeight * (isLandscape ? 0.44 : 0.32),
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.9,
                      child: Image.asset(
                        'assets/04_scenery_backgrounds/loading.png',
                        fit: BoxFit.contain,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isLandscape ? 28 : 24,
                      vertical: isLandscape ? 12 : 20,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isLandscape ? 820 : 520,
                          minHeight:
                              constraints.maxHeight - (isLandscape ? 24 : 40),
                        ),
                        child: isLandscape
                            ? _buildLandscape(
                                activeStep,
                                ringSize,
                                colors,
                                l10n,
                                stages,
                              )
                            : _buildPortrait(
                                activeStep,
                                ringSize,
                                colors,
                                l10n,
                                stages,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPortrait(
    int activeStep,
    double ringSize,
    ColorScheme colors,
    AppLocalizations l10n,
    List<String> stages,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressRing(ringSize, colors),
        const SizedBox(height: 22),
        _buildHeading(colors, l10n),
        const SizedBox(height: 34),
        _buildStageList(activeStep, stages),
      ],
    );
  }

  Widget _buildLandscape(
    int activeStep,
    double ringSize,
    ColorScheme colors,
    AppLocalizations l10n,
    List<String> stages,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressRing(ringSize, colors),
              const SizedBox(height: 12),
              _buildHeading(colors, l10n),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: _buildStageList(activeStep, stages)),
      ],
    );
  }

  Widget _buildProgressRing(double size, ColorScheme colors) {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            rotation: _ringController.value * 2 * math.pi,
            trackColor: colors.primaryContainer.withValues(alpha: 0.5),
            primaryColor: colors.primary,
            secondaryColor: colors.secondary,
          ),
          child: Center(
            child: Image.asset(
              Theme.of(context).brightness == Brightness.dark
                  ? 'assets/03_characters_mascot/cat_loading_dark_mode.png'
                  : 'assets/03_characters_mascot/cat_loading_light_mode.png',
              width: size * 0.43,
              height: size * 0.43,
              fit: BoxFit.contain,
              semanticLabel: 'YomiNow mascot',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeading(ColorScheme colors, AppLocalizations l10n) {
    return Column(
      children: [
        Text(
          l10n.imageScreenProcessingTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildStageList(int activeStep, List<String> stages) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < stages.length; index++)
          _StageRow(
            label: stages[index],
            state: index < activeStep
                ? _StageState.complete
                : index == activeStep
                ? _StageState.active
                : _StageState.pending,
          ),
      ],
    );
  }
}

enum _StageState { complete, active, pending }

class _StageRow extends StatelessWidget {
  const _StageRow({required this.label, required this.state});

  final String label;
  final _StageState state;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPending = state == _StageState.pending;
    final foreground = isPending
        ? colors.onSurface.withValues(alpha: 0.34)
        : colors.onSurface;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: switch (state) {
                _StageState.complete => Icon(
                  Icons.check_circle_rounded,
                  size: 27,
                  color: colors.primary,
                ),
                _StageState.active => SizedBox.square(
                  dimension: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: colors.primary,
                    backgroundColor: colors.primaryContainer,
                  ),
                ),
                _StageState.pending => Icon(
                  Icons.circle_outlined,
                  size: 29,
                  color: foreground.withValues(alpha: 0.4),
                ),
              },
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: 18,
                fontWeight: state == _StageState.active
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  const _ProgressRingPainter({
    required this.rotation,
    required this.trackColor,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final double rotation;
  final Color trackColor;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final stroke = size.shortestSide * 0.038;
    final bounds = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    canvas.drawCircle(
      center,
      radius - stroke / 2,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      bounds,
      -math.pi / 2 + rotation,
      math.pi * 0.54,
      false,
      secondaryPaint,
    );
    canvas.drawArc(
      bounds,
      0.19 + rotation,
      math.pi * 1.43,
      false,
      primaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.rotation != rotation ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.primaryColor != primaryColor ||
      oldDelegate.secondaryColor != secondaryColor;
}
