part of 'farmer_inventory_bloc.dart';

abstract class FarmerInventoryState extends Equatable {
  const FarmerInventoryState();

  @override
  List<Object> get props => [];
}

class FarmerInventoryInitial extends FarmerInventoryState {}

class FarmerInventoryLoading extends FarmerInventoryState {}

class FarmerInventoryLoaded extends FarmerInventoryState {
  final List<Product> products;

  const FarmerInventoryLoaded(this.products);

  @override
  List<Object> get props => [products];
}

class FarmerInventoryError extends FarmerInventoryState {
  final String message;

  const FarmerInventoryError(this.message);

  @override
  List<Object> get props => [message];
}
