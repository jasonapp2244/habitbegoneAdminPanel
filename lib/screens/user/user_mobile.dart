// import 'package:habitbegone_admin/test2/model/user_model.dart';
// import 'package:habitbegone_admin/test2/widgets/user_card.dart';
// import 'package:habitbegone_admin/test2/widgets/user_eidt_dialog.dart';
// import 'package:flutter/material.dart';

// class UsersMobile extends StatefulWidget {
//   const UsersMobile({super.key});

//   @override
//   State<UsersMobile> createState() => _UsersMobileState();
// }

// class _UsersMobileState extends State<UsersMobile> {
//   List<AppUserModel> users = [
//     AppUserModel(
//       id: "1",
//       name: "Alice Johnson",
//       email: "alice@example.com",
//       role: "Admin",
//       isActive: true,
//     ),
//     AppUserModel(
//       id: "2",
//       name: "Bob Smith",
//       email: "bob@example.com",
//       role: "Editor",
//       isActive: false,
//     ),
//     AppUserModel(
//       id: "3",
//       name: "Carla Gomez",
//       email: "carla@example.com",
//       role: "Manager",
//       isActive: true,
//     ),
//   ];

//   void toggleStatus(AppUserModel user) {
//     setState(() {
//       user.isActive = !user.isActive;
//     });
//   }

//   void editUser(AppUserModel user) async {
//     final updatedUser = await showDialog<AppUserModel>(
//       context: context,
//       builder: (_) => UserEditDialog(user: user),
//     );

//     if (updatedUser != null) {
//       setState(() {
//         final index = users.indexWhere((u) => u.id == updatedUser.id);
//         if (index != -1) {
//           users[index] = updatedUser;
//         }
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Users")),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Card(
//               elevation: 3,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text(
//                       "Total Users",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       "${users.length}",
//                       style: const TextStyle(fontSize: 18),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: users.length,
//                 itemBuilder: (context, index) {
//                   final user = users[index];
//                   return UserCard(
//                     user: user,
//                     onToggle: () => toggleStatus(user),
//                     onEdit: () => editUser(user),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
