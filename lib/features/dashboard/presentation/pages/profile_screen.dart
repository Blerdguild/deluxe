// C:/dev/flutter_projects/deluxe/lib/features/dashboard/presentation/pages/profile_screen.dart

// BEST PRACTICE: Only import the main bloc file, which exports its own events and states.
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            // This will now work correctly because AuthLogoutRequested is properly defined
            // and made available through the 'auth_bloc.dart' import.
            context.read<AuthBloc>().add(const AuthLogoutRequested());
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}

