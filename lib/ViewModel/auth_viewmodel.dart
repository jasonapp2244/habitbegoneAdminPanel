import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:habitbegone_admin/provider/user_provider.dart';
import 'package:habitbegone_admin/screens/dashboard/dashboard_view.dart';
import 'package:habitbegone_admin/screens/login/login_screen.dart';
import 'package:provider/provider.dart';

class AuthViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> logout(BuildContext context) async {
    try {
      // 1️⃣ Sign out from Firebase
      await _auth.signOut();

      // 2️⃣ Clear user data from provider
      Provider.of<UserProvider>(context, listen: false).clearUser();

      // 3️⃣ Navigate back to the login screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Logout failed: $e")));
    }
  }

  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      final user = _auth.currentUser;
      if (user != null) {
        // Load user data from Firestore into provider
        await Provider.of<UserProvider>(
          context,
          listen: false,
        ).loadUserDataFromFirestore(user.uid);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Login failed: $e")));
    }
  }
}
