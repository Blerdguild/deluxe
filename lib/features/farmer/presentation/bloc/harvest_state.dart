part of 'harvest_bloc.dart';

abstract class HarvestState extends Equatable {
  const HarvestState();

  @override
  List<Object> get props => [];
}

class HarvestInitial extends HarvestState {}

class HarvestLoading extends HarvestState {}

class HarvestLoaded extends HarvestState {
  final List<Harvest> harvests;

  const HarvestLoaded(this.harvests);

  @override
  List<Object> get props => [harvests];
}

class HarvestError extends HarvestState {
  final String message;

  const HarvestError(this.message);

  @override
  List<Object> get props => [message];
}
