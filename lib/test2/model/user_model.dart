class AppUserModel {
  final String id;
  String name;
  String email;
  String role;
  bool isActive;
  List<String>? uploadedFiles;
  List<Map<String, String>>? supportMessages;
  List<Map<String, String>>? history;

  AppUserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.uploadedFiles,
    this.supportMessages,
    this.history,
  });
}
