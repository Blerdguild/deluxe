part of 'consumer_order_bloc.dart';

abstract class ConsumerOrderEvent extends Equatable {
  const ConsumerOrderEvent();

  @override
  List<Object> get props => [];
}

class PlaceConsumerOrder extends ConsumerOrderEvent {
  final ConsumerOrder order;

  const PlaceConsumerOrder({required this.order});

  @override
  List<Object> get props => [order];
}

class LoadConsumerOrders extends ConsumerOrderEvent {}
