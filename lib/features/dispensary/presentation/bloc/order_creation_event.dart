
part of 'order_creation_bloc.dart';

abstract class OrderCreationEvent extends Equatable {
  const OrderCreationEvent();

  @override
  List<Object> get props => [];
}

class CreateOrder extends OrderCreationEvent {
  final Product product;
  final int quantity;

  const CreateOrder({required this.product, required this.quantity});

  @override
  List<Object> get props => [product, quantity];
}
