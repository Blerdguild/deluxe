import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/features/dispensary/domain/repositories/dispensary_sales_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';

class DispensarySalesRepositoryImpl implements DispensarySalesRepository {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  DispensarySalesRepositoryImpl({
    FirebaseFirestore? firestore,
    required AuthService authService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _authService = authService;

  @override
  Stream<List<OrderModel>> getIncomingOrders() {
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
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }
}
