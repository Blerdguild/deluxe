// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/core/firebase/cloud_functions_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // FIX: Define final fields to hold the injected services.
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final CloudFunctionsService _cloudFunctionsService;

  // FIX: Update the constructor to accept the required services.
  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
    required CloudFunctionsService cloudFunctionsService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _cloudFunctionsService = cloudFunctionsService,
        super(AuthInitial()) {
    // Register the event handlers.
    on<AppStarted>(_onAppStarted);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    // TODO: Implement logic to check for a stored token using _authService.
    await Future.delayed(const Duration(seconds: 1)); // Simulate check
    final user = _authService.getCurrentUser(); // Example usage
    if (user != null) {
      final role = await _authService.getUserRole(user.uid);
      emit(Authenticated(userId: user.uid, role: role));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;

        // Check if user exists in Firestore, if not create with default role
        // For now, we'll just fetch the role, assuming existing users or default 'consumer'
        // In a real scenario, we'd check `userCredential.additionalUserInfo?.isNewUser`

        String role = await _authService.getUserRole(uid);

        // Create Wallet (Idempotent call to backend)
        try {
          await _cloudFunctionsService.createWallet();
        } catch (e) {
          debugPrint("Wallet creation failed (non-fatal): $e");
          // We don't block login if wallet fails, but we log it.
        }

        // If it's a new user (or role fetch returned default 'consumer' but we want to be sure),
        // we might want to create the doc here if it doesn't exist.
        // For this MVP step, we rely on getUserRole returning 'consumer' as default.

        emit(Authenticated(userId: uid, role: role));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      // TODO: Emit an AuthError state with a user-friendly message
      print("Google Sign-In failed: $e");
      emit(Unauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authService.signOut();
    emit(Unauthenticated());
  }
}
