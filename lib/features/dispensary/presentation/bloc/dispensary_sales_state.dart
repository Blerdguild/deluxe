part of 'dispensary_sales_bloc.dart';

abstract class DispensarySalesState extends Equatable {
  const DispensarySalesState();

  @override
  List<Object> get props => [];
}

class DispensarySalesInitial extends DispensarySalesState {}

class DispensarySalesLoading extends DispensarySalesState {}

class DispensarySalesLoaded extends DispensarySalesState {
  final List<OrderModel> orders;

  const DispensarySalesLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class DispensarySalesError extends DispensarySalesState {
  final String message;

  const DispensarySalesError(this.message);

  @override
  List<Object> get props => [message];
}
