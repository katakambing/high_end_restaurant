import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:high_end_restaurant/screens/guest/guest_home.dart';

import 'authentication/login.dart';
import 'admin/admin_home.dart';
import 'user/user_home.dart';

class Root extends StatelessWidget {
  const Root({super.key});

  Future<Widget> getScreen() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const GuestHome();
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        return const LoginPage();
      }

      final data = doc.data();
      final role = data?['role']?.toString().toLowerCase();

      if (role == 'admin') {
        return const AdminHome();
      } else {
        return const UserHome();
      }

    } catch (e) {
      return const LoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("Something went wrong")),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data as Widget;
      },
    );
  }
}