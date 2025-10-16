// splash_mobile.dart
import 'package:flutter/material.dart';

class SplashMobile extends StatelessWidget {
  const SplashMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash - Mobile View", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

// splash_tablet.dart

class SplashTablet extends StatelessWidget {
  const SplashTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash - Tablet View", style: TextStyle(fontSize: 28)),
      ),
    );
  }
}

// splash_web.dart

class SplashWeb extends StatelessWidget {
  const SplashWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Splash - Web View", style: TextStyle(fontSize: 32)),
      ),
    );
  }
}
