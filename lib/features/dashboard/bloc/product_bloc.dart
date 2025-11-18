import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/repositories/product_repository.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository _productRepository;
  StreamSubscription? _productSubscription;

  ProductBloc({required ProductRepository productRepository})
      : _productRepository = productRepository,
        super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<ProductUpdate>(_onProductUpdate);
    on<_ProductsUpdateFailed>(_onProductsUpdateFailed);
  }

  void _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductLoading());
    _productSubscription?.cancel();
    _productSubscription = _productRepository.getProducts().listen(
          (products) => add(ProductUpdate(products: products)),
          onError: (error) =>
              add(_ProductsUpdateFailed(message: error.toString())),
        );
  }

  void _onProductUpdate(
    ProductUpdate event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductLoaded(products: event.products));
  }

  void _onProductsUpdateFailed(
    _ProductsUpdateFailed event,
    Emitter<ProductState> emit,
  ) {
    emit(ProductError(message: event.message));
  }

  @override
  Future<void> close() {
    _productSubscription?.cancel();
    return super.close();
  }
}
