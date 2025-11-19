import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/core/repositories/product_repository.dart';
import 'package:deluxe/core/firebase/cloud_functions_service.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:equatable/equatable.dart';

part 'farmer_inventory_event.dart';
part 'farmer_inventory_state.dart';

class FarmerInventoryBloc
    extends Bloc<FarmerInventoryEvent, FarmerInventoryState> {
  final ProductRepository _productRepository;
  final AuthService _authService;
  final CloudFunctionsService _cloudFunctionsService;
  StreamSubscription? _inventorySubscription;

  FarmerInventoryBloc({
    required ProductRepository productRepository,
    required AuthService authService,
    required CloudFunctionsService cloudFunctionsService,
  })  : _productRepository = productRepository,
        _authService = authService,
        _cloudFunctionsService = cloudFunctionsService,
        super(FarmerInventoryInitial()) {
    on<LoadInventory>(_onLoadInventory);
    on<UpdateProduct>(_onUpdateProduct);
    on<TokenizeProduct>(_onTokenizeProduct);
    on<_InventoryUpdated>(_onInventoryUpdated);
    on<_InventoryError>(_onInventoryError);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<FarmerInventoryState> emit,
  ) async {
    emit(FarmerInventoryLoading());

    final user = _authService.getCurrentUser();
    if (user == null) {
      emit(const FarmerInventoryError('User not authenticated'));
      return;
    }

    await _inventorySubscription?.cancel();
    _inventorySubscription =
        _productRepository.getProductsByFarmer(user.uid).listen(
              (products) => add(_InventoryUpdated(products)),
              onError: (error) => add(_InventoryError(error.toString())),
            );
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<FarmerInventoryState> emit,
  ) async {
    try {
      await _productRepository.updateProduct(event.product);
      // No need to emit state here as the stream listener will pick up the change
    } catch (e) {
      emit(FarmerInventoryError('Failed to update product: ${e.toString()}'));
    }
  }

  Future<void> _onTokenizeProduct(
    TokenizeProduct event,
    Emitter<FarmerInventoryState> emit,
  ) async {
    try {
      // 1. Get Current User Wallet (Idempotent)
      final walletAddress = await _cloudFunctionsService.createWallet();

      if (walletAddress == null) {
        throw Exception("No wallet found for user.");
      }

      // 2. Prepare Metadata
      final metadata = {
        'name': event.product.name,
        'description': event.product.description,
        'image': event.product.imageUrl.isNotEmpty
            ? event.product.imageUrl
            : 'https://placehold.co/400',
        'properties': {
          'productId': event.product.id,
          'weight': event.product.weight,
          'price': event.product.price,
        }
      };

      // 3. Call Mint Function
      await _cloudFunctionsService.mintBatchNFT(
        recipientAddress: walletAddress,
        metadata: metadata,
        supply: event.supply,
      );

      // Optionally show success message or update product state
      // For now, we just reload or keep state
      // emit(FarmerInventoryTokenizedSuccess()); // If we had such state
    } catch (e) {
      emit(FarmerInventoryError('Failed to tokenize product: ${e.toString()}'));
    }
  }

  // Internal events for stream updates
  Future<void> _onInventoryUpdated(
    _InventoryUpdated event,
    Emitter<FarmerInventoryState> emit,
  ) async {
    emit(FarmerInventoryLoaded(event.products));
  }

  Future<void> _onInventoryError(
    _InventoryError event,
    Emitter<FarmerInventoryState> emit,
  ) async {
    emit(FarmerInventoryError(event.message));
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}

// Private events for stream handling
class _InventoryUpdated extends FarmerInventoryEvent {
  final List<Product> products;
  const _InventoryUpdated(this.products);
}

class _InventoryError extends FarmerInventoryEvent {
  final String message;
  const _InventoryError(this.message);
}
