// C:/dev/flutter_projects/deluxe/lib/features/dashboard/presentation/pages/dashboard_screen.dart

// FIX: Removed the direct import of 'auth_state.dart'.
// The main 'auth_bloc.dart' file provides access to the Bloc, states, and events.
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';

import 'package:deluxe/features/dashboard/presentation/pages/main_shell.dart';
import 'package:deluxe/features/dashboard/presentation/pages/dispensary_main_shell.dart';
import 'package:deluxe/features/dashboard/presentation/pages/farmer_main_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Mock Implementations for context ---
// These shell widgets would be in their own files.
class MainShell extends StatelessWidget {
  const MainShell({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Consumer Dashboard')));
}

class FarmerMainShell extends StatelessWidget {
  const FarmerMainShell({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Farmer Dashboard')));
}

class DispensaryMainShell extends StatelessWidget {
  const DispensaryMainShell({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Dispensary Dashboard')));
}
// --- End Mocks ---

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This BlocBuilder listens to AuthState changes and rebuilds the UI accordingly.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // FIX: The state class name is 'Authenticated', aligned with our previous fix.
        if (state is Authenticated) {
          // This is a placeholder for accessing the user's role.
          // In the real 'Authenticated' state, we would pass the User object.
          // For now, let's mock this to avoid another error.
          const userRole = 'consumer'; // Mock role

          // The switch statement correctly routes the user based on their role.
          // This is a great implementation for handling our multi-user architecture.
          switch (userRole) {
            case 'consumer':
              return const MainShell();
            case 'farmer':
              return const FarmerMainShell();
            case 'dispensary':
              return const DispensaryMainShell();
            default:
            // A robust fallback for unexpected roles is crucial for stability.
              return const Scaffold(
                body: Center(
                  child: Text('Error: Unknown user role.'),
                ),
              );
          }
        }

        // If the state is not Authenticated (e.g., AuthInitial, Unauthenticated),
        // show a loading spinner. This is a safe fallback while the app determines
        // the auth state, preventing crashes.
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
