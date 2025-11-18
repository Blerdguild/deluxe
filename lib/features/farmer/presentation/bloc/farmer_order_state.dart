part of 'farmer_order_bloc.dart';

abstract class FarmerOrderState extends Equatable {
  const FarmerOrderState();

  @override
  List<Object> get props => [];
}

class FarmerOrderInitial extends FarmerOrderState {}

class FarmerOrderLoading extends FarmerOrderState {}

class FarmerOrderLoaded extends FarmerOrderState {
  final List<FarmerOrder> orders;

  const FarmerOrderLoaded(this.orders);

  @override
  List<Object> get props => [orders];
}

class FarmerOrderError extends FarmerOrderState {
  final String message;

  const FarmerOrderError(this.message);

  @override
  List<Object> get props => [message];
}
