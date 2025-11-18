import 'package:deluxe/shared/models/order_model.dart';

abstract class FarmerOrderRepository {
  Stream<List<OrderModel>> getOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
}
