
part of 'order_creation_bloc.dart';

abstract class OrderCreationState extends Equatable {
  const OrderCreationState();

  @override
  List<Object> get props => [];
}

class OrderCreationInitial extends OrderCreationState {}

class OrderCreationInProgress extends OrderCreationState {}

class OrderCreationSuccess extends OrderCreationState {}

class OrderCreationFailure extends OrderCreationState {
  final String message;

  const OrderCreationFailure({required this.message});

  @override
  List<Object> get props => [message];
}
