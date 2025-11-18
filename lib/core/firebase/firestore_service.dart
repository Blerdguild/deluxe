import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/shared/models/dispensary_model.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service that provides access to Firestore.
///
/// This service is responsible for all interactions with the Firestore database.
/// It provides methods for reading, writing, and updating data.
class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns a stream of the user's data from the `users` collection.
  ///
  /// The stream will emit `null` if the user is not logged in.
  Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream(User? user) {
    if (user == null) {
      return null;
    }
    return _firestore.collection('users').doc(user.uid).snapshots();
  }

  /// Creates a new user document in the `users` collection.
  ///
  /// This method is called when a new user signs up.
  Future<void> createUser({
    required User user,
    required String role,
  }) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'photoURL': user.photoURL,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Returns a stream of all dispensaries.
  Stream<List<Dispensary>> getDispensaries() {
    return _firestore.collection('dispensaries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Dispensary.fromSnapshot(doc)).toList();
    });
  }

  /// Returns a stream of all products.
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromSnapshot(doc)).toList();
    });
  }
}
