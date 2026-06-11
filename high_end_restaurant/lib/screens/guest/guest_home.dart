import 'package:flutter/material.dart';
import '../../services/menu_service.dart';
import '../../models/menu_model.dart';
import '../../widgets/menu_card.dart';
import '../../screens/authentication/login.dart';

class GuestHome extends StatefulWidget {
  const GuestHome({super.key});

  @override
  State<GuestHome> createState() => _GuestHomeState();
}

class _GuestHomeState extends State<GuestHome> {
  final MenuService menuService = MenuService();

  List<MenuModel> allMenus = [];
  List<MenuModel> filteredMenus = [];

  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> categories = [
    "All",
    "Burgers",
    "Snacks",
    "Drinks"
  ];

  @override
  void initState() {
    super.initState();
    loadMenus();
  }

  Future<void> loadMenus() async {
    final data = await menuService.getMenus();

    setState(() {
      allMenus = data;
      filteredMenus = data;
    });
  }

  void filterMenus() {
    setState(() {
      filteredMenus = allMenus.where((menu) {
        final matchesSearch = menu.name
            .toLowerCase()
            .contains(searchQuery.toLowerCase());

        final matchesCategory = selectedCategory == "All"
            ? true
            : menu.category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Premium Menu Choices"),
        actions: []
      ),

      body: Column(
        children: [

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            color: Colors.orange.shade100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("You are in Guest Mode"),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  },
                  child: const Text("Log In"),
                )
              ],
            ),
          ),

          //SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search menu...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                searchQuery = value;
                filterMenus();
              },
            ),
          ),

          //CATEGORY FILTER
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: selectedCategory == category,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = category;
                      });
                      filterMenus();
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          //MENU LIST
          Expanded(
            child: filteredMenus.isEmpty
                ? const Center(child: Text("No results found"))
                : ListView.builder(
              itemCount: filteredMenus.length,
              itemBuilder: (context, index) {
                final menu = filteredMenus[index];

                return MenuCard(
                  menu: menu,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Login to book this package"),
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