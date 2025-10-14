import 'package:habitbegone_admin/test2/model/user_model.dart';
import 'package:habitbegone_admin/test2/widgets/user_card.dart';
import 'package:habitbegone_admin/test2/widgets/user_eidt_dialog.dart';
import 'package:flutter/material.dart';

class UsersTablet extends StatefulWidget {
  const UsersTablet({super.key});

  @override
  State<UsersTablet> createState() => _UsersTabletState();
}

class _UsersTabletState extends State<UsersTablet> {
  List<AppUserModel> users = [
    AppUserModel(
      id: "1",
      name: "Alice Johnson",
      email: "alice@example.com",
      role: "Admin",
      isActive: true,
    ),
    AppUserModel(
      id: "2",
      name: "Bob Smith",
      email: "bob@example.com",
      role: "Editor",
      isActive: false,
    ),
  ];

  void toggleStatus(AppUserModel user) =>
      setState(() => user.isActive = !user.isActive);
  void editUser(AppUserModel user) async {
    final updated = await showDialog<AppUserModel>(
      context: context,
      builder: (_) => UserEditDialog(user: user),
    );
    if (updated != null) {
      setState(() {
        final index = users.indexWhere((u) => u.id == updated.id);
        users[index] = updated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 3.5,
          children: users.map((u) {
            return UserCard(
              user: u,
              onToggle: () => toggleStatus(u),
              onEdit: () => editUser(u),
            );
          }).toList(),
        ),
      ),
    );
  }
}
