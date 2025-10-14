// import 'package:habitbegone_admin/test2/screens/profile/profile_view.dart';
// import 'package:flutter/material.dart';

// class TopBar extends StatelessWidget implements PreferredSizeWidget {
//   final bool showMenu;
//   const TopBar({super.key, required this.showMenu});

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 2,
//       leading: showMenu
//           ? IconButton(
//               icon: const Icon(Icons.menu, color: Colors.black87),
//               onPressed: () => Scaffold.of(context).openDrawer(),
//             )
//           : null,
//       title: const Text("Dashboard", style: TextStyle(color: Colors.black)),
//       actions: [
//         GestureDetector(
//           onTap: () => Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => ProfileView()),
//           ),
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: CircleAvatar(child: Icon(Icons.person)),
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Size get preferredSize => const Size.fromHeight(56);
// }
