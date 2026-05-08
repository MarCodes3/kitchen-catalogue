import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/locations_screen.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/scanned_items_screen.dart';

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _index = 0;

  // ⭐ 4 screens for 4 tabs
  final screens = [
    HomeScreen(),
    LocationsScreen(),
    ShoppingListScreen(),
    ScannedItemsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.kitchen), label: "Locations"),
          NavigationDestination(icon: Icon(Icons.list_alt), label: "Shopping"),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: "Scanned"),
        ],
      ),
    );
  }
}
