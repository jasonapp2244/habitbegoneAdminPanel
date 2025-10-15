import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class CourseUploadDialog extends StatefulWidget {
  const CourseUploadDialog({super.key});

  @override
  State<CourseUploadDialog> createState() => _CourseUploadDialogState();
}

class _CourseUploadDialogState extends State<CourseUploadDialog> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  List<html.File> selectedFiles = [];
  List<Map<String, String>> uploadedFiles = [];

  bool _uploading = false;
  double _progress = 0.0;
  String? _selectedCategory;

  //// Course Categories
  final List<String> _categories = [
    'Osteotherapy',
    'Physiotherapy',
    'Hypnotherapy',
    'Electromagnetic Therapy',
  ];

  /// Pick multiple files (video, image, or PDF)
  Future<void> _pickFiles() async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'video/*,image/*,application/pdf'
      ..multiple = true
      ..click();

    uploadInput.onChange.listen((event) {
      if (uploadInput.files != null && uploadInput.files!.isNotEmpty) {
        setState(() {
          for (var f in uploadInput.files!) {
            if (!selectedFiles.any((existing) => existing.name == f.name)) {
              selectedFiles.add(f);
            }
          }
        });
      }
    });
  }

  /// Upload all selected files to Firebase Storage
  Future<void> _uploadAllFiles() async {
    if (selectedFiles.isEmpty) return;

    setState(() {
      _uploading = true;
      _progress = 0.0;
    });

    uploadedFiles.clear();

    for (var i = 0; i < selectedFiles.length; i++) {
      final file = selectedFiles[i];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final data = reader.result as List<int>;
      final fileName = "${const Uuid().v4()}_${file.name}";
      final ref = FirebaseStorage.instance.ref().child(
        "course_uploads/$_selectedCategory/$fileName",
      );

      final uploadTask = ref.putData(
        Uint8List.fromList(data),
        SettableMetadata(contentType: file.type),
      );

      // Track progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _progress =
              (i / selectedFiles.length) +
              (snapshot.bytesTransferred / snapshot.totalBytes) /
                  selectedFiles.length;
        });
      });

      final snapshot = await uploadTask.whenComplete(() {});
      final url = await snapshot.ref.getDownloadURL();

      // Detect file type
      final type = file.type.startsWith('video')
          ? 'video'
          : file.type.startsWith('image')
          ? 'image'
          : 'document';

      uploadedFiles.add({'type': type, 'url': url});
    }

    setState(() => _uploading = false);
  }

  /// Save course lesson and its files to Firestore
  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    await _uploadAllFiles();

    if (uploadedFiles.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload at least one file")),
      );
      return;
    }

    final lessonId = const Uuid().v4();

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(_selectedCategory!.toLowerCase().replaceAll(' ', '_'))
        .collection('lessons')
        .doc(lessonId)
        .set({
          'id': lessonId,
          'title': _titleCtrl.text.trim(),
          'description': _descCtrl.text.trim(),
          'category': _selectedCategory,
          'uploadedAt': FieldValue.serverTimestamp(),
          'files': uploadedFiles,
        });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lesson uploaded successfully ✅")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Upload New Course Lesson"),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Category",
                  ),
                  initialValue: _selectedCategory,
                  items: _categories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  validator: (v) => v == null ? "Select a category" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: "Lesson Title"),
                  validator: (v) => v!.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: "Lesson Description",
                  ),
                  validator: (v) => v!.isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 20),

                /// File preview section
                if (selectedFiles.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Selected Files:"),
                      const SizedBox(height: 8),
                      ...selectedFiles.map((f) {
                        final type = f.type.startsWith('video')
                            ? 'video'
                            : f.type.startsWith('image')
                            ? 'image'
                            : 'document';
                        return ListTile(
                          leading: type == 'image'
                              ? Image.network(
                                  html.Url.createObjectUrlFromBlob(f),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Icon(
                                  type == 'video'
                                      ? Icons.videocam
                                      : Icons.picture_as_pdf,
                                  color: type == 'video'
                                      ? Colors.blue
                                      : Colors.red,
                                ),
                          title: Text(f.name),
                        );
                      }),
                    ],
                  ),

                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _pickFiles,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Pick Files"),
                ),
                const SizedBox(height: 15),

                /// Upload progress
                if (_uploading)
                  Column(
                    children: [
                      const Text("Uploading..."),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: _progress),
                      const SizedBox(height: 10),
                      Text("${(_progress * 100).toStringAsFixed(1)}%"),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _uploading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _uploading ? null : _saveCourse,
          child: _uploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}

