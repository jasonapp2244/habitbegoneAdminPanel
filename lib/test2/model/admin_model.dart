// user_model.dart

class AdminModel {
  final String email;
  final String phoneNumer;


  AdminModel({
    required this.email,
    required this.phoneNumer,
  });

  // Convert Firestore data to UserModel
  factory AdminModel.fromMap(Map<String, dynamic> data) {
    return AdminModel(
      email: data['email'] ?? '',
      phoneNumer: data['phone'] ?? "",
    );
  }

  // Convert to map (for saving to Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phoneNumer,
    };
  }

  AdminModel copyWith({
    String? email,
    String? phoneNumer,
  }) {
    return AdminModel(
      email: email ?? this.email,
      phoneNumer: phoneNumer ?? this.phoneNumer,
    );
  }
}
