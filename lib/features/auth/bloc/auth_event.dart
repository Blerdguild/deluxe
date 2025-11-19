// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_event.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {
  const AppStarted();
}

class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthRoleSelected extends AuthEvent {
  final String role;

  const AuthRoleSelected({required this.role});

  @override
  List<Object> get props => [role];
}
