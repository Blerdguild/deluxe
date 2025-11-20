// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/core/firebase/cloud_functions_service.dart';
import 'package:deluxe/features/dashboard/domain/repositories/dispensary_repository.dart';
import 'package:deluxe/shared/models/dispensary_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // FIX: Define final fields to hold the injected services.
  final AuthService _authService;
  final FirestoreService _firestoreService;
  final CloudFunctionsService _cloudFunctionsService;
  final DispensaryRepository _dispensaryRepository;

  // FIX: Update the constructor to accept the required services.
  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
    required CloudFunctionsService cloudFunctionsService,
    required DispensaryRepository dispensaryRepository,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        _cloudFunctionsService = cloudFunctionsService,
        _dispensaryRepository = dispensaryRepository,
        super(AuthInitial()) {
    // Register the event handlers.
    on<AppStarted>(_onAppStarted);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRoleSelected>(_onAuthRoleSelected);
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
        final user = userCredential.user!;
        String role = await _authService.getUserRole(uid);

        // If getUserRole returns 'consumer' (default), we should verify if the doc actually exists
        // and create it if it's a new user.
        final userDoc = await _firestoreService.userStream(user)?.first;
        if (userDoc == null || !userDoc.exists) {
          // New user! Emit state to ask for role selection.
          emit(AuthNeedsRoleSelection(userId: uid));
          return;
        } else if (userDoc.data()?.containsKey('role') == true) {
          role = userDoc.data()!['role'] as String;
        }

        // Create Wallet (Idempotent call to backend)
        try {
          await _cloudFunctionsService.createWallet();
        } catch (e) {
          debugPrint("Wallet creation failed (non-fatal): $e");
          // We don't block login if wallet fails, but we log it.
        }

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

  Future<void> _onAuthRoleSelected(
    AuthRoleSelected event,
    Emitter<AuthState> emit,
  ) async {
    final user = _authService.getCurrentUser();
    if (user != null) {
      await _firestoreService.createUser(
        user: user,
        role: event.role,
      );

      // If role is dispensary, create dispensary entry
      if (event.role == 'dispensary') {
        try {
          final dispensary = Dispensary(
            id: user.uid,
            name: user.displayName ?? 'Unnamed Dispensary',
            location: '', // Can be updated later in profile
            imageUrl: user.photoURL ?? '',
          );
          await _dispensaryRepository.createDispensary(dispensary);
          debugPrint('Dispensary entry created for ${user.uid}');
        } catch (e) {
          debugPrint('Error creating dispensary entry: $e');
          // Don't block authentication if dispensary creation fails
        }
      }

      // Create Wallet (Idempotent call to backend)
      try {
        await _cloudFunctionsService.createWallet();
      } catch (e) {
        debugPrint("Wallet creation failed (non-fatal): $e");
      }

      emit(Authenticated(userId: user.uid, role: event.role));
    } else {
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
