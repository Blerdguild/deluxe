import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/features/farmer/domain/repositories/farmer_order_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';

class FarmerOrderRepositoryImpl implements FarmerOrderRepository {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  FarmerOrderRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthService authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService;

  @override
  Stream<List<OrderModel>> getOrders() {
    final user = _authService.getCurrentUser();
    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('sellerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final orderDoc = await _firestore.collection('orders').doc(orderId).get();
    if (!orderDoc.exists) return;

    final order = OrderModel.fromSnapshot(orderDoc);

    // 1. Handle Inventory Deduction on Acceptance
    if (newStatus == 'Accepted' && order.status != 'Accepted') {
      final batch = _firestore.batch();

      for (final item in order.items) {
        // Deduct from Farmer's inventory (original product)
        final productRef = _firestore.collection('products').doc(item.id);
        batch.update(productRef, {
          'quantity': FieldValue.increment(-item.quantity),
        });
      }

      // Update order status
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {'status': newStatus});

      await batch.commit();
      return;
    }

    // 2. Handle Dispensary Inventory Addition on Delivery
    if (newStatus == 'Delivered' && order.status != 'Delivered') {
      final batch = _firestore.batch();

      for (final item in order.items) {
        // Create new product for Dispensary
        final newProductRef = _firestore.collection('products').doc();

        final newProductData = item.toJson();
        // Override specific fields for the new owner (Dispensary)
        newProductData['dispensaryId'] = order.consumerId;
        newProductData['quantity'] = item.quantity;
        // Reset ratings for the new listing
        newProductData['rating'] = 0.0;
        newProductData['reviewCount'] = 0;
        // Optionally, we could set a default markup price here, e.g., item.price * 1.5
        // For now, we keep the wholesale price as the base

        batch.set(newProductRef, newProductData);
      }

      // Update order status
      final orderRef = _firestore.collection('orders').doc(orderId);
      batch.update(orderRef, {'status': newStatus});

      await batch.commit();
      return;
    }

    // Default update for other statuses (e.g., Pending -> Declined, Shipped)
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }
}
