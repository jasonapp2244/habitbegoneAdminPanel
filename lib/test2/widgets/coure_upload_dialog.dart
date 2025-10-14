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

  html.File? selectedFile;
  String? uploadedUrl;
  bool _uploading = false;
  double _progress = 0.0;
  String fileType = '';
  String? _selectedCategory;

  //// Course Categories
  final List<String> _categories = [
    'Osteotherapy',
    'Physiotherapy',
    'Hypnotherapy',
    'Electromagnetic Therapy',
  ];

  //// Pick a file (image, video, or PDF)
  Future<void> _pickFile() async {
    final uploadInput = html.FileUploadInputElement()
      ..accept = 'video/*,image/*,application/pdf'
      ..click();

    uploadInput.onChange.listen((event) {
      final file = uploadInput.files?.first;
      if (file != null) {
        setState(() {
          selectedFile = file;
          fileType = file.type.startsWith('video')
              ? 'video'
              : file.type.startsWith('image')
              ? 'image'
              : 'document';
        });
      }
    });
  }

  /// Upload file to Firebase Storage with progress
  Future<void> _uploadToFirebase() async {
    if (selectedFile == null) return;

    setState(() {
      _uploading = true;
      _progress = 0.0;
    });

    final reader = html.FileReader();
    reader.readAsArrayBuffer(selectedFile!);
    await reader.onLoad.first;

    final data = reader.result as List<int>;
    final fileName = "${const Uuid().v4()}_${selectedFile!.name}";
    final ref = FirebaseStorage.instance.ref().child(
      "course_uploads/$_selectedCategory/$fileName",
    );

    final uploadTask = ref.putData(
      Uint8List.fromList(data),
      SettableMetadata(contentType: selectedFile!.type),
    );

    // Listen to progress
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      setState(() {
        _progress = snapshot.bytesTransferred / snapshot.totalBytes;
      });
    });

    final snapshot = await uploadTask.whenComplete(() {});
    uploadedUrl = await snapshot.ref.getDownloadURL();

    setState(() => _uploading = false);
  }

  /// Save course metadata in Firestore
  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a category")));
      return;
    }

    await _uploadToFirebase();

    if (uploadedUrl == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please upload a file first")),
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
          'fileUrl': uploadedUrl,
          'fileType': fileType,
          'category': _selectedCategory,
          'uploadedAt': FieldValue.serverTimestamp(),
        });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Course uploaded successfully ✅")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Upload New Course Lesson"),
      content: SizedBox(
        width: 400,
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

                if (selectedFile != null)
                  Column(
                    children: [
                      Text("Selected File: ${selectedFile!.name}"),
                      const SizedBox(height: 8),
                      if (fileType == 'image')
                        Image.network(
                          html.Url.createObjectUrlFromBlob(selectedFile!),
                          width: 200,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      if (fileType == 'video')
                        const Icon(
                          Icons.videocam,
                          size: 80,
                          color: Colors.blue,
                        ),
                      if (fileType == 'document')
                        const Icon(
                          Icons.picture_as_pdf,
                          size: 80,
                          color: Colors.red,
                        ),
                    ],
                  ),

                const SizedBox(height: 15),
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: const Text("Pick File"),
                ),
                const SizedBox(height: 15),

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
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _uploading ? null : _saveCourse,
          child: _uploading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(),
                )
              : const Text("Save"),
        ),
      ],
    );
  }
}

// workfine but modified for performance

// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:uuid/uuid.dart';

// class CourseUploadDialog extends StatefulWidget {
//   const CourseUploadDialog({super.key});

//   @override
//   State<CourseUploadDialog> createState() => _CourseUploadDialogState();
// }

// class _CourseUploadDialogState extends State<CourseUploadDialog> {
//   final _formKey = GlobalKey<FormState>();

//   final _titleCtrl = TextEditingController();
//   final _descCtrl = TextEditingController();
//   final _categoryCtrl = TextEditingController();

//   html.File? selectedFile;
//   String? uploadedUrl;
//   bool _uploading = false;
//   String fileType = '';

//   /// Pick a file (image, video, or doc)
//   Future<void> _pickFile() async {
//     final uploadInput = html.FileUploadInputElement()
//       ..accept = 'video/*,image/*,application/pdf'
//       ..click();

//     uploadInput.onChange.listen((event) {
//       final file = uploadInput.files?.first;
//       if (file != null) {
//         setState(() {
//           selectedFile = file;
//           fileType = file.type.startsWith('video')
//               ? 'video'
//               : file.type.startsWith('image')
//               ? 'image'
//               : 'document';
//         });
//       }
//     });
//   }

//   /// Upload file to Firebase Storage
//   double _uploadProgress = 0.0;

//   Future<void> _uploadToFirebase() async {
//     if (selectedFile == null) return;

//     setState(() {
//       _uploading = true;
//       _uploadProgress = 0.0;
//     });

//     try {
//       final reader = html.FileReader();
//       reader.readAsArrayBuffer(selectedFile!);
//       await reader.onLoad.first;

//       final data = reader.result as List<int>;
//       final fileName = "${const Uuid().v4()}_${selectedFile!.name}";
//       final ref = FirebaseStorage.instance.ref().child("uploads/$fileName");

//       final uploadTask = ref.putData(
//         Uint8List.fromList(data),
//         SettableMetadata(contentType: selectedFile!.type),
//       );

//       // ✅ Listen to upload progress
//       uploadTask.snapshotEvents.listen((event) {
//         final progress = event.bytesTransferred / event.totalBytes;
//         setState(() => _uploadProgress = progress);
//       });

//       // ✅ Wait for completion
//       final snapshot = await uploadTask;
//       uploadedUrl = await snapshot.ref.getDownloadURL();

//       debugPrint("✅ Uploaded successfully: $uploadedUrl");
//     } catch (e) {
//       debugPrint("❌ Upload error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Upload failed: $e")));
//       }
//     } finally {
//       setState(() => _uploading = false);
//     }
//   }

//   /// Save metadata in Firestore
//   Future<void> _saveCourse() async {
//     if (!_formKey.currentState!.validate()) return;

//     await _uploadToFirebase();

//     if (uploadedUrl == null && mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text("Please upload a file")));
//       return;
//     }

//     try {
//       final courseId = const Uuid().v4();

//       await FirebaseFirestore.instance.collection('courses').doc(courseId).set({
//         'id': courseId,
//         'title': _titleCtrl.text,
//         'description': _descCtrl.text,
//         'category': _categoryCtrl.text,
//         'fileUrl': uploadedUrl,
//         'fileType': fileType,
//         'uploadedAt': FieldValue.serverTimestamp(),
//       });

//       debugPrint("✅ Course saved successfully in Firestore");
//       if (mounted) Navigator.pop(context);
//     } catch (e) {
//       debugPrint("❌ Firestore error: $e");
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text("Error saving course: $e")));
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text("Upload New Course"),
//       content: SizedBox(
//         width: 400,
//         child: Form(
//           key: _formKey,
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 TextFormField(
//                   controller: _titleCtrl,
//                   decoration: const InputDecoration(labelText: "Course Title"),
//                   validator: (v) => v!.isEmpty ? 'Enter title' : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _descCtrl,
//                   decoration: const InputDecoration(
//                     labelText: "Course Description",
//                   ),
//                   validator: (v) => v!.isEmpty ? 'Enter description' : null,
//                 ),
//                 const SizedBox(height: 10),
//                 TextFormField(
//                   controller: _categoryCtrl,
//                   decoration: const InputDecoration(
//                     labelText: "Course Category",
//                   ),
//                   validator: (v) => v!.isEmpty ? 'Enter category' : null,
//                 ),
//                 const SizedBox(height: 20),

//                 if (selectedFile != null)
//                   Text("Selected File: ${selectedFile!.name}"),

//                 const SizedBox(height: 10),
//                 ElevatedButton.icon(
//                   onPressed: _pickFile,
//                   icon: const Icon(Icons.upload_file),
//                   label: const Text("Pick File"),
//                 ),
//                 if (_uploading) ...[
//                   LinearProgressIndicator(value: _uploadProgress),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Uploading: ${(_uploadProgress * 100).toStringAsFixed(1)}%",
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//                 if (selectedFile != null)
//                   Column(
//                     children: [
//                       Text("Selected File: ${selectedFile!.name}"),
//                       if (fileType == 'image')
//                         Image.network(
//                           html.Url.createObjectUrlFromBlob(selectedFile!),
//                           width: 200,
//                           height: 120,
//                           fit: BoxFit.cover,
//                         ),
//                       if (fileType == 'video')
//                         const Icon(
//                           Icons.videocam,
//                           size: 80,
//                           color: Colors.blue,
//                         ),
//                       if (fileType == 'document')
//                         const Icon(
//                           Icons.picture_as_pdf,
//                           size: 80,
//                           color: Colors.red,
//                         ),
//                     ],
//                   ),
//                 const SizedBox(height: 20),

//                 // ✅ Progress Bar
//               ],
//             ),
//           ),
//         ),
//       ),
//       actions: [
//         TextButton(
//           onPressed: _uploading ? null : () => Navigator.pop(context),
//           child: const Text("Cancel"),
//         ),
//         ElevatedButton(
//           onPressed: _uploading ? null : _saveCourse,
//           child: Text(_uploading ? "Uploading..." : "Save"),
//         ),
//       ],
//     );
//   }
// }
