// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import './auth_event.dart';
import './auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthUninitialized()) {
    on<AppStarted>(_onAppStarted);
  }

  void _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    // For now, we'll just yield unauthenticated.
    // Later, this will check for a valid token.
    emit(AuthUnauthenticated());
  }
}
