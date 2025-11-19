import 'package:bloc/bloc.dart';
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/domain/repositories/harvest_repository.dart';
import 'package:deluxe/core/repositories/product_repository.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/core/firebase/cloud_functions_service.dart';
import 'package:equatable/equatable.dart';

part 'harvest_event.dart';
part 'harvest_state.dart';

class HarvestBloc extends Bloc<HarvestEvent, HarvestState> {
  final HarvestRepository _harvestRepository;
  final ProductRepository _productRepository;
  final AuthService _authService;
  final CloudFunctionsService _cloudFunctionsService;

  HarvestBloc({
    required HarvestRepository harvestRepository,
    required ProductRepository productRepository,
    required AuthService authService,
    required CloudFunctionsService cloudFunctionsService,
  })  : _harvestRepository = harvestRepository,
        _productRepository = productRepository,
        _authService = authService,
        _cloudFunctionsService = cloudFunctionsService,
        super(HarvestInitial()) {
    on<LoadHarvests>(_onLoadHarvests);
    on<AddHarvest>(_onAddHarvest);
    on<DeleteHarvest>(_onDeleteHarvest);
    on<TokenizeHarvest>(_onTokenizeHarvest);
  }

  Future<void> _onLoadHarvests(
    LoadHarvests event,
    Emitter<HarvestState> emit,
  ) async {
    emit(HarvestLoading());
    try {
      final harvests = await _harvestRepository.getHarvests();
      emit(HarvestLoaded(harvests));
    } catch (e) {
      emit(HarvestError(e.toString()));
    }
  }

  Future<void> _onAddHarvest(
    AddHarvest event,
    Emitter<HarvestState> emit,
  ) async {
    try {
      await _harvestRepository.addHarvest(event.harvest);

      // Create corresponding Product in Firestore
      final currentUser = _authService.getCurrentUser();
      final farmerId = currentUser?.uid ?? 'unknown_farmer';
      final farmerName =
          currentUser?.displayName ?? currentUser?.email ?? 'Unknown Farmer';

      final product = Product(
        id: event.harvest.id,
        name: event.harvest.strainName,
        type: 'Flower', // Default type
        price: 0.0, // Default price, to be set by farmer later
        rating: 0.0,
        reviewCount: 0,
        imageUrl: '', // Placeholder
        description:
            'Harvested on ${event.harvest.harvestDate.toString().split(' ')[0]}',
        dispensaryId: '',
        farmerId: farmerId,
        farmerName: farmerName,
        weight: event.harvest.weight,
      );

      await _productRepository.createProduct(product);

      add(LoadHarvests());
    } catch (e) {
      emit(HarvestError('Failed to add harvest: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteHarvest(
    DeleteHarvest event,
    Emitter<HarvestState> emit,
  ) async {
    try {
      await _harvestRepository.deleteHarvest(event.harvestId);
      add(LoadHarvests());
    } catch (e) {
      emit(HarvestError('Failed to delete harvest: ${e.toString()}'));
    }
  }

  Future<void> _onTokenizeHarvest(
    TokenizeHarvest event,
    Emitter<HarvestState> emit,
  ) async {
    try {
      // 1. Get Current User Wallet
      // In a real app, we should fetch this from Firestore or state.
      // For now, we'll assume the wallet was created on login.
      // We can re-fetch it or pass it.
      // Ideally, we call a method to get the wallet address.
      // Since createWallet is idempotent and returns the address, we can call it.

      final walletAddress = await _cloudFunctionsService.createWallet();

      if (walletAddress == null) {
        throw Exception("No wallet found for user.");
      }

      // 2. Prepare Metadata
      final metadata = {
        'name': event.harvest.strainName,
        'description': 'Harvested on ${event.harvest.harvestDate}',
        'image': 'https://placehold.co/400', // TODO: Use real image URL
        'properties': {
          'harvestId': event.harvest.id,
          'weight': event.harvest.weight,
        }
      };

      // 3. Call Mint Function
      await _cloudFunctionsService.mintBatchNFT(
        recipientAddress: walletAddress,
        metadata: metadata,
        supply: event.supply,
      );

      // 4. Update Product/Harvest to show it's tokenized (Optional for now)
      // await _productRepository.updateProductTokenInfo(...)

      add(LoadHarvests()); // Refresh UI
    } catch (e) {
      emit(HarvestError('Failed to tokenize harvest: ${e.toString()}'));
    }
  }
}
