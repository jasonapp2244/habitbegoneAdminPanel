import 'package:habitbegone_admin/widgets/profile_form.dart';
import 'package:habitbegone_admin/widgets/profile_header.dart';
import 'package:habitbegone_admin/widgets/sidebar.dart';
import 'package:habitbegone_admin/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';

class ProfileWeb extends StatelessWidget {
  const ProfileWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(showMenu: false, heading: 'PROFILE'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            ProfileHeader(),
                            SizedBox(height: 32),
                            ProfileForm(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
