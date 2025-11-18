import 'package:deluxe/shared/models/order_model.dart';

// Abstract contract for the consumer order repository
abstract class ConsumerOrderRepository {
  Stream<List<OrderModel>> getOrders();
  Future<void> createOrder(OrderModel order);
}
