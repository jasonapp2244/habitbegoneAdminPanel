import 'package:habitbegone_admin/test2/provider/theme_provider.dart';
import 'package:habitbegone_admin/test2/widgets/setting_section.dart';
import 'package:habitbegone_admin/test2/widgets/setting_tile.dart';
import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
import 'package:habitbegone_admin/test2/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsTablet extends StatefulWidget {
  const SettingsTablet({super.key});

  @override
  State<SettingsTablet> createState() => _SettingsTabletState();
}

class _SettingsTabletState extends State<SettingsTablet> {
  bool darkMode = false;
  bool emailNotif = true;
  bool pushNotif = true;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      drawer: const Sidebar(),
      appBar: const TopBar(showMenu: true, heading: 'SETTING'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SettingsSection(
              title: "General",
              children: [
                SettingsTile(
                  icon: Icons.language,
                  title: "Language",
                  subtitle: "English (US)",
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.brightness_6,
                  title: "Dark Mode",
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: "Notifications",
              children: [
                SettingsTile(
                  icon: Icons.email,
                  title: "Email Notifications",
                  trailing: Switch(
                    value: emailNotif,
                    onChanged: (v) => setState(() => emailNotif = v),
                  ),
                ),
                SettingsTile(
                  icon: Icons.notifications,
                  title: "Push Notifications",
                  trailing: Switch(
                    value: pushNotif,
                    onChanged: (v) => setState(() => pushNotif = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SettingsSection(
              title: "Account",
              children: [
                SettingsTile(
                  icon: Icons.lock,
                  title: "Change Password",
                  onTap: () {},
                ),
                SettingsTile(
                  icon: Icons.exit_to_app,
                  title: "Logout",
                  textColor: Colors.red,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
