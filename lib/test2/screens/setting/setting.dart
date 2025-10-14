import 'package:habitbegone_admin/test2/screens/setting/setting_mobile.dart';
import 'package:habitbegone_admin/test2/screens/setting/setting_tablet.dart';
import 'package:habitbegone_admin/test2/screens/setting/setting_web.dart';
import 'package:flutter/material.dart';
import '../../responsive/responsive_layout.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const SettingsMobile(),
      tablet: const SettingsTablet(),
      web: const SettingsWeb(),
    );
  }
}
