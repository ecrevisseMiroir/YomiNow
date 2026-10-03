import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/yomi_now_theme.dart';

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

  static const _stages = <String>[
    'Image preprocessing',
    'Running OCR',
    'Extracting text',
    'Finding words',
    'Looking up dictionary',
  ];

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: YomiNowPalette.cream,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            final activeStep = widget.currentStep.clamp(0, _stages.length - 1);
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
                            ? _buildLandscape(activeStep, ringSize, colors)
                            : _buildPortrait(activeStep, ringSize, colors),
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

  Widget _buildPortrait(int activeStep, double ringSize, ColorScheme colors) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildProgressRing(ringSize),
        const SizedBox(height: 22),
        _buildHeading(colors),
        const SizedBox(height: 34),
        _buildStageList(activeStep),
      ],
    );
  }

  Widget _buildLandscape(int activeStep, double ringSize, ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildProgressRing(ringSize),
              const SizedBox(height: 12),
              _buildHeading(colors),
            ],
          ),
        ),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: _buildStageList(activeStep)),
      ],
    );
  }

  Widget _buildProgressRing(double size) {
    return AnimatedBuilder(
      animation: _ringController,
      builder: (context, _) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _ProgressRingPainter(
            rotation: _ringController.value * 2 * math.pi,
          ),
          child: Center(
            child: Image.asset(
              'assets/03_characters_mascot/cat_loading.png',
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

  Widget _buildHeading(ColorScheme colors) {
    return Column(
      children: [
        Text(
          'Processing Image...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: colors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enhancing image and running OCR',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 17,
            color: colors.onSurface.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
  }

  Widget _buildStageList(int activeStep) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < _stages.length; index++)
          _StageRow(
            label: _stages[index],
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
    final isPending = state == _StageState.pending;
    final foreground = isPending
        ? YomiNowPalette.ink.withValues(alpha: 0.34)
        : YomiNowPalette.ink;

    return SizedBox(
      height: 48,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Center(
              child: switch (state) {
                _StageState.complete => const Icon(
                  Icons.check_circle_rounded,
                  size: 27,
                  color: YomiNowPalette.indigo,
                ),
                _StageState.active => const SizedBox.square(
                  dimension: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    color: YomiNowPalette.indigo,
                    backgroundColor: YomiNowPalette.softBlue,
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
  const _ProgressRingPainter({required this.rotation});

  final double rotation;

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
        ..color = YomiNowPalette.softBlue.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    final bluePaint = Paint()
      ..color = YomiNowPalette.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    final coralPaint = Paint()
      ..color = YomiNowPalette.coral
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      bounds,
      -math.pi / 2 + rotation,
      math.pi * 0.54,
      false,
      coralPaint,
    );
    canvas.drawArc(bounds, 0.19 + rotation, math.pi * 1.43, false, bluePaint);
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}
