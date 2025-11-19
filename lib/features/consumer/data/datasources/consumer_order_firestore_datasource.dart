import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/consumer/data/datasources/consumer_order_datasource.dart';
import 'package:deluxe/features/consumer/domain/entities/consumer_order.dart';

class ConsumerOrderFirestoreDataSource implements ConsumerOrderDataSource {
  final FirebaseFirestore _firestore;
  final String _userId;

  ConsumerOrderFirestoreDataSource({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  @override
  Future<List<ConsumerOrder>> getOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('consumerId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ConsumerOrder(
          id: doc.id,
          productName: data['productName'] ?? 'Unknown Product',
          quantity: (data['quantity'] as num?)?.toInt() ?? 0,
          dispensaryId: data['sellerId'] ??
              'unknown_dispensary', // Mapping sellerId to dispensaryId
          consumerId: data['consumerId'] ?? _userId,
          status: data['status'] ?? 'Pending',
          orderDate:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error getting consumer orders: $e');
      return [];
    }
  }

  @override
  Future<void> addOrder(ConsumerOrder order) async {
    try {
      await _firestore.collection('orders').doc(order.id).set({
        'consumerId': _userId,
        'productName': order.productName,
        'quantity': order.quantity,
        'sellerId': order.dispensaryId, // Mapping dispensaryId to sellerId
        'status': order.status,
        'createdAt': Timestamp.fromDate(order.orderDate),
      });
    } catch (e) {
      print('Error adding consumer order: $e');
      rethrow;
    }
  }
}
