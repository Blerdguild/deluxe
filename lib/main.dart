// C:/dev/flutter_projects/deluxe/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Core services and setup.
import 'core/theme/app_theme.dart';
import 'shared/services/service_locator.dart';
import 'core/firebase/firebase_init.dart';

// Auth feature components.
import 'features/auth/presentation/pages/age_gate_wrapper.dart';
import 'features/auth/bloc/auth_bloc.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the dedicated service.
  await initializeFirebase();

  // Initialize Hive for local, secure storage.
  await Hive.initFlutter();
  // Open a box for storing sensitive data like auth tokens or user preferences.
  await Hive.openBox('secure_box');

  // Load environment variables from the .env file (API keys, contract addresses).
  await dotenv.load(fileName: ".env");

  // Register services for dependency injection.
  setupServiceLocator();

  runApp(const ItalVibesApp());
}

class ItalVibesApp extends StatelessWidget {
  const ItalVibesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create (and retrieve from GetIt) the AuthBloc, making it available to the widget tree.
      create: (_) => sl<AuthBloc>(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ITALVIBES',
        theme: AppTheme.darkGreenTheme,
        // The AgeGateWrapper will be the first thing the user sees.
        home: const AgeGateWrapper(),
      ),
    );
  }
}
