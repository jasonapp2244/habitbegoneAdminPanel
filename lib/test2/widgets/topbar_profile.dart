import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/provider/user_provider.dart';
import 'package:habitbegone_admin/test2/screens/profile/profile_view.dart';
import 'package:provider/provider.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showMenu;
  final String heading;
  const TopBar({super.key, required this.showMenu, required this.heading});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      leading: showMenu
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: () => Scaffold.of(context).openDrawer(),
            )
          : null,
      title: Text(heading, style: const TextStyle(color: Colors.black)),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(child: Icon(Icons.person)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Text(
            user?.name ?? 'Loading...', // 👈 dynamic name here
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
