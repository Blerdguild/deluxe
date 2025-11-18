part of 'dispensary_bloc.dart';

abstract class DispensaryState extends Equatable {
  const DispensaryState();

  @override
  List<Object> get props => [];
}

class DispensaryInitial extends DispensaryState {}

class DispensaryLoading extends DispensaryState {}

class DispensaryLoaded extends DispensaryState {
  final List<Dispensary> dispensaries;

  const DispensaryLoaded({required this.dispensaries});

  @override
  List<Object> get props => [dispensaries];
}

class DispensaryError extends DispensaryState {
  final String message;

  const DispensaryError({required this.message});

  @override
  List<Object> get props => [message];
}
