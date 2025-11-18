import 'dart:async';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/shared/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(AuthUninitialized()) {
    _userSubscription = _authService.user.listen((user) {
      add(AuthUserChanged(user: user));
    });

    on<AuthUserChanged>(_onAuthUserChanged);
    on<SignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final firebaseUser = event.user;
    if (firebaseUser != null) {
      try {
        final userDocStream = _firestoreService.userStream(firebaseUser);
        if (userDocStream == null) {
          emit(AuthUnauthenticated());
          return;
        }

        final userDoc = await userDocStream.first;

        if (userDoc.exists) {
          emit(AuthAuthenticated(user: UserModel.fromDocument(userDoc)));
        } else {
          await _firestoreService.createUser(user: firebaseUser, role: 'consumer');
          final newUser = UserModel(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
            role: 'consumer',
          );
          emit(AuthAuthenticated(user: newUser));
        }
      } catch (e) {
        emit(AuthUnauthenticated());
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignInWithGoogleRequested(
    SignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await _authService.signOut();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
