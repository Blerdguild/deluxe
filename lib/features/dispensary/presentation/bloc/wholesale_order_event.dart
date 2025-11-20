part of 'wholesale_order_bloc.dart';

abstract class WholesaleOrderEvent extends Equatable {
  const WholesaleOrderEvent();

  @override
  List<Object> get props => [];
}

class LoadWholesaleOrders extends WholesaleOrderEvent {}

class _WholesaleOrdersUpdated extends WholesaleOrderEvent {
  final List<OrderModel> orders;

  const _WholesaleOrdersUpdated(this.orders);

  @override
  List<Object> get props => [orders];
}

class _WholesaleOrdersError extends WholesaleOrderEvent {
  final String message;

  const _WholesaleOrdersError(this.message);

  @override
  List<Object> get props => [message];
}

class PlaceWholesaleOrder extends WholesaleOrderEvent {
  final OrderModel order;

  const PlaceWholesaleOrder(this.order);

  @override
  List<Object> get props => [order];
}
