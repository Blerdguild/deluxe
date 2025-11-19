import 'package:deluxe/features/dashboard/presentation/pages/farmer_dashboard.dart';
import 'package:deluxe/features/farmer/presentation/pages/farmer_orders_screen.dart';
import 'package:deluxe/features/farmer/presentation/pages/inventory_screen.dart';
import 'package:deluxe/features/profile/presentation/pages/farmer_profile_screen.dart';
import 'package:flutter/material.dart';

class FarmerShell extends StatefulWidget {
  const FarmerShell({super.key});

  @override
  State<FarmerShell> createState() => _FarmerShellState();
}

class _FarmerShellState extends State<FarmerShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FarmerDashboard(),
    InventoryScreen(),
    FarmerOrdersScreen(),
    FarmerProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        onTap: _onItemTapped,
      ),
    );
  }
}
