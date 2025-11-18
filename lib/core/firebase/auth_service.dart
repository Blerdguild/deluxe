
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// A service class that wraps FirebaseAuth functionality.
///
/// This service provides a stream of the current user's authentication state
/// and includes methods for sign-in, sign-up, and sign-out.
class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// A stream that emits the current [User] when the authentication state changes.
  ///
  /// Emits null if the user is signed out.
  Stream<User?> get user => _firebaseAuth.authStateChanges();

  /// Signs in the user with Google and then with Firebase.
  ///
  /// Returns the [UserCredential] from Firebase.
  /// Throws an exception if the Google Sign-In process is canceled by the user.
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the Google Sign-In flow.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // If the user canceled the sign-in, throw an exception.
    if (googleUser == null) {
      throw Exception('Google Sign In canceled by user.');
    }

    // Obtain the auth details from the request.
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential for Firebase.
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential.
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs out the current user from both Firebase and Google.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
