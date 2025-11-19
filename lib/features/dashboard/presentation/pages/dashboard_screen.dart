import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:deluxe/features/dashboard/presentation/pages/dispensary_dashboard.dart';
import 'package:deluxe/features/dashboard/presentation/pages/farmer_dashboard.dart';
import 'package:deluxe/features/dashboard/presentation/pages/farmer_shell.dart';
import 'package:deluxe/features/dashboard/presentation/pages/main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          final userRole = state.role;

          switch (userRole) {
            case 'consumer':
              return const MainShell();
            case 'farmer':
              return const FarmerShell();
            case 'dispensary':
              return const DispensaryDashboard();
            default:
              return const Scaffold(
                body: Center(
                  child: Text('Error: Unknown user role.'),
                ),
              );
          }
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
