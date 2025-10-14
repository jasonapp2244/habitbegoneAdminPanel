import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitbegone_admin/test2/model/coure_model.dart';
import 'package:habitbegone_admin/test2/widgets/coure_upload_dialog.dart';
import 'package:flutter/material.dart';
import 'package:habitbegone_admin/test2/widgets/sidebar.dart';
import 'package:habitbegone_admin/test2/widgets/videoplayer_widget.dart';

class CoursesWeb extends StatefulWidget {
  const CoursesWeb({super.key});

  @override
  State<CoursesWeb> createState() => _CoursesWebState();
}

class _CoursesWebState extends State<CoursesWeb> {
  List<CourseModel> allCourses = [];
  List<CourseModel> get filteredCourses {
    final q = searchQuery.toLowerCase();
    return allCourses
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.category.toLowerCase().contains(q),
        )
        .toList();
  }

  String selectedCategory = 'All';
  String searchQuery = '';
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() => searchQuery = val);
    });
  }

  void _addCourse(CourseModel course) {
    setState(() => allCourses.add(course));
  }

  void _deleteCourse(CourseModel course) {
    setState(() => allCourses.remove(course));
  }

  List<String> categories = [
    'All',
    'Course A',
    'Course B',
    'Course C',
    'Course D',
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = selectedCategory == 'All'
        ? filteredCourses
        : filteredCourses.where((c) => c.category == selectedCategory).toList();

    return Scaffold(
      body: Row(
        children: [
          Sidebar(),
          Expanded(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 3),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Course Management",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        width: 300,
                        child: TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search),
                            hintText: "Search courses...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter & Add
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      DropdownButton<String>(
                        value: selectedCategory,
                        items: categories
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) =>
                            setState(() => selectedCategory = val!),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Upload Video"),
                        onPressed: () async {
                          final newCourse = await showDialog<CourseModel>(
                            context: context,
                            builder: (_) => const CourseUploadDialog(),
                          );
                          if (newCourse != null) _addCourse(newCourse);
                        },
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collectionGroup('lessons')
                          .snapshots(),

                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No courses found"));
                        }

                        final allCourses = snapshot.data!.docs
                            .map((doc) => CourseModel.fromMap(doc.data()))
                            .toList();

                        final filtered = selectedCategory == 'All'
                            ? allCourses
                            : allCourses
                                  .where((c) => c.category == selectedCategory)
                                  .toList();

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text("Thumbnail")),
                                DataColumn(label: Text("Title")),
                                DataColumn(label: Text("Category")),
                                DataColumn(label: Text("Actions")),
                              ],
                              rows: filtered.map((course) {
                                return DataRow(
                                  cells: [
                                    DataCell(
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: course.thumbnailUrl.isNotEmpty
                                            ? Image.network(
                                                course.thumbnailUrl,
                                                width: 80,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : const Icon(
                                                Icons.image_not_supported,
                                              ),
                                      ),
                                    ),
                                    // DataCell(
                                    //   SizedBox(
                                    //     width: 150,
                                    //     height: 100,
                                    //     child: FilePreviewWidget(
                                    //       fileUrl: course.fileUrl,
                                    //       fileType: course.fileType,
                                    //     ),
                                    //   ),
                                    // ),
                                    DataCell(Text(course.title)),
                                    DataCell(Text(course.category)),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.visibility,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              if (course.videoUrl.isNotEmpty) {
                                                // show video player
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => Dialog(
                                                    insetPadding:
                                                        const EdgeInsets.all(
                                                          20,
                                                        ),
                                                    child: AspectRatio(
                                                      aspectRatio: 16 / 9,
                                                      child: VideoPlayerWidget(
                                                        url: course.videoUrl,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              } else if (course
                                                  .thumbnailUrl
                                                  .isNotEmpty) {
                                                // show image preview
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => Dialog(
                                                    child: Image.network(
                                                      course.thumbnailUrl,
                                                    ),
                                                  ),
                                                );
                                              } else if (course
                                                  .files
                                                  .isNotEmpty) {
                                                // show document or multiple files
                                                showDialog(
                                                  context: context,
                                                  builder: (_) => Dialog(
                                                    child: ListView(
                                                      children: course.files.map((
                                                        f,
                                                      ) {
                                                        final fileType =
                                                            f['fileType'];
                                                        final fileUrl =
                                                            f['fileUrl'];
                                                        if (fileType ==
                                                            'document') {
                                                          return ListTile(
                                                            leading: const Icon(
                                                              Icons
                                                                  .picture_as_pdf,
                                                            ),
                                                            title: Text(
                                                              'PDF File',
                                                            ),
                                                            onTap: () {
                                                              // open PDF viewer
                                                            },
                                                          );
                                                        } else if (fileType ==
                                                            'image') {
                                                          return Image.network(
                                                            fileUrl,
                                                            height: 200,
                                                          );
                                                        } else if (fileType ==
                                                            'video') {
                                                          return ListTile(
                                                            leading: const Icon(
                                                              Icons.videocam,
                                                            ),
                                                            title: const Text(
                                                              'Play Video',
                                                            ),
                                                            onTap: () {
                                                              showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) => Dialog(
                                                                  child: VideoPlayerWidget(
                                                                    url:
                                                                        fileUrl,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        } else {
                                                          return const SizedBox.shrink();
                                                        }
                                                      }).toList(),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                          ),

                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.green,
                                            ),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance
                                                  .collection('lessons')
                                                  .doc(course.id)
                                                  .delete();
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
