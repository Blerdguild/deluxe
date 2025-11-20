import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:equatable/equatable.dart';

part 'wholesale_order_event.dart';
part 'wholesale_order_state.dart';

class WholesaleOrderBloc
    extends Bloc<WholesaleOrderEvent, WholesaleOrderState> {
  final ConsumerOrderRepository _repository;
  StreamSubscription? _ordersSubscription;

  WholesaleOrderBloc({required ConsumerOrderRepository repository})
      : _repository = repository,
        super(WholesaleOrderInitial()) {
    on<LoadWholesaleOrders>(_onLoadWholesaleOrders);
    on<_WholesaleOrdersUpdated>(_onWholesaleOrdersUpdated);
    on<_WholesaleOrdersError>(_onWholesaleOrdersError);
    on<PlaceWholesaleOrder>(_onPlaceWholesaleOrder);
  }

  void _onLoadWholesaleOrders(
    LoadWholesaleOrders event,
    Emitter<WholesaleOrderState> emit,
  ) {
    emit(WholesaleOrderLoadInProgress());
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.getOrders().listen(
          (orders) => add(_WholesaleOrdersUpdated(orders)),
          onError: (error) => add(_WholesaleOrdersError(error.toString())),
        );
  }

  void _onWholesaleOrdersUpdated(
    _WholesaleOrdersUpdated event,
    Emitter<WholesaleOrderState> emit,
  ) {
    emit(WholesaleOrderLoadSuccess(orders: event.orders));
  }

  void _onWholesaleOrdersError(
    _WholesaleOrdersError event,
    Emitter<WholesaleOrderState> emit,
  ) {
    emit(WholesaleOrderLoadFailure(message: event.message));
  }

  Future<void> _onPlaceWholesaleOrder(
    PlaceWholesaleOrder event,
    Emitter<WholesaleOrderState> emit,
  ) async {
    // Note: We don't emit a loading state here to avoid replacing the list view
    // Instead, the UI should handle the loading state for the button
    try {
      await _repository.createOrder(event.order);
      // No need to emit success, the stream will update the list
    } catch (e) {
      // UI should handle error display
    }
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
