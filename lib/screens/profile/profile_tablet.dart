import 'package:habitbegone_admin/widgets/profile_form.dart';
import 'package:habitbegone_admin/widgets/profile_header.dart';
import 'package:habitbegone_admin/widgets/sidebar.dart';
import 'package:habitbegone_admin/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';

class ProfileTablet extends StatelessWidget {
  const ProfileTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Sidebar(),
      appBar: const TopBar(showMenu: true, heading: 'PROFILE'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: const [
            ProfileHeader(),
            SizedBox(height: 32),
            ProfileForm(),
          ],
        ),
      ),
    );
  }
}
