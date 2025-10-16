import 'package:flutter/material.dart';
import '../../responsive/responsive_layout.dart';
import 'profile_mobile.dart';
import 'profile_tablet.dart';
import 'profile_web.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const ProfileMobile(),
      tablet: const ProfileTablet(),
      web: const ProfileWeb(),
    );
  }
}
