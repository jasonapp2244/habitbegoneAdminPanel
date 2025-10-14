import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String thumbnailUrl;
  final String videoUrl;
  final String duration;
  final DateTime? uploadedAt;
  final List<Map<String, dynamic>> files;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.duration,
    required this.uploadedAt,
    required this.files,
  });

  factory CourseModel.fromMap(Map<String, dynamic> data) {
    return CourseModel(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? 'Uncategorized',
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      duration: data['duration'] ?? '',
      uploadedAt: data['uploadedAt'] is Timestamp
          ? (data['uploadedAt'] as Timestamp).toDate()
          : (data['uploadedAt'] is DateTime ? data['uploadedAt'] : null),
      files: List<Map<String, dynamic>>.from(data['files'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'duration': duration,
      'uploadedAt': uploadedAt,
      'files': files,
    };
  }
}

























// // lib/test2/model/course_model.dart
// import 'package:cloud_firestore/cloud_firestore.dart';

// class CourseModel {
//   final String id;
//   final String title;
//   final String description;
//   final String category;
//   final String thumbnailUrl;
//   final String videoUrl;
//   final String duration;
//   final DateTime uploadedAt;
//   final List<Map<String, dynamic>> files;

//   CourseModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.category,
//     required this.thumbnailUrl,
//     required this.videoUrl,
//     required this.duration,
//     required this.uploadedAt,
//     required this.files,
//   });

//   factory CourseModel.fromMap(Map<String, dynamic> data) {
//     return CourseModel(
//       id: data['id'] ?? '',
//       title: data['title'] ?? '',
//       description: data['description'] ?? '',
//       category: data['category'] ?? 'no category',
//       thumbnailUrl: data['thumbnailUrl'] ?? '',
//       videoUrl: data['videoUrl'] ?? '',
//       duration: data['duration'] ?? '',
//       uploadedAt: (data['uploadedAt'] is Timestamp)
//           ? (data['uploadedAt'] as Timestamp).toDate()
//           : data['uploadedAt'],
//       files: List<Map<String, dynamic>>.from(data['files'] ?? []),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'category': category,
//       'thumbnailUrl': thumbnailUrl,
//       'videoUrl': thumbnailUrl,
//       'duration': duration,
//       'files': files,
//     };
//   }
// }

// // class CourseModel {
// //   final String id;
// //   String title;
// //   String description;
// //   String thumbnailUrl;
// //   String videoUrl;
// //   String duration;
// //   String category; // e.g., Course A, B, C, D
// //   DateTime uploadedAt;

// //   CourseModel({
// //     required this.id,
// //     required this.title,
// //     required this.description,
// //     required this.thumbnailUrl,
// //     required this.videoUrl,
// //     required this.duration,
// //     required this.category,
// //     required this.uploadedAt,
// //   });
// // }
