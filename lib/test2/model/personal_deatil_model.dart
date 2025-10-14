// user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final bool isPaid;
  final bool isBlocked;
  final bool emailVerified;
  final DateTime? lastOnline;
  final String? name;
  final String? role;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.isPaid,
    required this.isBlocked,
    required this.emailVerified,
    this.lastOnline,
    this.name,
    this.role,
    this.photoUrl,
  });

  // Convert Firestore data to UserModel
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      isPaid: data['isPaid'] ?? false,
      isBlocked: data['isBlocked'] ?? false,
      emailVerified: data['emailVerified'] ?? false,
      lastOnline: (data['lastOnline'] != null)
          ? (data['lastOnline'] as Timestamp).toDate()
          : null,
      name: data['name'],
      role: data['role'],
      photoUrl: data['photoUrl'],
    );
  }

  // Convert to map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'isPaid': isPaid,
      'isBlocked': isBlocked,
      'emailVerified': emailVerified,
      'lastOnline': lastOnline,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
    };
  }
}
