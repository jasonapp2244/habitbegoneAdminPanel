class AppUserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  bool isActive;
  final bool isPaid;
  final bool isBlocked;
  final bool emailVerified;
  final DateTime? joinedAt;
  final DateTime? lastOnline;

  // 👇 Add these new optional fields
  List<String>? uploadedFiles;
  List<Map<String, dynamic>>? supportMessages;
  List<Map<String, dynamic>>? history;

  AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.lastOnline,
    required this.role,
    this.isActive = true, // ✅ default to true
    required this.isPaid,
    required this.isBlocked,
    required this.emailVerified,
    this.joinedAt,
    this.uploadedFiles,
    this.supportMessages,
    this.history,
  });

  // ✅ Factory to create model from Firestore document
  factory AppUserModel.fromMap(Map<String, dynamic> data, String docId) {
    return AppUserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      lastOnline: data['lastOnline']?.toDate(),
      role: data['role'] ?? 'User',
      isActive: data['isActive'] ?? true, // ✅ initialize it
      isPaid: data['isPaid'],
      isBlocked: data['isBlocked'],
      emailVerified: data['emailVerified'],
      joinedAt: data['joinedAt']?.toDate(),
      uploadedFiles: (data['uploadedFiles'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      supportMessages: (data['supportMessages'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
      history: (data['history'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList(),
    );
  }

  // ✅ Convert model to map (for saving back to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'uid': uid,
      'role': role,
      'lastOnline': lastOnline,
      'isActive': isActive,
      'isPaid': isPaid,
      'isBlocked': isBlocked,
      'emailVerified': emailVerified,
      'joinedAt': joinedAt,
      'uploadedFiles': uploadedFiles,
      'supportMessages': supportMessages,
      'history': history,
    };
  }
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class AppUserModel {
//   final String uid;
//   final String email;
//   final String name;
//   String role;
//   bool isPaid;
//   bool isActive;
//   final bool emailVerified;
//   final DateTime? joinedAt;

//   AppUserModel({
//     required this.uid,
//     required this.role,
//     required this.email,
//     required this.name,
//     required this.isPaid,
//     required this.isActive,
//     required this.emailVerified,
//     required this.joinedAt,
//   });

//   factory AppUserModel.fromMap(Map<String, dynamic> map) {
//     return AppUserModel(
//       uid: map['uid'] ?? '',
//       email: map['email'] ?? '',
//       role: map['role']??'standard user',
//       name: map['name'] ?? '',
//       isPaid: map['isPaid'] ?? false,
//       isActive: map['isBlocked'] ?? false,
//       emailVerified: map['emailVerified'] ?? false,
//       joinedAt: map['joinedAt'] != null
//           ? (map['joinedAt'] as Timestamp).toDate()
//           : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'uid': uid,
//       'email': email,
//       'role':role,
//       'name': name,
//       'isPaid': isPaid,
//       'isBlocked': isActive,
//       'emailVerified': emailVerified,
//       'joinedAt': joinedAt,
//     };
//   }
// }
