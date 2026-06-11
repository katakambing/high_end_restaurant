import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/menu_service.dart';
import '../models/menu_model.dart';
import '../widgets/menu_card.dart';
import 'authentication/login.dart';
import 'user/booking_page.dart';
import 'root.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MenuService menuService = MenuService();

  List<MenuModel> menus = [];

  String search = "";
  String category = "All";

  final categories = ["All", "Burgers", "Snacks", "Drinks"];

  @override
  void initState() {
    super.initState();
    loadMenus();
  }

  Future<void> loadMenus() async {
    menus = await menuService.getMenus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isGuest = user == null;

    final filtered = menus.where((m) {
      final matchSearch =
      m.name.toLowerCase().contains(search.toLowerCase());

      final matchCat = category == "All" ? true : m.category == category;

      return matchSearch && matchCat;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Premium Menu"),
        actions: [
          if (isGuest)
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Login", style: TextStyle(color: Colors.white)),
            )
          else
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const Root()),
                      (route) => false,
                );
              },
              child: const Text("Logout",
                  style: TextStyle(color: Colors.white)),
            ),
        ],
      ),

      body: Column(
        children: [

          //GUEST BANNER
          if (isGuest)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.orange.shade100,
              child: Text(
                isGuest ? "Guest Mode" : "User Mode",
                textAlign: TextAlign.center,
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search menu...",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: categories.map((c) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(c),
                    selected: category == c,
                    onSelected: (_) => setState(() => category = c),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final menu = filtered[i];

                return MenuCard(
                  menu: menu,
                  onTap: () {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Login to book this package"),
                        ),
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginPage()),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingPage(menu: menu),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}