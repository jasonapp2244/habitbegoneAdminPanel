import 'dart:html' as html;
import 'package:habitbegone_admin/test2/model/user_model.dart';
import 'package:flutter/material.dart';

class UserDetailScreen extends StatelessWidget {
  final AppUserModel user;

  const UserDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User Details - ${user.name}"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- User Info ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  child: Text(
                    user.name.substring(0, 1),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Chip(
                      label: Text(user.role),
                      backgroundColor: Colors.blue.shade50,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text("Status: "),
                        Text(
                          user.isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: user.isActive ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // --- Uploaded Files Section ---
            Text(
              "Uploaded Files",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildFilePreviewGrid(context),

            const SizedBox(height: 32),

            // --- Support Messages Section ---
            Text(
              "Support Messages",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildSupportMessages(),

            const SizedBox(height: 32),

            // --- History Section ---
            Text(
              "User Activity History",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildHistoryLog(),
          ],
        ),
      ),
    );
  }

  // --- File Previews Grid ---
  Widget _buildFilePreviewGrid(BuildContext context) {
    final uploads =
        user.uploadedFiles ??
        [
          "https://via.placeholder.com/150",
          "https://via.placeholder.com/200",
          "document1.pdf",
          "notes.txt",
        ];

    return uploads.isEmpty
        ? const Text("No uploaded files yet.")
        : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: uploads.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final file = uploads[index];
              final isImage =
                  file.endsWith(".png") ||
                  file.endsWith(".jpg") ||
                  file.endsWith(".jpeg") ||
                  file.startsWith("http");

              return GestureDetector(
                onTap: () {
                  if (isImage) {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        child: InteractiveViewer(
                          child: Image.network(file, fit: BoxFit.contain),
                        ),
                      ),
                    );
                  } else {
                    html.window.open(file, "_blank");
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  elevation: 2,
                  child: isImage
                      ? Image.network(file, fit: BoxFit.cover)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.insert_drive_file,
                                size: 32,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                file.split('/').last,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                ),
              );
            },
          );
  }

  // --- Support Messages ---
  Widget _buildSupportMessages() {
    final messages =
        user.supportMessages ??
        [
          {"date": "2025-10-10", "msg": "Unable to upload file."},
          {"date": "2025-10-09", "msg": "Request for account activation."},
        ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: messages.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final msg = messages[i];
          return ListTile(
            leading: const Icon(Icons.message_outlined, color: Colors.blue),
            title: Text(msg["msg"] ?? ""),
            subtitle: Text(msg["date"] ?? ""),
          );
        },
      ),
    );
  }

  // --- History Log ---
  Widget _buildHistoryLog() {
    final history =
        user.history ??
        [
          {"date": "2025-10-11", "action": "Logged in"},
          {"date": "2025-10-10", "action": "Uploaded file: report.pdf"},
          {"date": "2025-10-09", "action": "Changed password"},
        ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: history.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final h = history[i];
          return ListTile(
            leading: const Icon(Icons.history, color: Colors.grey),
            title: Text(h["action"] ?? ""),
            subtitle: Text(h["date"] ?? ""),
          );
        },
      ),
    );
  }
}

// import 'package:habitbegone_admin/test2/model/user_model.dart';
// import 'package:flutter/material.dart';

// class UserDetailScreen extends StatefulWidget {
//   final AppUserModel user;
//   const UserDetailScreen({super.key, required this.user});

//   @override
//   State<UserDetailScreen> createState() => _UserDetailScreenState();
// }

// class _UserDetailScreenState extends State<UserDetailScreen> {
//   int selectedTab = 0;

//   final List<String> tabs = ["Profile", "Uploads", "Support", "History"];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("User Details - ${widget.user.name}"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: Row(
//         children: [
//           // Sidebar navigation
//           Container(
//             width: 220,
//             color: Colors.blueGrey.shade50,
//             child: Column(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   child: CircleAvatar(
//                     radius: 40,
//                     backgroundColor: Colors.blue.shade100,
//                     child: Text(
//                       widget.user.name[0],
//                       style: const TextStyle(fontSize: 32),
//                     ),
//                   ),
//                 ),
//                 Text(widget.user.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 4),
//                 Text(widget.user.email,
//                     style: const TextStyle(color: Colors.grey)),
//                 const SizedBox(height: 16),
//                 Divider(),
//                 ...tabs.asMap().entries.map((entry) {
//                   int index = entry.key;
//                   String title = entry.value;
//                   return ListTile(
//                     title: Text(title),
//                     leading: Icon(
//                       index == 0
//                           ? Icons.person
//                           : index == 1
//                               ? Icons.upload
//                               : index == 2
//                                   ? Icons.support_agent
//                                   : Icons.history,
//                     ),
//                     selected: selectedTab == index,
//                     onTap: () => setState(() => selectedTab = index),
//                   );
//                 }),
//               ],
//             ),
//           ),

//           // Main content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(24),
//               child: IndexedStack(
//                 index: selectedTab,
//                 children: [
//                   _buildProfileTab(),
//                   _buildUploadsTab(),
//                   _buildSupportTab(),
//                   _buildHistoryTab(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // PROFILE TAB
//   Widget _buildProfileTab() {
//     final user = widget.user;
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Profile Information",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const Divider(height: 24),
//             _infoRow("Full Name", user.name),
//             _infoRow("Email", user.email),
//             _infoRow("Role", user.role),
//             _infoRow("Status", user.isActive ? "Active" : "Inactive",
//                 valueColor: user.isActive ? Colors.green : Colors.red),
//           ],
//         ),
//       ),
//     );
//   }

//   // UPLOADS TAB
//   Widget _buildUploadsTab() {
//     // In a real app, fetch from backend
//     final uploads = [
//       {"file": "invoice_2025.pdf", "date": "Oct 5, 2025"},
//       {"file": "profile_photo.png", "date": "Sep 29, 2025"},
//     ];

//     return _dataListSection("User Uploads", uploads, "file", "date");
//   }

//   // SUPPORT TAB
//   Widget _buildSupportTab() {
//     final messages = [
//       {"subject": "Login issue", "status": "Resolved"},
//       {"subject": "Payment not showing", "status": "Open"},
//     ];

//     return _dataListSection("Support Messages", messages, "subject", "status");
//   }

//   // HISTORY TAB
//   Widget _buildHistoryTab() {
//     final history = [
//       {"event": "Logged in", "date": "Oct 10, 2025"},
//       {"event": "Updated profile", "date": "Oct 9, 2025"},
//       {"event": "Made a purchase", "date": "Oct 8, 2025"},
//     ];

//     return _dataListSection("User Activity History", history, "event", "date");
//   }

//   // Reusable info row
//   Widget _infoRow(String label, String value, {Color? valueColor}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label,
//               style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
//           Text(value,
//               style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: valueColor ?? Colors.black87)),
//         ],
//       ),
//     );
//   }

//   // Reusable table-like section
//   Widget _dataListSection(String title, List<Map<String, String>> data,
//       String key1, String key2) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title,
//                 style:
//                     const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             const Divider(height: 24),
//             Expanded(
//               child: ListView.separated(
//                 itemCount: data.length,
//                 separatorBuilder: (_, __) => const Divider(),
//                 itemBuilder: (_, i) => Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(data[i][key1]!,
//                         style: const TextStyle(fontSize: 16)),
//                     Text(data[i][key2]!,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, color: Colors.grey)),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
