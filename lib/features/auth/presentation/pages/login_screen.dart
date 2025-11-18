
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:deluxe/features/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to ITALVIBES x Deluxe',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                // Dispatch the sign-in event to the AuthBloc.
                context.read<AuthBloc>().add(SignInWithGoogleRequested());
              },
              child: const Text('Sign In with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
