
import 'package:deluxe/features/farmer/domain/entities/farmer_order.dart';

abstract class FarmerOrderDataSource {
  Future<List<FarmerOrder>> getOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
  Future<void> addOrder(FarmerOrder order);
}

class FarmerOrderLocalDataSource implements FarmerOrderDataSource {
  // In a real app, this would be a database or a remote API call.
  final List<FarmerOrder> _orders = [
    FarmerOrder(
      id: '1',
      strainName: 'OG Kush',
      quantity: 2.5,
      dispensaryName: 'The Green Room',
      status: 'Pending',
      orderDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    FarmerOrder(
      id: '2',
      strainName: 'Sour Diesel',
      quantity: 1.0,
      dispensaryName: 'Kind Care',
      status: 'Accepted',
      orderDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    FarmerOrder(
      id: '3',
      strainName: 'Blue Dream',
      quantity: 5.0,
      dispensaryName: 'The Green Room',
      status: 'Shipped',
      orderDate: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  @override
  Future<List<FarmerOrder>> getOrders() async {
    return _orders;
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final order = _orders[index];
      // Create a new instance with the updated status
      _orders[index] = FarmerOrder(
        id: order.id,
        strainName: order.strainName,
        quantity: order.quantity,
        dispensaryName: order.dispensaryName,
        status: newStatus, // The new status
        orderDate: order.orderDate,
      );
    }
  }

  @override
  Future<void> addOrder(FarmerOrder order) async {
    _orders.add(order);
  }
}
