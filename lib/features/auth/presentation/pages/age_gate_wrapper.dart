// C:/dev/flutter_projects/deluxe/lib/features/auth/presentation/pages/age_gate_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// FIX: Only import the main 'auth_bloc.dart' file.
// This single import provides access to AuthBloc, AuthState, Authenticated, and Unauthenticated.
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';

// Dependencies for navigation targets
import 'package:deluxe/features/auth/presentation/pages/login_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/dashboard_screen.dart';

// --- Mock LoginScreen for context ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('Login Screen')));
}
// --- End Mock ---

class AgeGateWrapper extends StatelessWidget {
  const AgeGateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Using BlocConsumer is often better here if you need to react to state changes
    // with one-time actions (like showing a dialog), but BlocBuilder is fine for navigation.
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // FIX: The class name is 'Unauthenticated'.
        if (state is Unauthenticated) {
          // If the user is not logged in, show the login screen.
          return const LoginScreen();
        }

        // FIX: The class name is 'Authenticated'.
        if (state is Authenticated) {
          // If the user is logged in, proceed to the main dashboard.
          return const DashboardScreen();
        }

        // This is the default case, which covers the 'AuthInitial' state.
        // It shows a loading screen while the AuthBloc's 'AppStarted' event
        // is being processed to determine the user's status.
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // We can add our logo here later
                Text("ITALVIBES", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Verifying Session..."), // More accurate text
                SizedBox(height: 10),
                CircularProgressIndicator(),
              ],
            ),
          ),
        );
      },
    );
  }
}
