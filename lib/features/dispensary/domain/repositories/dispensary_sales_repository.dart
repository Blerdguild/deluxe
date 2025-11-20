import 'package:deluxe/shared/models/order_model.dart';

abstract class DispensarySalesRepository {
  Stream<List<OrderModel>> getIncomingOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
}
