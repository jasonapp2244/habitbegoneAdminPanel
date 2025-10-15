import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/model/coure_model.dart';
import 'package:habitbegone_admin/test2/service/cousre_service.dart';
import 'package:habitbegone_admin/test2/widgets/coure_upload_dialog.dart';
import 'package:habitbegone_admin/test2/widgets/file_preview.dart';

class CoursesWeb extends StatefulWidget {
  const CoursesWeb({super.key});

  @override
  State<CoursesWeb> createState() => _CoursesWebState();
}

class _CoursesWebState extends State<CoursesWeb> {
  final CourseService _courseService = CourseService();

  String? _selectedCategory;
  final List<String> _categories = [
    'Osteotherapy',
    'Physiotherapy',
    'Hypnotherapy',
    'Electromagnetic Therapy',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Courses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const CourseUploadDialog(),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🟦 Category Selector
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              value: _selectedCategory,
              hint: const Text("Select Category"),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
          ),

          // 🟨 Lessons List
          Expanded(
            child: _selectedCategory == null
                ? const Center(child: Text("Please select a category."))
                : StreamBuilder<List<CourseModel>>(
                    stream: _courseService.getLessonsByCategory(
                      _selectedCategory!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("No lessons found."));
                      }

                      final lessons = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.2,
                            ),
                        itemCount: lessons.length,
                        itemBuilder: (context, i) {
                          final lesson = lessons[i];
                          return 
                          Card(
                            elevation: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 🖼 Preview
                                  Expanded(
                                    child: Center(
                                      // child: _buildFilePreview(lesson),
                                      child:buildFileList(lesson.files), 
                                      // FilePreviewWidget(lesson: lesson),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    lesson.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    lesson.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        lesson.category,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () async {
                                          await _courseService.deleteLesson(
                                            lesson.category,
                                            lesson.id,
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// 🖼 Helper: Builds image/video/document preview
  Widget buildFileList(List<Map<String, dynamic>> files) {
  return GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.2,
    ),
    itemCount: files.length,
    itemBuilder: (context, index) {
      final file = files[index];
      return FilePreviewWidget(
        lesson: CourseModel(
          fileType: file['type'],
          fileUrl: file['url'],
          title: '',
          description: '',
          id: '',
          category: '', courseId: '', thumbnailUrl: '', videoUrl: '', duration: '', uploadedAt: null, files: [],
        ),
      );
    },
  );
}

}

// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:habitbegone_admin/test2/model/coure_model.dart';
// import 'package:habitbegone_admin/test2/service/cousre_service.dart';
// import 'package:habitbegone_admin/test2/widgets/coure_upload_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
// import 'package:habitbegone_admin/test2/widgets/videoplayer_widget.dart';

// class CoursesWeb extends StatefulWidget {
//   const CoursesWeb({super.key});

//   @override
//   State<CoursesWeb> createState() => _CoursesWebState();
// }

// class _CoursesWebState extends State<CoursesWeb> {
//   List<CourseModel> allCourses = [];
//   List<CourseModel> get filteredCourses {
//     final q = searchQuery.toLowerCase();
//     return allCourses
//         .where(
//           (c) =>
//               c.title.toLowerCase().contains(q) ||
//               c.category.toLowerCase().contains(q),
//         )
//         .toList();
//   }

//   String selectedCategory = 'All';
//   String searchQuery = '';
//   Timer? _debounce;

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     super.dispose();
//   }

//   void _onSearchChanged(String val) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();
//     _debounce = Timer(const Duration(milliseconds: 300), () {
//       setState(() => searchQuery = val);
//     });
//   }

//   void _addCourse(CourseModel course) {
//     setState(() => allCourses.add(course));
//   }

//   void _deleteCourse(CourseModel course) {
//     setState(() => allCourses.remove(course));
//   }

//   List<String> categories = [
//     'All',
//     'hypnotherapy',
//     'Osteotherapy',
//     'Electromagnetic Therapy',
//     'Physiotherapy',
//   ];

//   @override
//   Widget build(BuildContext context) {
//     final filtered = selectedCategory == 'All'
//         ? filteredCourses
//         : filteredCourses.where((c) => c.category == selectedCategory).toList();
// final courseService = CourseService();

//     return Scaffold(
//       body: Row(
//         children: [
//           Sidebar(),
//           Expanded(
//             child: Column(
//               children: [
//                 // Header
//                 Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(color: Colors.black12, blurRadius: 3),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "Course Management",
//                         style: TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 300,
//                         child: TextField(
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(Icons.search),
//                             hintText: "Search courses...",
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                           ),
//                           onChanged: _onSearchChanged,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Filter & Add
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     children: [
//                       DropdownButton<String>(
//                         value: selectedCategory,
//                         items: categories
//                             .map(
//                               (e) => DropdownMenuItem(value: e, child: Text(e)),
//                             )
//                             .toList(),
//                         onChanged: (val) =>
//                             setState(() => selectedCategory = val!),
//                       ),
//                       const Spacer(),
//                       ElevatedButton.icon(
//                         icon: const Icon(Icons.add),
//                         label: const Text("Upload Video"),
//                         onPressed: () async {
//                           final newCourse = await showDialog<CourseModel>(
//                             context: context,
//                             builder: (_) => const CourseUploadDialog(),
//                           );
//                           if (newCourse != null) _addCourse(newCourse);
//                         },
//                       ),
//                     ],
//                   ),
//                 ),

//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: StreamBuilder(
//                       stream: FirebaseFirestore.instance
//                           .collectionGroup('lessons')
//                           .snapshots(),

//                       builder: (context, snapshot) {
//                         if (snapshot.connectionState ==
//                             ConnectionState.waiting) {
//                           return const Center(
//                             child: CircularProgressIndicator(),
//                           );
//                         }

//                         if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                           return const Center(child: Text("No courses found"));
//                         }

//                         // final allCourses = snapshot.data!.docs
//                         //     .map((doc) => CourseModel.fromMap(doc.data()))
//                         //     .toList();

//                         final allCourses = snapshot.data!.docs.map((doc) {
//                           final parentCourseId =
//                               doc.reference.parent.parent?.id ?? '';
//                           return CourseModel.fromMap(
//                             doc.data(),
//                             doc.id,
//                             parentCourseId,
//                           );
//                         }).toList();

//                         final filtered = selectedCategory == 'All'
//                             ? allCourses
//                             : allCourses
//                                   .where((c) => c.category == selectedCategory)
//                                   .toList();

//                         return Card(
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: DataTable(
//                               columns: const [
//                                 DataColumn(label: Text("Thumbnail")),
//                                 DataColumn(label: Text("Title")),
//                                 DataColumn(label: Text("Category")),
//                                 DataColumn(label: Text("Actions")),
//                               ],
//                               rows: filtered.map((course) {
//                                 return DataRow(
//                                   cells: [
//                                     DataCell(
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: course.thumbnailUrl.isNotEmpty
//                                             ? Image.network(
//                                                 course.thumbnailUrl,
//                                                 width: 80,
//                                                 height: 50,
//                                                 fit: BoxFit.cover,
//                                               )
//                                             : const Icon(
//                                                 Icons.image_not_supported,
//                                               ),
//                                       ),
//                                     ),
//                                     // DataCell(
//                                     //   SizedBox(
//                                     //     width: 150,
//                                     //     height: 100,
//                                     //     child: FilePreviewWidget(
//                                     //       fileUrl: course.fileUrl,
//                                     //       fileType: course.fileType,
//                                     //     ),
//                                     //   ),
//                                     // ),
//                                     DataCell(Text(course.title)),
//                                     DataCell(Text(course.category)),
//                                     DataCell(
//                                       Row(
//                                         children: [
//                                           IconButton(
//                                             icon: const Icon(
//                                               Icons.visibility,
//                                               color: Colors.blue,
//                                             ),
//                                             onPressed: () {
//                                               if (course.files.isNotEmpty) {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (_) => Dialog(
//                                                     child: Padding(
//                                                       padding:
//                                                           const EdgeInsets.all(
//                                                             16,
//                                                           ),
//                                                       child: ListView(
//                                                         shrinkWrap: true,
//                                                         children: course.files.map((
//                                                           f,
//                                                         ) {
//                                                           final fileType =
//                                                               f['fileType'];
//                                                           final fileUrl =
//                                                               f['fileUrl'];

//                                                           if (fileType ==
//                                                               'video') {
//                                                             return ListTile(
//                                                               leading: const Icon(
//                                                                 Icons.videocam,
//                                                               ),
//                                                               title: const Text(
//                                                                 'Play Video',
//                                                               ),
//                                                               onTap: () {
//                                                                 Navigator.pop(
//                                                                   context,
//                                                                 ); // close list dialog
//                                                                 showDialog(
//                                                                   context:
//                                                                       context,
//                                                                   builder: (_) => Dialog(
//                                                                     insetPadding:
//                                                                         const EdgeInsets.all(
//                                                                           20,
//                                                                         ),
//                                                                     child: AspectRatio(
//                                                                       aspectRatio:
//                                                                           16 /
//                                                                           9,
//                                                                       child: VideoPlayerWidget(
//                                                                         url:
//                                                                             fileUrl,
//                                                                       ),
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             );
//                                                           } else if (fileType ==
//                                                               'image') {
//                                                             return Padding(
//                                                               padding:
//                                                                   const EdgeInsets.symmetric(
//                                                                     vertical:
//                                                                         8.0,
//                                                                   ),
//                                                               child:
//                                                                   Image.network(
//                                                                     fileUrl,
//                                                                     height: 200,
//                                                                   ),
//                                                             );
//                                                           } else if (fileType ==
//                                                               'document') {
//                                                             return ListTile(
//                                                               leading: const Icon(
//                                                                 Icons
//                                                                     .picture_as_pdf,
//                                                               ),
//                                                               title: const Text(
//                                                                 'Open Document',
//                                                               ),
//                                                               onTap: () {
//                                                                 // TODO: open PDF viewer here
//                                                               },
//                                                             );
//                                                           } else {
//                                                             return ListTile(
//                                                               title: Text(
//                                                                 'Unknown file type: $fileType',
//                                                               ),
//                                                             );
//                                                           }
//                                                         }).toList(),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               } else if (course
//                                                   .videoUrl
//                                                   .isNotEmpty) {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (_) => Dialog(
//                                                     insetPadding:
//                                                         const EdgeInsets.all(
//                                                           20,
//                                                         ),
//                                                     child: AspectRatio(
//                                                       aspectRatio: 16 / 9,
//                                                       child: VideoPlayerWidget(
//                                                         url: course.videoUrl,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 );
//                                               } else if (course
//                                                   .thumbnailUrl
//                                                   .isNotEmpty) {
//                                                 showDialog(
//                                                   context: context,
//                                                   builder: (_) => Dialog(
//                                                     child: Image.network(
//                                                       course.thumbnailUrl,
//                                                     ),
//                                                   ),
//                                                 );
//                                               }
//                                             },
//                                           ),

//                                           IconButton(
//                                             icon: const Icon(
//                                               Icons.delete,
//                                               color: Colors.green,
//                                             ),
//                                             onPressed: () async {
//                                               final confirm =
//                                                   await showDialog<bool>(
//                                                     context: context,
//                                                     builder: (_) => AlertDialog(
//                                                       title: const Text(
//                                                         'Delete Lesson',
//                                                       ),
//                                                       content: const Text(
//                                                         'Are you sure you want to delete this lesson?',
//                                                       ),
//                                                       actions: [
//                                                         TextButton(
//                                                           onPressed: () =>
//                                                               Navigator.pop(
//                                                                 context,
//                                                                 false,
//                                                               ),
//                                                           child: const Text(
//                                                             'Cancel',
//                                                           ),
//                                                         ),
//                                                         ElevatedButton(
//                                                           onPressed: () =>
//                                                               Navigator.pop(
//                                                                 context,
//                                                                 true,
//                                                               ),
//                                                           child: const Text(
//                                                             'Delete',
//                                                           ),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   );

//                                               if (confirm == true) {
//                                                 try {
//                                                   final categoryDocId = course
//                                                       .category
//                                                       .toLowerCase()
//                                                       .replaceAll(' ', '_');

//                                                   await
//                                                    FirebaseFirestore
//                                                       .instance
//                                                       .collection('courses')
//                                                       .doc(categoryDocId)
//                                                       .collection('lessons')
//                                                       .doc(course.id)
//                                                       .delete();

//                                                   ScaffoldMessenger.of(
//                                                     context,
//                                                   ).showSnackBar(
//                                                     const SnackBar(
//                                                       content: Text(
//                                                         'Lesson deleted successfully ✅',
//                                                       ),
//                                                     ),
//                                                   );
//                                                 } catch (e) {
//                                                   ScaffoldMessenger.of(
//                                                     context,
//                                                   ).showSnackBar(
//                                                     SnackBar(
//                                                       content: Text(
//                                                         'Failed to delete: $e',
//                                                       ),
//                                                     ),
//                                                   );
//                                                 }
//                                               }
//                                             },
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 );
//                               }).toList(),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
