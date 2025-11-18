import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';

class ConsumerOrderRepositoryImpl implements ConsumerOrderRepository {
  final FirebaseFirestore _firestore;
  final AuthService _authService;

  ConsumerOrderRepositoryImpl({
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
        .where('consumerId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toJson());
  }
}
