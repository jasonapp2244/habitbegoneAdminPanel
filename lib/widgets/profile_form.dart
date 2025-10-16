import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:habitbegone_admin/provider/user_provider.dart';

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Initialize controllers with existing provider data (if available)
    emailController = TextEditingController(text: userProvider.email ?? '');
    phoneController = TextEditingController(text: userProvider.phone ?? '');
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Account Information",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // Email field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your email";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone field
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) return;

                        final userData = {
                          "email": emailController.text.trim(),
                          "phone": phoneController.text.trim(),
                        };

                        // Save to Firestore (each user gets their own doc)
                        await _firestore
                            .collection("app_users")
                            .doc('contact_info')
                            .set(userData, SetOptions(merge: true));

                        // Update provider
                        userProvider.setUserAdminData(
                          emailController.text.trim(),
                          phoneController.text.trim(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Profile saved successfully!"),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error saving profile: $e")),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Save Changes",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:habitbegone_admin/test2/provider/user_provider.dart';
// import 'package:provider/provider.dart';

// class ProfileForm extends StatefulWidget {
//   const ProfileForm({super.key});

//   @override
//   State<ProfileForm> createState() => _ProfileFormState();
// }

// class _ProfileFormState extends State<ProfileForm> {
//   final _formKey = GlobalKey<FormState>();
//   String? name, email, phone, role;
//   final _firestore = FirebaseFirestore.instance;
//   final TextEditingController emailController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final userProvider = Provider.of<UserProvider>(context);

//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               const Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   "Account Information",
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: "Full Name",
//                   border: OutlineInputBorder(),
//                 ),
//                 onSaved: (val) => name = val,
//               ),
//               const SizedBox(height: 16),

//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: "Email Address",
//                   border: OutlineInputBorder(),
//                 ),
//                 onSaved: (val) => email = val,
//               ),
//               const SizedBox(height: 16),

//               TextFormField(
//                 decoration: const InputDecoration(
//                   labelText: "Phone Number",
//                   border: OutlineInputBorder(),
//                 ),
//                 onSaved: (val) => phone = val,
//               ),
//               const SizedBox(height: 16),

//               DropdownButtonFormField<String>(
//                 decoration: const InputDecoration(
//                   labelText: "Role",
//                   border: OutlineInputBorder(),
//                 ),
//                 items: const [
//                   DropdownMenuItem(value: "Admin", child: Text("Admin")),
//                   DropdownMenuItem(value: "Manager", child: Text("Manager")),
//                   DropdownMenuItem(value: "Editor", child: Text("Editor")),
//                 ],
//                 onChanged: (val) => role = val,
//               ),

//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     if (_formKey.currentState!.validate()) {
//                       _formKey.currentState!.save();

//                       try {
//                         // Create a map of data to store
//                         final userData = {"email": email, "phone": phone};
//                         final user = FirebaseAuth.instance.currentUser;

//                         if (user != null) {
//                           // Save to Firestore (for example, in a 'app_users' collection)
//                           await _firestore
//                               .collection("app_users")
//                               .doc("contact_info")
//                               .set(userData);
//                         }

//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Profile saved successfully!"),
//                           ),
//                         );
//                       } catch (e) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(content: Text("Error saving profile: $e")),
//                         );
//                       }
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: const Text(
//                     "Save Changes",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
