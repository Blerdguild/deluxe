part of 'wholesale_order_bloc.dart';

abstract class WholesaleOrderState extends Equatable {
  const WholesaleOrderState();

  @override
  List<Object> get props => [];
}

class WholesaleOrderInitial extends WholesaleOrderState {}

class WholesaleOrderLoadInProgress extends WholesaleOrderState {}

class WholesaleOrderLoadSuccess extends WholesaleOrderState {
  final List<OrderModel> orders;

  const WholesaleOrderLoadSuccess({this.orders = const []});

  @override
  List<Object> get props => [orders];
}

class WholesaleOrderLoadFailure extends WholesaleOrderState {
  final String message;

  const WholesaleOrderLoadFailure({required this.message});

  @override
  List<Object> get props => [message];
}
