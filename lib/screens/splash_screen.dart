import 'dart:async';

import 'package:flutter/material.dart';

import 'home_screen.dart';
import '../theme/yomi_now_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _transitionTimer;

  @override
  void initState() {
    super.initState();
    _transitionTimer = Timer(const Duration(milliseconds: 1800), _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _transitionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            return Column(
              children: [
                Expanded(
                  child: isLandscape
                      ? Row(
                          children: [
                            Expanded(flex: 4, child: _buildBrand()),
                            Expanded(flex: 6, child: _buildScene(isLandscape)),
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(flex: 4, child: _buildBrand()),
                            Expanded(flex: 5, child: _buildScene(isLandscape)),
                          ],
                        ),
                ),
                SizedBox(
                  height: isLandscape ? 64 : 100,
                  child: LayoutBuilder(
                    builder: (context, footerConstraints) {
                      final progress = SizedBox(
                        width: footerConstraints.maxWidth * 0.45,
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          color: YomiNowPalette.coral,
                          backgroundColor: YomiNowPalette.coral.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(3),
                          ),
                        ),
                      );
                      final label = Text(
                        'Loading...',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      );

                      if (isLandscape) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            label,
                            const SizedBox(width: 16),
                            progress,
                          ],
                        );
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [label, const SizedBox(height: 16), progress],
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBrand() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/02_brand_logo/logo_splash.png',
              width: 200,
              height: 150,
              fit: BoxFit.contain,
              semanticLabel: 'YomiNow logo',
            ),
            Image.asset(
              'assets/02_brand_logo/wordmark_splash.png',
              width: 200,
              height: 84,
              fit: BoxFit.contain,
              semanticLabel: 'YomiNow, Read Japanese Instantly',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScene(bool isLandscape) {
    return SizedBox.expand(
      child: Transform.scale(
        scale: isLandscape ? 1.0 : 1.05,
        child: Image.asset(
          'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
          fit: isLandscape ? BoxFit.contain : BoxFit.fitWidth,
          semanticLabel: 'Mount Fuji and a torii gate',
        ),
      ),
    );
  }
}
