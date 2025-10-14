import 'package:habitbegone_admin/test2/provider/theme_provider.dart';
import 'package:habitbegone_admin/test2/widgets/setting_section.dart';
import 'package:habitbegone_admin/test2/widgets/setting_tile.dart';
import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
import 'package:habitbegone_admin/test2/widgets/topbar_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsWeb extends StatefulWidget {
  const SettingsWeb({super.key});

  @override
  State<SettingsWeb> createState() => _SettingsWebState();
}

class _SettingsWebState extends State<SettingsWeb> {
  bool darkMode = false;
  bool emailNotif = true;
  bool pushNotif = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: Column(
              children: [
                const TopBar(showMenu: false, heading: 'SETTINGS'),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Settings",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
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
                                    onChanged: (v) =>
                                        setState(() => emailNotif = v),
                                  ),
                                ),
                                SettingsTile(
                                  icon: Icons.notifications,
                                  title: "Push Notifications",
                                  trailing: Switch(
                                    value: pushNotif,
                                    onChanged: (v) =>
                                        setState(() => pushNotif = v),
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
