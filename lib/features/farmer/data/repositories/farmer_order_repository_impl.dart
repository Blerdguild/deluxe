
import 'package:deluxe/features/farmer/data/datasources/farmer_order_datasource.dart';
import 'package:deluxe/features/farmer/domain/entities/farmer_order.dart';
import 'package:deluxe/features/farmer/domain/repositories/farmer_order_repository.dart';

class FarmerOrderRepositoryImpl implements FarmerOrderRepository {
  final FarmerOrderDataSource dataSource;

  FarmerOrderRepositoryImpl({required this.dataSource});

  @override
  Future<List<FarmerOrder>> getOrders() {
    return dataSource.getOrders();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String newStatus) {
    return dataSource.updateOrderStatus(orderId, newStatus);
  }

  @override
  Future<void> addOrder(FarmerOrder order) {
    return dataSource.addOrder(order);
  }
}
