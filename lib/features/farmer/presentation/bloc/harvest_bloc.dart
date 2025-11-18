import 'package:bloc/bloc.dart';
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/domain/repositories/harvest_repository.dart';
import 'package:deluxe/core/repositories/product_repository.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:equatable/equatable.dart';

part 'harvest_event.dart';
part 'harvest_state.dart';

class HarvestBloc extends Bloc<HarvestEvent, HarvestState> {
  final HarvestRepository _harvestRepository;
  final ProductRepository _productRepository;
  final AuthService _authService;

  HarvestBloc({
    required HarvestRepository harvestRepository,
    required ProductRepository productRepository,
    required AuthService authService,
  })  : _harvestRepository = harvestRepository,
        _productRepository = productRepository,
        _authService = authService,
        super(HarvestInitial()) {
    on<LoadHarvests>(_onLoadHarvests);
    on<AddHarvest>(_onAddHarvest);
    on<DeleteHarvest>(_onDeleteHarvest);
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
}
