// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // FIX: Define final fields to hold the injected services.
  final AuthService _authService;
  final FirestoreService _firestoreService;

  // FIX: Update the constructor to accept the required services.
  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
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
      emit(Authenticated(userId: user.uid));
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
        // Here you would use _firestoreService to check if it's a new user
        // and create their profile document if needed.
        emit(Authenticated(userId: userCredential.user!.uid));
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
