import 'package:habitbegone_admin/test2/screens/user/user_mobile.dart';
import 'package:habitbegone_admin/test2/screens/user/user_tablet.dart';
import 'package:habitbegone_admin/test2/screens/user/user_web.dart';
import 'package:flutter/material.dart';
import '../../responsive/responsive_layout.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobile: UsersWeb(),
      tablet: UsersWeb(),
      web: UsersWeb(),
    );
  }
}
