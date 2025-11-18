import 'package:cloud_firestore/cloud_firestore.dart';

/// A model class representing a user in the application.
class UserModel {
  const UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    required this.role,
  });

  /// The user's unique ID.
  final String uid;

  /// The user's email address.
  final String? email;

  /// The user's display name.
  final String? displayName;

  /// The URL of the user's profile picture.
  final String? photoURL;

  /// The user's role (e.g., 'consumer', 'farmer', 'dispensary').
  final String role;

  /// Creates a [UserModel] from a Firestore document.
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    return UserModel(
      uid: doc.id,
      email: data?['email'] as String?,
      displayName: data?['displayName'] as String?,
      photoURL: data?['photoURL'] as String?,
      role: data?['role'] as String? ?? 'consumer', // Default to consumer
    );
  }
}
