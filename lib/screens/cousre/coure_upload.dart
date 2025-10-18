import 'package:flutter/material.dart';
import 'package:habitbegone_admin/model/coure_model.dart';
import 'package:habitbegone_admin/service/cousre_service.dart';
import 'package:habitbegone_admin/widgets/coure_upload_dialog.dart';
import 'package:habitbegone_admin/widgets/file_preview.dart';

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