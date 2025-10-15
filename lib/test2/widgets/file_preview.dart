import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/model/coure_model.dart';
import 'package:video_player/video_player.dart';

class FilePreviewWidget extends StatefulWidget {
  final CourseModel lesson;
  const FilePreviewWidget({super.key, required this.lesson});

  @override
  State<FilePreviewWidget> createState() => _FilePreviewWidgetState();
}

class _FilePreviewWidgetState extends State<FilePreviewWidget> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.lesson.fileType == 'video') {
      _controller = VideoPlayerController.network(widget.lesson.fileUrl)
        ..initialize().then((_) {
          setState(() => _initialized = true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;

    if (lesson.fileType == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          lesson.fileUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
        ),
      );
    } else if (lesson.fileType == 'video') {
      if (!_initialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return
       AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller!),
            IconButton(
              icon: Icon(
                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
            ),
          ],
        ),
      );
    } else if (lesson.fileType == 'document') {
      return const Icon(Icons.picture_as_pdf, size: 60, color: Colors.red);
    } else {
      return const Icon(Icons.insert_drive_file, size: 60);
    }
  }
}

















// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:url_launcher/url_launcher.dart';

// class FilePreviewWidget extends StatefulWidget {
//   final String fileUrl;
//   final String fileType;

//   const FilePreviewWidget({
//     super.key,
//     required this.fileUrl,
//     required this.fileType,
//   });

//   @override
//   State<FilePreviewWidget> createState() => _FilePreviewWidgetState();
// }

// class _FilePreviewWidgetState extends State<FilePreviewWidget> {
//   VideoPlayerController? _videoController;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.fileType.contains("video")) {
//       _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.fileUrl))
//         ..initialize().then((_) => setState(() {}));
//     }
//   }

//   @override
//   void dispose() {
//     _videoController?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.fileType.contains("image")) {
//       return CachedNetworkImage(
//         imageUrl: widget.fileUrl,
//         fit: BoxFit.cover,
//         placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
//         errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
//       );
//     }

//     if (widget.fileType.contains("video")) {
//       if (_videoController == null || !_videoController!.value.isInitialized) {
//         return const Center(child: CircularProgressIndicator());
//       }
//       return AspectRatio(
//         aspectRatio: _videoController!.value.aspectRatio,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             VideoPlayer(_videoController!),
//             Positioned(
//               bottom: 10,
//               child: IconButton(
//                 icon: Icon(
//                   _videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
//                   color: Colors.white,
//                   size: 40,
//                 ),
//                 onPressed: () {
//                   setState(() {
//                     _videoController!.value.isPlaying
//                         ? _videoController!.pause()
//                         : _videoController!.play();
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (widget.fileType.contains("pdf")) {
//       return InkWell(
//         onTap: () => launchUrl(Uri.parse(widget.fileUrl)),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: const [
//             Icon(Icons.picture_as_pdf, color: Colors.red, size: 60),
//             Text("Open PDF Document", style: TextStyle(fontSize: 16)),
//           ],
//         ),
//       );
//     }

//     // Other docs (Word, text, etc.)
//     return InkWell(
//       onTap: () => launchUrl(Uri.parse(widget.fileUrl)),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: const [
//           Icon(Icons.insert_drive_file, color: Colors.blueGrey, size: 60),
//           Text("Open Document", style: TextStyle(fontSize: 16)),
//         ],
//       ),
//     );
//   }
// }
