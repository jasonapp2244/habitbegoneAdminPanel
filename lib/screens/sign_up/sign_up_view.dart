import 'package:habitbegone_admin/screens/sign_up/sign_up_device.dart';
import 'package:flutter/material.dart';
import '../../responsive/responsive_layout.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: const SignUpMobile(),
      tablet: const SignUpTablet(),
      web: const SignUpWeb(),
    );
  }
}
