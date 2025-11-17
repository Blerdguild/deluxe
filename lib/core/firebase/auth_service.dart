
import 'package:firebase_auth/firebase_auth.dart';

/// A service class that wraps FirebaseAuth functionality.
///
/// This service provides a stream of the current user's authentication state
/// and will be expanded to include methods for sign-in, sign-up, sign-out,
/// and custom claims management.
class AuthService {
  final FirebaseAuth _firebaseAuth;

  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// A stream that emits the current [User] when the authentication state changes.
  ///
  /// Emits null if the user is signed out.
  Stream<User?> get user => _firebaseAuth.authStateChanges();
}
