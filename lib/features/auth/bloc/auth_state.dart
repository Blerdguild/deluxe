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

  const Authenticated({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// State representing a user who is not authenticated.
class Unauthenticated extends AuthState {}

