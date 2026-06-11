import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/booking_model.dart';
import '../../models/menu_model.dart';
import '../../services/booking_service.dart';
import '../../services/menu_service.dart';
import '../../widgets/menu_card.dart';
import '../../widgets/booking_cards.dart';
import '../../screens/root.dart';
import 'booking_page.dart';
import 'edit_booking.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    if (index == 3) {
      _logout();
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Root()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Dashboard"),
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onDestinationSelected,
            labelType: NavigationRailLabelType.all,
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Icon(Icons.person, size: 32),
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text("Home"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: Text("Menu"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.book_online_outlined),
                selectedIcon: Icon(Icons.book_online),
                label: Text("Bookings"),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.logout),
                selectedIcon: Icon(Icons.logout),
                label: Text("Logout"),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? const _WelcomeView()
                : _selectedIndex == 1
                    ? const _EmbeddedMenuView()
                    : const _EmbeddedBookingsView(),
          ),
        ],
      ),
    );
  }
}

class _WelcomeView extends StatelessWidget {
  const _WelcomeView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Welcome!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Use the navigation rail on the left to browse the menu and manage your reservations.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _UserCard(
                  icon: Icons.restaurant_menu,
                  label: "View Menu & Book",
                  color: Colors.deepPurple,
                  onTap: () {},
                ),
                _UserCard(
                  icon: Icons.book_online,
                  label: "My Reservations",
                  color: Colors.orange,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmbeddedMenuView extends StatefulWidget {
  const _EmbeddedMenuView();

  @override
  State<_EmbeddedMenuView> createState() => _EmbeddedMenuViewState();
}

class _EmbeddedMenuViewState extends State<_EmbeddedMenuView> {
  final MenuService menuService = MenuService();

  List<MenuModel> allMenus = [];
  List<MenuModel> filteredMenus = [];

  String searchQuery = "";
  String selectedCategory = "All";

  final List<String> categories = ["All", "Burgers", "Snacks", "Drinks"];

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
        final matchesSearch =
            menu.name.toLowerCase().contains(searchQuery.toLowerCase());
        final matchesCategory = selectedCategory == "All"
            ? true
            : menu.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              const Icon(Icons.restaurant_menu,
                  size: 28, color: Colors.deepPurple),
              const SizedBox(width: 10),
              const Text(
                "Premium Menu",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
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
    );
  }
}

class _EmbeddedBookingsView extends StatefulWidget {
  const _EmbeddedBookingsView();

  @override
  State<_EmbeddedBookingsView> createState() => _EmbeddedBookingsViewState();
}

class _EmbeddedBookingsViewState extends State<_EmbeddedBookingsView> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          color: Colors.grey.shade50,
          child: Row(
            children: [
              const Icon(Icons.book_online, size: 28, color: Colors.orange),
              const SizedBox(width: 10),
              const Text(
                "My Reservations",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<BookingModel>>(
            future: BookingService.getUserBookings(user!.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = snapshot.data ?? [];

              if (bookings.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_busy, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No reservations yet",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return BookingCard(
                    booking: booking,
                    onEdit: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditBookingPage(booking: booking),
                        ),
                      );
                      setState(() {});
                    },
                    onDelete: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text("Delete Reservation"),
                          content: const Text(
                            "Are you sure you want to delete this reservation?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text(
                                "Delete",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await BookingService.deleteBooking(booking.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Reservation deleted")),
                        );
                        setState(() {});
                      }
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _UserCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _UserCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
