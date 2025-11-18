import 'package:deluxe/features/consumer/domain/entities/consumer_order.dart';

// Abstract contract
abstract class ConsumerOrderDataSource {
  Future<List<ConsumerOrder>> getOrders();
  Future<void> addOrder(ConsumerOrder order);
}

// Concrete local implementation
class ConsumerOrderLocalDataSource implements ConsumerOrderDataSource {
  final List<ConsumerOrder> _orders = [
    ConsumerOrder(
      id: 'co1',
      productName: 'OG Kush',
      quantity: 2,
      dispensaryId: 'disp1',
      consumerId: 'user123',
      status: 'Ready for Pickup',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<ConsumerOrder>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network latency
    return _orders;
  }

  @override
  Future<void> addOrder(ConsumerOrder order) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network latency
    _orders.add(order);
  }
}
