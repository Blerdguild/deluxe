import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/dashboard/domain/repositories/dispensary_repository.dart';
import 'package:deluxe/shared/models/dispensary_model.dart';

class DispensaryRepositoryImpl implements DispensaryRepository {
  final FirebaseFirestore _firestore;

  DispensaryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Dispensary>> getDispensaries() {
    return _firestore.collection('dispensaries').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Dispensary.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> createDispensary(Dispensary dispensary) async {
    try {
      await _firestore
          .collection('dispensaries')
          .doc(dispensary.id)
          .set(dispensary.toJson());
    } catch (e) {
      print('Error creating dispensary: $e');
      rethrow;
    }
  }
}
