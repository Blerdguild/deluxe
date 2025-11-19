// C:/dev/flutter_projects/deluxe/lib/features/auth/bloc/auth_state.dart

part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

/// Initial state, before any authentication check has been made.
class AuthInitial extends AuthState {}

/// State representing a successfully authenticated user.
class Authenticated extends AuthState {
  // In a real app, you would hold a User model here.
  final String userId;
  final String role;

  const Authenticated({
    required this.userId,
    required this.role,
  });

  @override
  List<Object> get props => [userId, role];
}

/// State representing a user who is not authenticated.
class Unauthenticated extends AuthState {}
