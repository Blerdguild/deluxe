
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Dispatch the logout event
            context.read<AuthBloc>().add(AuthLogoutRequested());
          },
          child: const Text('Logout'),
        ),
      ),
    );
  }
}
