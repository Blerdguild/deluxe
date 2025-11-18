part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductEvent {}

class ProductUpdate extends ProductEvent {
  final List<Product> products;

  const ProductUpdate({required this.products});

  @override
  List<Object> get props => [products];
}

class _ProductsUpdateFailed extends ProductEvent {
  final String message;

  const _ProductsUpdateFailed({required this.message});

  @override
  List<Object> get props => [message];
}
