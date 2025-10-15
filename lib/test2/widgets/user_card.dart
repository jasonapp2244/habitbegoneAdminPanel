import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/model/app-user_model.dart';
import 'package:habitbegone_admin/test2/model/user_model.dart';

class UserCard extends StatelessWidget {
  final AppUserModel user;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const UserCard({
    super.key,
    required this.user,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isActive ? Colors.green : Colors.grey,
          child: Text(user.name[0]),
        ),
        title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        // subtitle: Text("${user.email}\nRole: ${user.role}"),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 8,
          children: [
            Switch(
              value: user.isActive,
              onChanged: (_) => onToggle(),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
      ),
    );
  }
}
