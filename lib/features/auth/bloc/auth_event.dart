// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_event.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

/// Event dispatched when the app first starts to check the current auth state.
class AppStarted extends AuthEvent {
  const AppStarted();
}

// FIX: Define the new event class for handling Google Sign-In requests.
/// Event dispatched when the user presses the "Sign In with Google" button.
class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// Event dispatched when the user attempts to sign out.
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
