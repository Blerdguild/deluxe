import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:equatable/equatable.dart';

part 'consumer_order_event.dart';
part 'consumer_order_state.dart';

class ConsumerOrderBloc extends Bloc<ConsumerOrderEvent, ConsumerOrderState> {
  final ConsumerOrderRepository _repository;
  StreamSubscription? _ordersSubscription;

  ConsumerOrderBloc({required ConsumerOrderRepository repository})
      : _repository = repository,
        super(ConsumerOrderInitial()) {
    on<PlaceConsumerOrder>(_onPlaceConsumerOrder);
    on<LoadConsumerOrders>(_onLoadConsumerOrders);
    on<_ConsumerOrdersUpdated>(_onConsumerOrdersUpdated);
    on<_ConsumerOrdersError>(_onConsumerOrdersError);
  }

  Future<void> _onPlaceConsumerOrder(
    PlaceConsumerOrder event,
    Emitter<ConsumerOrderState> emit,
  ) async {
    emit(ConsumerOrderPlacementInProgress());
    try {
      await _repository.createOrder(event.order);
      emit(ConsumerOrderPlacementSuccess());
    } catch (e) {
      emit(ConsumerOrderPlacementFailure(message: e.toString()));
    }
  }

  void _onLoadConsumerOrders(
    LoadConsumerOrders event,
    Emitter<ConsumerOrderState> emit,
  ) {
    emit(ConsumerOrderLoadInProgress());
    _ordersSubscription?.cancel();
    _ordersSubscription = _repository.getOrders().listen(
          (orders) => add(_ConsumerOrdersUpdated(orders)),
          onError: (error) => add(_ConsumerOrdersError(error.toString())),
        );
  }

  void _onConsumerOrdersUpdated(
    _ConsumerOrdersUpdated event,
    Emitter<ConsumerOrderState> emit,
  ) {
    emit(ConsumerOrderLoadSuccess(orders: event.orders));
  }

  void _onConsumerOrdersError(
    _ConsumerOrdersError event,
    Emitter<ConsumerOrderState> emit,
  ) {
    emit(ConsumerOrderLoadFailure(message: event.message));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}
