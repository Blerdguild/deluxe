import 'package:bloc/bloc.dart';
import 'package:deluxe/features/consumer/domain/entities/consumer_order.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';
import 'package:equatable/equatable.dart';

part 'consumer_order_event.dart';
part 'consumer_order_state.dart';

class ConsumerOrderBloc extends Bloc<ConsumerOrderEvent, ConsumerOrderState> {
  final ConsumerOrderRepository _repository;

  ConsumerOrderBloc({required ConsumerOrderRepository repository})
      : _repository = repository,
        super(ConsumerOrderInitial()) {
    on<PlaceConsumerOrder>(_onPlaceConsumerOrder);
    on<LoadConsumerOrders>(_onLoadConsumerOrders);
  }

  Future<void> _onPlaceConsumerOrder(
    PlaceConsumerOrder event,
    Emitter<ConsumerOrderState> emit,
  ) async {
    emit(ConsumerOrderPlacementInProgress());
    try {
      await _repository.addOrder(event.order);
      emit(ConsumerOrderPlacementSuccess());
    } catch (e) {
      emit(ConsumerOrderPlacementFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadConsumerOrders(
    LoadConsumerOrders event,
    Emitter<ConsumerOrderState> emit,
  ) async {
    emit(ConsumerOrderLoadInProgress());
    try {
      final orders = await _repository.getOrders();
      emit(ConsumerOrderLoadSuccess(orders: orders));
    } catch (e) {
      emit(ConsumerOrderLoadFailure(message: e.toString()));
    }
  }
}
