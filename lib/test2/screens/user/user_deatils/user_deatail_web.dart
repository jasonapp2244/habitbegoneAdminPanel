import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/model/app-user_model.dart';

class UserDetailScreen extends StatelessWidget {
  final AppUserModel user;

  const UserDetailScreen({super.key, required this.user});

  bool _isImage(String file) =>
      file.endsWith(".png") ||
      file.endsWith(".jpg") ||
      file.endsWith(".jpeg") ||
      file.endsWith(".gif") ||
      file.startsWith("http");

  bool _isVideo(String file) =>
      file.endsWith(".mp4") ||
      file.endsWith(".mov") ||
      file.endsWith(".webm") ||
      file.endsWith(".mkv");

  bool _isDocument(String file) =>
      file.endsWith(".pdf") ||
      file.endsWith(".doc") ||
      file.endsWith(".docx") ||
      file.endsWith(".txt");

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
            _buildUserInfo(),
            const SizedBox(height: 32),
            _buildSectionTitle(context, "Uploaded Files"),
            _buildFilePreviewGrid(context),
            const SizedBox(height: 32),
            _buildSectionTitle(context, "Support Messages"),
            _buildSupportMessages(),
            const SizedBox(height: 32),
            _buildSectionTitle(context, "User Activity History"),
            _buildHistoryLog(),
          ],
        ),
      ),
    );
  }

  // --- Header Info ---
  Widget _buildUserInfo() {
    return Row(
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(user.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Chip(label: Text(user.role), backgroundColor: Colors.blue.shade50),
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
    );
  }

  // --- Title Builder ---
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  // --- File Preview Grid ---
  Widget _buildFilePreviewGrid(BuildContext context) {
    final uploads =
        user.uploadedFiles ??
        [
          // "https://via.placeholder.com/150",
          // "https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4",
          // "https://example.com/document1.pdf",
        ];

    if (uploads.isEmpty) return const Text("No uploaded files yet.");

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: uploads.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final file = uploads[index];
        return _buildFileCard(context, file);
      },
    );
  }

  Widget _buildFileCard(BuildContext context, String file) {
    final isImg = _isImage(file);
    final isVid = _isVideo(file);
    final isDoc = _isDocument(file);
    if (file.isEmpty) return const Text("No uploaded files yet.");
    return GestureDetector(
      onTap: () {
        if (isImg) {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              child: InteractiveViewer(
                child: Image.network(file, fit: BoxFit.contain),
              ),
            ),
          );
        } else if (isVid) {
          // _showVideoDialog(context, file);
        } else if (isDoc) {
          html.window.open(file, "_blank");
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: isImg
                  ? Image.network(file, fit: BoxFit.cover)
                  : Container(
                      color: Colors.grey.shade100,
                      child: Center(
                        child: isVid
                            ? const Icon(
                                Icons.videocam,
                                size: 48,
                                color: Colors.blue,
                              )
                            : isDoc
                            ? const Icon(
                                Icons.picture_as_pdf,
                                size: 48,
                                color: Colors.red,
                              )
                            : const Icon(
                                Icons.insert_drive_file,
                                size: 48,
                                color: Colors.grey,
                              ),
                      ),
                    ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              right: 6,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(4),
                child: Text(
                  file.split('/').last,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// --- FIXED VIDEO PREVIEW (Web Compatible) ---
  // void _showVideoDialog(BuildContext context, String fileUrl) {
  //   // Register a unique view type for each video
  //   final viewId = 'video-${fileUrl.hashCode}';
  //   // ignore: undefined_prefixed_name
  //   ui.platformViewRegistry.registerViewFactory(
  //     viewId,
  //     (int _) {
  //       final iframe = html.IFrameElement()
  //         ..src = fileUrl
  //         ..style.border = 'none'
  //         ..allowFullscreen = true
  //         ..allow = 'autoplay; fullscreen';
  //       return iframe;
  //     },
  //   );

  //   showDialog(
  //     context: context,
  //     builder: (_) => Dialog(
  //       insetPadding: const EdgeInsets.all(16),
  //       child: AspectRatio(
  //         aspectRatio: 16 / 9,
  //         child: HtmlElementView(viewType: viewId),
  //       ),
  //     ),
  //   );
  // }

  // --- Support Messages ---
  Widget _buildSupportMessages() {
    final messages =
        user.supportMessages ??
        [
          // {"date": "2025-10-10", "msg": "Unable to upload file."},
          // {"date": "2025-10-09", "msg": "Request for account activation."},
          // {"date": "2025-10-10", "msg": "Unable to upload file."},
          // {"date": "2025-10-09", "msg": "Request for account activation."},
          // {"date": "2025-10-10", "msg": "Unable to upload file."},
          // {"date": "2025-10-09", "msg": "Request for account activation."},
        ];
    if (messages.isEmpty) return const Text("No messages yet.");
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
          // {"date": "2025-10-11", "action": "Logged in"},
          // {"date": "2025-10-10", "action": "Uploaded file: report.pdf"},
          // {"date": "2025-10-09", "action": "Changed password"},
          // {"date": "2025-10-11", "action": "Logged in"},
          // {"date": "2025-10-10", "action": "Uploaded file: report.pdf"},
          // {"date": "2025-10-09", "action": "Changed password"},
          // {"date": "2025-10-11", "action": "Logged in"},
          // {"date": "2025-10-10", "action": "Uploaded file: report.pdf"},
          // {"date": "2025-10-09", "action": "Changed password"},
          // {"date": "2025-10-11", "action": "Logged in"},
          // {"date": "2025-10-10", "action": "Uploaded file: report.pdf"},
          // {"date": "2025-10-09", "action": "Changed password"},
        ];
    if (history.isEmpty) return const Text("No history yet.");
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