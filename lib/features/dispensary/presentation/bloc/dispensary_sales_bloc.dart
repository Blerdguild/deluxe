import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/features/dispensary/domain/repositories/dispensary_sales_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:equatable/equatable.dart';

part 'dispensary_sales_event.dart';
part 'dispensary_sales_state.dart';

class DispensarySalesBloc
    extends Bloc<DispensarySalesEvent, DispensarySalesState> {
  final DispensarySalesRepository _repository;
  StreamSubscription? _ordersSubscription;

  DispensarySalesBloc({required DispensarySalesRepository repository})
      : _repository = repository,
        super(DispensarySalesInitial()) {
    on<LoadDispensarySales>(_onLoadDispensarySales);
    on<UpdateSaleStatus>(_onUpdateSaleStatus);
    on<_DispensarySalesUpdated>(_onDispensarySalesUpdated);
    on<_DispensarySalesError>(_onDispensarySalesError);
  }

  void _onLoadDispensarySales(
    LoadDispensarySales event,
    Emitter<DispensarySalesState> emit,
  ) {
    emit(DispensarySalesLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.getIncomingOrders().listen(
          (orders) => add(_DispensarySalesUpdated(orders)),
          onError: (error) => add(_DispensarySalesError(error.toString())),
        );
  }

  Future<void> _onUpdateSaleStatus(
    UpdateSaleStatus event,
    Emitter<DispensarySalesState> emit,
  ) async {
    try {
      await _repository.updateOrderStatus(event.orderId, event.newStatus);
    } catch (e) {
      emit(DispensarySalesError('Failed to update order: ${e.toString()}'));
    }
  }

  void _onDispensarySalesUpdated(
    _DispensarySalesUpdated event,
    Emitter<DispensarySalesState> emit,
  ) {
    emit(DispensarySalesLoaded(orders: event.orders));
  }

  void _onDispensarySalesError(
    _DispensarySalesError event,
    Emitter<DispensarySalesState> emit,
  ) {
    emit(DispensarySalesError(event.message));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}

// Private events for stream handling
class _DispensarySalesUpdated extends DispensarySalesEvent {
  final List<OrderModel> orders;
  const _DispensarySalesUpdated(this.orders);
}

class _DispensarySalesError extends DispensarySalesEvent {
  final String message;
  const _DispensarySalesError(this.message);
}
