import 'package:deluxe/features/dashboard/presentation/pages/dispensary_dashboard.dart';
import 'package:deluxe/features/dashboard/presentation/pages/inventory_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/orders_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:flutter/material.dart';

class DispensaryMainShell extends StatefulWidget {
  const DispensaryMainShell({super.key});

  @override
  State<DispensaryMainShell> createState() => _DispensaryMainShellState();
}

class _DispensaryMainShellState extends State<DispensaryMainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    DispensaryDashboard(), // Dashboard
    InventoryScreen(), // Inventory
    OrdersScreen(), // Orders
    ProfileScreen(), // Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dispensary Dashboard',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
