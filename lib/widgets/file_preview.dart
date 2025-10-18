import 'package:flutter/material.dart';
import 'package:habitbegone_admin/model/coure_model.dart';
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