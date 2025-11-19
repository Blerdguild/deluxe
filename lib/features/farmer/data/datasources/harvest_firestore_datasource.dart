import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/data/datasources/harvest_datasource.dart';

class HarvestFirestoreDataSource implements HarvestDataSource {
  final FirebaseFirestore _firestore;
  final String _userId;

  HarvestFirestoreDataSource({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  @override
  Future<List<Harvest>> getHarvests() async {
    try {
      final snapshot = await _firestore
          .collection('harvests')
          .where('farmerId', isEqualTo: _userId)
          .orderBy('harvestDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Harvest(
                id: doc.id,
                strainName: doc.data()['strainName'] as String,
                weight: (doc.data()['weight'] as num).toDouble(),
                harvestDate: (doc.data()['harvestDate'] as Timestamp).toDate(),
              ))
          .toList();
    } catch (e) {
      print('Error getting harvests: $e');
      return [];
    }
  }

  @override
  Future<void> addHarvest(Harvest harvest) async {
    try {
      await _firestore.collection('harvests').doc(harvest.id).set({
        'farmerId': _userId,
        'strainName': harvest.strainName,
        'weight': harvest.weight,
        'harvestDate': Timestamp.fromDate(harvest.harvestDate),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding harvest: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteHarvest(String harvestId) async {
    try {
      await _firestore.collection('harvests').doc(harvestId).delete();
    } catch (e) {
      print('Error deleting harvest: $e');
      rethrow;
    }
  }
}
