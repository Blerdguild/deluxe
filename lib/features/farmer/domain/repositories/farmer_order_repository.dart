
import 'package:deluxe/features/farmer/domain/entities/farmer_order.dart';

abstract class FarmerOrderRepository {
  Future<List<FarmerOrder>> getOrders();
  Future<void> updateOrderStatus(String orderId, String newStatus);
  Future<void> addOrder(FarmerOrder order);
}
