// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_bloc.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  StreamSubscription<User?>? _userSubscription;

  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthUninitialized()) {
    _userSubscription = _authService.user.listen((user) {
      add(AuthUserChanged(user: user));
    });

    on<AuthUserChanged>(_onAuthUserChanged);
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(user: event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
