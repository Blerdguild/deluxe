part of 'dispensary_sales_bloc.dart';

abstract class DispensarySalesEvent extends Equatable {
  const DispensarySalesEvent();

  @override
  List<Object> get props => [];
}

class LoadDispensarySales extends DispensarySalesEvent {}

class UpdateSaleStatus extends DispensarySalesEvent {
  final String orderId;
  final String newStatus;

  const UpdateSaleStatus({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [orderId, newStatus];
}
