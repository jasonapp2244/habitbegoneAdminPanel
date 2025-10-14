import 'package:habitbegone_admin/test2/responsive/responsive_layout.dart';
import 'package:habitbegone_admin/test2/screens/dashboard/dashboard_mobile.dart';
import 'package:habitbegone_admin/test2/screens/dashboard/dashboard_tablet.dart';
import 'package:habitbegone_admin/test2/screens/dashboard/dashboard_web.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const DashboardMobile(),
      tablet: const DashboardTablet(),
      web: const DashboardWeb(),
    );
  }
}
