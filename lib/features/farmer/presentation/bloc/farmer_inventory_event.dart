part of 'farmer_inventory_bloc.dart';

abstract class FarmerInventoryEvent extends Equatable {
  const FarmerInventoryEvent();

  @override
  List<Object> get props => [];
}

class LoadInventory extends FarmerInventoryEvent {}

class UpdateProduct extends FarmerInventoryEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object> get props => [product];
}
