import 'package:flutter/material.dart';
import 'package:high_end_restaurant/screens/home_screen.dart';
import 'package:high_end_restaurant/screens/root.dart';
import 'user_reservation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/guest/guest_home.dart';

class UserHome extends StatelessWidget {
  const UserHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Welcome!",
              style: TextStyle(fontSize: 20),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyReservationsPage(),
                  ),
                );
              },
              child: const Text("My Reservations"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              },
              child: const Text("View Menu & Book"),
            ),

            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Root()),
                      (route) => false,
                );
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}