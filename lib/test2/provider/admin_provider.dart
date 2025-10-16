// user_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:habitbegone_admin/test2/model/personal_deatil_model.dart';

class AdminProvider with ChangeNotifier {
  UserModel? _user;
  bool _loading = false;


  UserModel? get user => _user;
  bool get isLoading => _loading;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _loading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }

    _loading = false;
    notifyListeners();
  }

  // Optional: real-time listener
  void listenToUser() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore.collection('users').doc(user.uid).snapshots().listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _user = UserModel.fromMap(snapshot.data()!);
        notifyListeners();
      }
    });
  }


    Future<void> updateUser({String? name, String? email, String? role}) async {
    if (user == null) return;

    try {
      _loading = true;
      notifyListeners();

      final uid = _user!.uid;
      final updatedData = {
        'name': name ?? _user!.name,
        'email': email ?? _user!.email,
        'role': role ?? _user!.role,
      };

      await FirebaseFirestore.instance.collection('users').doc(uid).update(updatedData);

      // Update local state
      _user = _user!.copyWith(
        name: name,
        email: email,
        role: role,
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error updating user: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

}
