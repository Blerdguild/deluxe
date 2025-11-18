part of 'dispensary_bloc.dart';

abstract class DispensaryEvent extends Equatable {
  const DispensaryEvent();

  @override
  List<Object> get props => [];
}

class LoadDispensaries extends DispensaryEvent {}
