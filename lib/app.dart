import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'services/app_services.dart';

/// The root widget: a dark Material 3 app that provides [services] to every
/// screen.
class YomiNowApp extends StatelessWidget {
  const YomiNowApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: services,
      child: MaterialApp(
        title: 'YomiNow',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF38BDF8), // sky blue
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: Colors.black,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
