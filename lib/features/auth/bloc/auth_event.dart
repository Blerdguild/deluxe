import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event fired when the auth state changes (e.g., user signs in or out).
class AuthUserChanged extends AuthEvent {
  final User? user;

  const AuthUserChanged({this.user});

  @override
  List<Object?> get props => [user];
}

/// Event fired when the user requests to sign in with Google.
class SignInWithGoogleRequested extends AuthEvent {}

/// Event fired when the user requests to sign out.
class SignOutRequested extends AuthEvent {}
