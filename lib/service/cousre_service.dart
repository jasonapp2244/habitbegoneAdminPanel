import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:habitbegone_admin/model/coure_model.dart';

class CourseService {
  final _db = FirebaseFirestore.instance;

  /// Add a new lesson under a specific category
  Future<void> addLesson(String category, CourseModel lesson) async {
    final categoryId = category.toLowerCase().replaceAll(' ', '_');

    await _db
        .collection('courses')
        .doc(categoryId)
        .collection('lessons')
        .doc(lesson.id)
        .set(lesson.toMap());
  }

  /// Stream all lessons across all categories (using collectionGroup)
  Stream<List<CourseModel>> getAllLessons() {
    return _db.collectionGroup('lessons').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final parentCategory = doc.reference.parent.parent?.id ?? 'unknown';

        return CourseModel.fromMap({
          ...data,
          'category': parentCategory,
        });
      }).toList();
    });
  }

  /// Get lessons for a specific category
  Stream<List<CourseModel>> getLessonsByCategory(String category) {
    final categoryId = category.toLowerCase().replaceAll(' ', '_');

    return _db
        .collection('courses')
        .doc(categoryId)
        .collection('lessons')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return CourseModel.fromMap({
                ...data,
                'category': category,
              });
            }).toList());
  }

  /// Delete a lesson from a specific category
  Future<void> deleteLesson(String category, String lessonId) async {
    final categoryId = category.toLowerCase().replaceAll(' ', '_');

    await _db
        .collection('courses')
        .doc(categoryId)
        .collection('lessons')
        .doc(lessonId)
        .delete();
  }
}













