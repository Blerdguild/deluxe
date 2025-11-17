// C:/dev/flutter_projects/deluxe/lib/features/auth/presentation/pages/age_gate_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:deluxe/features/auth/bloc/auth_state.dart';
import 'package:deluxe/features/auth/presentation/pages/login_screen.dart';
import 'package:deluxe/features/dashboard/presentation/pages/dashboard_screen.dart';

class AgeGateWrapper extends StatelessWidget {
  const AgeGateWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthUnauthenticated) {
          return const LoginScreen();
        }
        if (state is AuthAuthenticated) {
          return const DashboardScreen();
        }
        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("ITALVIBES", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Text("Age Gate Check..."),
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
