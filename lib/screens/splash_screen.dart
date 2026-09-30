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
    if (mounted) return;
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
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxHeight < 220;
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/02_brand_logo/logo_splash.png',
                          width: 200,
                          height: 150,
                          fit: BoxFit.cover,
                          semanticLabel: 'YomiNow logo',
                        ),
                        Image.asset(
                          'assets/02_brand_logo/wordmark_splash.png',
                          width: 200,
                          height: compact ? 48 : 84,
                          fit: BoxFit.contain,
                          semanticLabel: 'YomiNow, Read Japanese Instantly',
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.topCenter,
                child: Transform.scale(
                  scale: 1.05,
                  child: Image.asset(
                    'assets/04_scenery_backgrounds/splash_fuji_torii_scene.png',
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    semanticLabel: 'Mount Fuji and a torii gate',
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Loading...',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      color: YomiNowPalette.coral,
                      backgroundColor: YomiNowPalette.coral.withValues(
                        alpha: 0.2,
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(3)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
