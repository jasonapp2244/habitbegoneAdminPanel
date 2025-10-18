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

  List<String>? uploadedFiles;
  List<Map<String, dynamic>>? supportMessages;
  List<Map<String, dynamic>>? history;

  AppUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.lastOnline,
    required this.role,
    this.isActive = true, 
    required this.isPaid,
    required this.isBlocked,
    required this.emailVerified,
    this.joinedAt,
    this.uploadedFiles,
    this.supportMessages,
    this.history,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> data, String docId) {
    return AppUserModel(
      uid: data['uid'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      lastOnline: data['lastOnline']?.toDate(),
      role: data['role'] ?? 'User',
      isActive: data['isActive'] ?? true,
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