import 'package:habitbegone_admin/test2/model/app-user_model.dart';
import 'package:habitbegone_admin/test2/model/user_model.dart';
import 'package:flutter/material.dart';

extension AppUserModelCopy on AppUserModel {
  AppUserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    bool? isActive,
    bool? isBlocked

  }) {
    return AppUserModel(
      uid: id ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      // role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isPaid: isPaid,
      emailVerified: emailVerified,
      joinedAt: joinedAt,
      role: role ?? "standard user", isBlocked: isBlocked ?? false,
    );
  }
}

class UserEditDialog extends StatefulWidget {
  final AppUserModel user;

  const UserEditDialog({super.key, required this.user});

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late String _selectedRole;
  late bool _isActive;

  final List<String> roles = ["admin","manager", "user"];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _emailController = TextEditingController(text: widget.user.email);

    // ✅ ensure role exists, else default to first role
    _selectedRole = roles.contains(widget.user.role)
        ? widget.user.role
        : roles.first;

    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _save() {
    final updated = widget.user.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _selectedRole,
      isActive: _isActive,
    );
    Navigator.pop(context, updated);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit User"),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              // value: _selectedRole,
              initialValue: roles.contains(_selectedRole)
                  ? _selectedRole
                  : roles.first,

              items: roles
                  .map(
                    (role) => DropdownMenuItem(value: role, child: Text(role)),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _selectedRole = value!),
              decoration: const InputDecoration(labelText: "Role"),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text("Active"),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: _save, child: const Text("Save")),
      ],
    );
  }
}

// import 'package:habitbegone_admin/test2/model/user_model.dart';
// import 'package:flutter/material.dart';
// class UserEditDialog extends StatefulWidget {
//   final AppUserModel user;
//   const UserEditDialog({super.key, required this.user});

//   @override
//   State<UserEditDialog> createState() => _UserEditDialogState();
// }

// class _UserEditDialogState extends State<UserEditDialog> {
//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   late String role;
//   late bool isActive;

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.user.name);
//     emailController = TextEditingController(text: widget.user.email);
//     role = widget.user.role;
//     isActive = widget.user.isActive;
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Edit User"),
//       content: SingleChildScrollView(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: nameController,
//               decoration: const InputDecoration(labelText: "Name"),
//             ),
//             const SizedBox(height: 12),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: "Email"),
//             ),
//             const SizedBox(height: 12),
//             DropdownButtonFormField<String>(
//               value: role,
//               decoration: const InputDecoration(labelText: "Role"),
//               items: const [
//                 DropdownMenuItem(value: "Admin", child: Text("Admin")),
//                 DropdownMenuItem(value: "Editor", child: Text("Editor")),
//                 DropdownMenuItem(value: "Manager", child: Text("Manager")),
//               ],
//               onChanged: (val) => setState(() => role = val ?? role),
//             ),
//             const SizedBox(height: 12),
//             SwitchListTile(
//               title: const Text("Active"),
//               value: isActive,
//               onChanged: (val) => setState(() => isActive = val),
//             ),
//           ],
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: () {
//             Navigator.pop(
//               context,
//               AppUserModel(
//                 id: widget.user.id,
//                 name: nameController.text,
//                 email: emailController.text,
//                 role: role,
//                 isActive: isActive,
//               ),
//             );
//           },
//           child: const Text("Save"),
//         ),
//       ],
//     );
//   }
// }
