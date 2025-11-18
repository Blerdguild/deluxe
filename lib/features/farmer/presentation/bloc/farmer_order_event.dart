part of 'farmer_order_bloc.dart';

abstract class FarmerOrderEvent extends Equatable {
  const FarmerOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadFarmerOrders extends FarmerOrderEvent {}

class UpdateOrderStatus extends FarmerOrderEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatus(this.orderId, this.newStatus);

  @override
  List<Object> get props => [orderId, newStatus];
}
