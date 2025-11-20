import 'package:deluxe/features/dashboard/presentation/pages/dispensary_dashboard.dart';
import 'package:deluxe/features/dispensary/presentation/pages/browse_products_screen.dart';
import 'package:deluxe/features/dispensary/presentation/pages/wholesale_orders_screen.dart';
import 'package:deluxe/features/dispensary/presentation/pages/dispensary_profile_screen.dart';
import 'package:flutter/material.dart';

class DispensaryMainShell extends StatefulWidget {
  const DispensaryMainShell({super.key});

  @override
  State<DispensaryMainShell> createState() => _DispensaryMainShellState();
}

class _DispensaryMainShellState extends State<DispensaryMainShell> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const DispensaryDashboard(), // Dashboard
    const BrowseProductsScreen(), // Browse Products (B2B)
    const WholesaleOrdersScreen(), // Wholesale Orders
    const DispensaryProfileScreen(), // Profile
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
            icon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Browse',
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
