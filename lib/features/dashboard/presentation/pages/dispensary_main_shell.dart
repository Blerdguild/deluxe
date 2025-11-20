import 'package:deluxe/features/dashboard/presentation/pages/dispensary_dashboard.dart';
import 'package:deluxe/features/dispensary/presentation/pages/browse_products_screen.dart';
import 'package:deluxe/features/dispensary/presentation/pages/wholesale_orders_screen.dart';
import 'package:deluxe/features/dispensary/presentation/pages/dispensary_consumer_orders_screen.dart';
import 'package:deluxe/features/dispensary/presentation/pages/dispensary_inventory_screen.dart';
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
    const DispensaryDashboardView(), // Dashboard
    const DispensaryInventoryScreen(), // Inventory
    const BrowseProductsScreen(), // Browse Products (B2B)
    const WholesaleOrdersScreen(), // Wholesale Orders (Purchases)
    const DispensaryConsumerOrdersScreen(), // Consumer Orders (Sales)
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
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.store),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale),
            label: 'Sales',
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
