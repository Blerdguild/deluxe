import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/farmer/data/datasources/farmer_order_datasource.dart';
import 'package:deluxe/features/farmer/domain/entities/farmer_order.dart';

class FarmerOrderFirestoreDataSource implements FarmerOrderDataSource {
  final FirebaseFirestore _firestore;
  final String _userId;

  FarmerOrderFirestoreDataSource({
    required FirebaseFirestore firestore,
    required String userId,
  })  : _firestore = firestore,
        _userId = userId;

  @override
  Future<List<FarmerOrder>> getOrders() async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('sellerId', isEqualTo: _userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return FarmerOrder(
          id: doc.id,
          strainName: data['productName'] ?? 'Unknown Product',
          quantity: (data['quantity'] as num?)?.toDouble() ?? 0.0,
          dispensaryName: data['buyerName'] ?? 'Unknown Buyer',
          status: data['status'] ?? 'Pending',
          orderDate:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error getting farmer orders: $e');
      return [];
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      print('Error updating order status: $e');
      rethrow;
    }
  }

  @override
  Future<void> addOrder(FarmerOrder order) async {
    // Farmers usually don't add orders manually in this context (consumers do),
    // but implementing for interface compliance and potential future use.
    try {
      await _firestore.collection('orders').doc(order.id).set({
        'sellerId': _userId,
        'productName': order.strainName,
        'quantity': order.quantity,
        'buyerName': order.dispensaryName,
        'status': order.status,
        'createdAt': Timestamp.fromDate(order.orderDate),
      });
    } catch (e) {
      print('Error adding order: $e');
      rethrow;
    }
  }
}
