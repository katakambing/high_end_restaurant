import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  //LOGIN
  Future<User?> login(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  //REGISTER
  Future<User?> register(String email, String password) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = result.user;

      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'role': 'user', // default role
        });
      }

      return user;
    } catch (e) {
      print("Register error: $e");
      return null;
    }
  }

  //GET ROLE
  Future<String> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] ?? 'user';
  }

  //LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
  }
}