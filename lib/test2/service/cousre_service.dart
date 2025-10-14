import 'package:habitbegone_admin/test2/model/coure_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseService {
  final _courses = FirebaseFirestore.instance.collection('courses');

  Future<void> addCourse(CourseModel course) async {
    await _courses.doc(course.id).set({
      'title': course.title,
      'description': course.description,
      'thumbnailUrl': course.thumbnailUrl,
      'videoUrl': course.videoUrl,
      'duration': course.duration,
      'category': course.category,
      'uploadedAt': course.uploadedAt,
    });
  }

  Stream<List<CourseModel>> getCourses() {
    return _courses.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CourseModel(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          thumbnailUrl: data['thumbnailUrl'],
          videoUrl: data['videoUrl'],
          duration: data['duration'],
          category: data['category'],
          uploadedAt: (data['uploadedAt'] as Timestamp).toDate(), files: [],
        );
      }).toList();
    });
  }

  Future<void> deleteCourse(String id) async {
    await _courses.doc(id).delete();
  }
}
