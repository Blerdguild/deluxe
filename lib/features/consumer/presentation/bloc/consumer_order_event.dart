part of 'consumer_order_bloc.dart';

abstract class ConsumerOrderEvent extends Equatable {
  const ConsumerOrderEvent();

  @override
  List<Object> get props => [];
}

class PlaceConsumerOrder extends ConsumerOrderEvent {
  final OrderModel order;

  const PlaceConsumerOrder({required this.order});

  @override
  List<Object> get props => [order];
}

class LoadConsumerOrders extends ConsumerOrderEvent {}

class _ConsumerOrdersUpdated extends ConsumerOrderEvent {
  final List<OrderModel> orders;
  const _ConsumerOrdersUpdated(this.orders);
  @override
  List<Object> get props => [orders];
}

class _ConsumerOrdersError extends ConsumerOrderEvent {
  final String message;
  const _ConsumerOrdersError(this.message);
  @override
  List<Object> get props => [message];
}
