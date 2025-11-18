// C:/dev/flutter_projects/deluxe/lib/features/auth/presentation/pages/login_screen.dart

// FIX: Removed the incorrect import of 'auth_event.dart'.
// The main bloc file is the single source of truth for imports.
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to ITALVIBES x Deluxe',
                style: Theme.of(context).textTheme.headlineSmall, // Adjusted for better fit
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                onPressed: () {
                  // FIX: Instantiate the event with 'const' before adding it.
                  // This now works because the event is defined and correctly imported.
                  context.read<AuthBloc>().add(const SignInWithGoogleRequested());
                },
                child: const Text('Sign In with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
