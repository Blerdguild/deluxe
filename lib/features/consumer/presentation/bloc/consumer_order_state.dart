part of 'consumer_order_bloc.dart';

abstract class ConsumerOrderState extends Equatable {
  const ConsumerOrderState();

  @override
  List<Object> get props => [];
}

// Initial State
class ConsumerOrderInitial extends ConsumerOrderState {}

// States for Loading Orders
class ConsumerOrderLoadInProgress extends ConsumerOrderState {}

class ConsumerOrderLoadSuccess extends ConsumerOrderState {
  final List<ConsumerOrder> orders;

  const ConsumerOrderLoadSuccess({required this.orders});

  @override
  List<Object> get props => [orders];
}

class ConsumerOrderLoadFailure extends ConsumerOrderState {
  final String message;

  const ConsumerOrderLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// States for Placing an Order
class ConsumerOrderPlacementInProgress extends ConsumerOrderState {}

class ConsumerOrderPlacementSuccess extends ConsumerOrderState {}

class ConsumerOrderPlacementFailure extends ConsumerOrderState {
  final String message;

  const ConsumerOrderPlacementFailure({required this.message});

  @override
  List<Object> get props => [message];
}
