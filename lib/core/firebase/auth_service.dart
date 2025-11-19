// C:/dev/flutter_projects/deluxe/lib/core/firebase/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthService({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  // FIX: Define the 'getCurrentUser' method.
  /// Returns the current Firebase [User] if one is signed in, otherwise returns null.
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Initiates the Google Sign-In flow.
  ///
  /// Throws a [FirebaseAuthException] if the process fails at the Firebase level.
  /// Returns a [UserCredential] upon success.
  Future<UserCredential> signInWithGoogle() async {
    // Trigger the Google authentication flow.
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // If the user cancels the flow, googleUser will be null.
    if (googleUser == null) {
      throw Exception('Google Sign-In was cancelled by the user.');
    }

    // Obtain the auth details from the request.
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential for Firebase.
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential.
    return await _firebaseAuth.signInWithCredential(credential);
  }

  /// Signs the current user out from both Firebase and Google.
  Future<void> signOut() async {
    // We sign out from both services to ensure a clean logout.
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  /// Fetches the user's role from the 'users' collection in Firestore.
  /// Returns 'consumer' if the user document or role field doesn't exist.
  Future<String> getUserRole(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null && doc.data()!.containsKey('role')) {
        return doc.data()!['role'] as String;
      }
    } catch (e) {
      // Log error or handle appropriately
      print('Error fetching user role: $e');
    }
    return 'consumer'; // Default role
  }
}
