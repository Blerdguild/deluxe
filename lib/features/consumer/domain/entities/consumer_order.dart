import 'package:equatable/equatable.dart';

class ConsumerOrder extends Equatable {
  final String id;
  final String productName;
  final int quantity;
  final String dispensaryId;
  final String consumerId;
  final String status;
  final DateTime orderDate;

  const ConsumerOrder({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.dispensaryId,
    required this.consumerId,
    required this.status,
    required this.orderDate,
  });

  @override
  List<Object?> get props => [
        id,
        productName,
        quantity,
        dispensaryId,
        consumerId,
        status,
        orderDate,
      ];
}
