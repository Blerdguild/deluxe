import 'package:deluxe/features/consumer/data/datasources/consumer_order_datasource.dart';
import 'package:deluxe/features/consumer/domain/entities/consumer_order.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';

class ConsumerOrderRepositoryImpl implements ConsumerOrderRepository {
  final ConsumerOrderDataSource dataSource;

  ConsumerOrderRepositoryImpl({required this.dataSource});

  @override
  Future<List<ConsumerOrder>> getOrders() {
    return dataSource.getOrders();
  }

  @override
  Future<void> addOrder(ConsumerOrder order) {
    return dataSource.addOrder(order);
  }
}
