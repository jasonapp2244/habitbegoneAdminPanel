import 'package:flutter/material.dart';
import 'package:habitbegone_admin/provider/user_provider.dart';
import 'package:provider/provider.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (userProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (user == null) {
      return const Center(child: Text('No user data found'));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name ?? 'No Name',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.role ?? 'User',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                showEditUserDialog(context, userProvider);
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showEditUserDialog(
  BuildContext context,
  UserProvider userProvider,
) async {
  final user = userProvider.user;
  if (user == null) return;

  // Controllers prefilled with current data
  final nameController = TextEditingController(text: user.name ?? '');
  final emailController = TextEditingController(text: user.email);
  final roleController = TextEditingController(text: user.role ?? '');

  final formKey = GlobalKey<FormState>();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Edit Profile"),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter a name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
                validator: (val) =>
                    val == null || val.isEmpty ? "Enter an email" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: roleController,
                decoration: const InputDecoration(labelText: "Role"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Call provider method to update Firestore
                await userProvider.updateUser(
                  name: nameController.text,
                  email: emailController.text,
                  role: roleController.text,
                );

                Navigator.pop(context); // close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("User updated successfully!")),
                );
              }
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}
