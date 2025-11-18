
import 'package:deluxe/features/dashboard/bloc/dispensary_bloc.dart';
import 'package:deluxe/features/dashboard/bloc/product_bloc.dart';
import 'package:deluxe/features/dashboard/presentation/pages/consumer_dashboard.dart';
import 'package:deluxe/features/dashboard/presentation/pages/dispensary_list_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/product_list_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    ConsumerDashboard(),
    DispensaryListScreen(),
    ProductListScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<DispensaryBloc>()..add(LoadDispensaries()),
        ),
        BlocProvider(
          create: (context) => sl<ProductBloc>()..add(LoadProducts()),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'ITALVIBES x DeluxeBudSt',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: theme.colorScheme.onPrimary),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
          ],
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.store),
              label: 'Dispensaries',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
