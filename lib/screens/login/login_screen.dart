import 'package:habitbegone_admin/screens/login/login_devices.dart';
import 'package:flutter/material.dart';
import 'package:habitbegone_admin/screens/login/login_web.dart';
import '../../responsive/responsive_layout.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const LoginMobile(),
      tablet: const LoginTablet(),
      web: const LoginWeb(),
    );
  }
}
