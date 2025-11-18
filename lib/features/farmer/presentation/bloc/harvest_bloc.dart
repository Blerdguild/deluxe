
import 'package:bloc/bloc.dart';
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/domain/repositories/harvest_repository.dart';
import 'package:equatable/equatable.dart';

part 'harvest_event.dart';
part 'harvest_state.dart';

class HarvestBloc extends Bloc<HarvestEvent, HarvestState> {
  final HarvestRepository _harvestRepository;

  HarvestBloc({required HarvestRepository harvestRepository})
      : _harvestRepository = harvestRepository,
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
