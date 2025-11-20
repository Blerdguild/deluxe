import 'package:deluxe/features/dashboard/presentation/pages/farmer_dashboard.dart';
import 'package:deluxe/features/dashboard/presentation/pages/harvests_screen.dart';
import 'package:deluxe/features/farmer/presentation/pages/farmer_orders_screen.dart';
import 'package:deluxe/features/profile/presentation/pages/farmer_profile_screen.dart';
import 'package:flutter/material.dart';

class FarmerMainShell extends StatefulWidget {
  const FarmerMainShell({super.key});

  @override
  State<FarmerMainShell> createState() => _FarmerMainShellState();
}

class _FarmerMainShellState extends State<FarmerMainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FarmerDashboard(),
    HarvestsScreen(),
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
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Farmer Dashboard',
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
            icon: Icon(Icons.grass),
            label: 'Harvests',
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
      ),
    );
  }
}
