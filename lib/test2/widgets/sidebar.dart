import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/screens/cousre/coure_upload.dart';
import 'package:habitbegone_admin/test2/screens/dashboard/dashboard_view.dart';
import 'package:habitbegone_admin/test2/screens/setting/setting.dart';
import 'package:habitbegone_admin/test2/screens/user/users.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.zero),
            ),
            child: Text(
              "Admin Panel",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DashboardScreen()),
            ),
            leading: Icon(Icons.dashboard),
            title: Text("Dashboard"),
          ),
          // UsersScreen
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UsersScreen()),
            ),
            leading: Icon(Icons.people),
            title: Text("Users"),
          ),
          ListTile(leading: Icon(Icons.shopping_cart), title: Text("Orders")),
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            ),
            leading: Icon(Icons.settings),
            title: Text("Settings"),
          ),
          ListTile(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CoursesWeb()),
            ),
            leading: Icon(Icons.settings),
            title: Text("Course"),
          ),
        ],
      ),
    );
  }
}
