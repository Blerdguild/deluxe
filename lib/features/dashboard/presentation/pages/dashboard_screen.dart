
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:deluxe/features/auth/bloc/auth_state.dart';
import 'package:deluxe/features/dashboard/presentation/pages/main_shell.dart';
import 'package:deluxe/features/dashboard/presentation/pages/dispensary_main_shell.dart';
import 'package:deluxe/features/dashboard/presentation/pages/farmer_main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          switch (state.user.role) {
            case 'consumer':
              return const MainShell();
            case 'farmer':
              return const FarmerMainShell();
            case 'dispensary':
              return const DispensaryMainShell();
            default:
              // Fallback for any unknown roles
              return const Scaffold(
                body: Center(
                  child: Text('Unknown user role'),
                ),
              );
          }
        } else {
          // This should technically not be reached if the user is authenticated
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
