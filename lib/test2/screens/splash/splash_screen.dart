import 'package:habitbegone_admin/test2/screens/splash/splash_mobilw.dart';
import 'package:flutter/material.dart';
import '../../responsive/responsive_layout.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const SplashMobile(),
      tablet: const SplashTablet(),
      web: const SplashWeb(),
    );
  }
}
