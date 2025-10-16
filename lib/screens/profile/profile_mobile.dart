import 'package:habitbegone_admin/widgets/profile_form.dart';
import 'package:habitbegone_admin/widgets/profile_header.dart';
import 'package:flutter/material.dart';

class ProfileMobile extends StatelessWidget {
  const ProfileMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ProfileHeader(),
            SizedBox(height: 24),
            ProfileForm(),
          ],
        ),
      ),
    );
  }
}
