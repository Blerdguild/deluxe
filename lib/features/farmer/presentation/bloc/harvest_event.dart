part of 'harvest_bloc.dart';

abstract class HarvestEvent extends Equatable {
  const HarvestEvent();

  @override
  List<Object> get props => [];
}

class LoadHarvests extends HarvestEvent {}

class AddHarvest extends HarvestEvent {
  final Harvest harvest;

  const AddHarvest(this.harvest);

  @override
  List<Object> get props => [harvest];
}

class DeleteHarvest extends HarvestEvent {
  final String harvestId;

  const DeleteHarvest(this.harvestId);

  @override
  List<Object> get props => [harvestId];
}

class TokenizeHarvest extends HarvestEvent {
  final Harvest harvest;
  final int supply;

  const TokenizeHarvest({required this.harvest, required this.supply});

  @override
  List<Object> get props => [harvest, supply];
}
