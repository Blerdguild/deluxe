import 'package:deluxe/features/consumer/domain/entities/consumer_order.dart';

// Abstract contract for the consumer order repository
abstract class ConsumerOrderRepository {
  Future<List<ConsumerOrder>> getOrders();
  Future<void> addOrder(ConsumerOrder order);
}
