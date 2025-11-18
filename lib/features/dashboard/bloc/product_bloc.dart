import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/firestore_service.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:equatable/equatable.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FirestoreService _firestoreService;
  StreamSubscription? _productSubscription;

  ProductBloc({required FirestoreService firestoreService})
      : _firestoreService = firestoreService,
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
    _productSubscription = _firestoreService.getProducts().listen(
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
