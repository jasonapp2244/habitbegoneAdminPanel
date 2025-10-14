import 'package:habitbegone_admin/test2/provider/theme_provider.dart';
import 'package:habitbegone_admin/test2/widgets/setting_section.dart';
import 'package:habitbegone_admin/test2/widgets/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsMobile extends StatefulWidget {
  const SettingsMobile({super.key});

  @override
  State<SettingsMobile> createState() => _SettingsMobileState();
}

class _SettingsMobileState extends State<SettingsMobile> {
  bool emailNotif = true;
  bool pushNotif = true;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emailNotif = prefs.getBool('emailNotif') ?? true;
      pushNotif = prefs.getBool('pushNotif') ?? true;
      isLoading = false;
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('emailNotif', emailNotif);
    await prefs.setBool('pushNotif', pushNotif);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 16),
            SettingsSection(
              title: "Notifications",
              children: [
                SettingsTile(
                  icon: Icons.email,
                  title: "Email Notifications",
                  trailing: Switch(
                    value: emailNotif,
                    onChanged: (v) {
                      setState(() => emailNotif = v);
                      _savePrefs();
                    },
                  ),
                ),
                SettingsTile(
                  icon: Icons.notifications,
                  title: "Push Notifications",
                  trailing: Switch(
                    value: pushNotif,
                    onChanged: (v) {
                      setState(() => pushNotif = v);
                      _savePrefs();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
