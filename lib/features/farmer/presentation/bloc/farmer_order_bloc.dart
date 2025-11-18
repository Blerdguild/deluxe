import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:deluxe/features/farmer/domain/repositories/farmer_order_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:equatable/equatable.dart';

part 'farmer_order_event.dart';
part 'farmer_order_state.dart';

class FarmerOrderBloc extends Bloc<FarmerOrderEvent, FarmerOrderState> {
  final FarmerOrderRepository _farmerOrderRepository;
  StreamSubscription? _ordersSubscription;

  FarmerOrderBloc({required FarmerOrderRepository farmerOrderRepository})
      : _farmerOrderRepository = farmerOrderRepository,
        super(FarmerOrderInitial()) {
    on<LoadFarmerOrders>(_onLoadFarmerOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<_OrdersUpdated>(_onOrdersUpdated);
    on<_OrdersError>(_onOrdersError);
  }

  void _onLoadFarmerOrders(
    LoadFarmerOrders event,
    Emitter<FarmerOrderState> emit,
  ) {
    emit(FarmerOrderLoading());
    _ordersSubscription?.cancel();
    _ordersSubscription = _farmerOrderRepository.getOrders().listen(
          (orders) => add(_OrdersUpdated(orders)),
          onError: (error) => add(_OrdersError(error.toString())),
        );
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<FarmerOrderState> emit,
  ) async {
    try {
      await _farmerOrderRepository.updateOrderStatus(
          event.orderId, event.newStatus);
      // No need to reload manually, stream will update
    } catch (e) {
      emit(FarmerOrderError(e.toString()));
    }
  }

  void _onOrdersUpdated(
    _OrdersUpdated event,
    Emitter<FarmerOrderState> emit,
  ) {
    emit(FarmerOrderLoaded(event.orders));
  }

  void _onOrdersError(
    _OrdersError event,
    Emitter<FarmerOrderState> emit,
  ) {
    emit(FarmerOrderError(event.message));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }
}

class _OrdersUpdated extends FarmerOrderEvent {
  final List<OrderModel> orders;
  const _OrdersUpdated(this.orders);
  @override
  List<Object> get props => [orders];
}

class _OrdersError extends FarmerOrderEvent {
  final String message;
  const _OrdersError(this.message);
  @override
  List<Object> get props => [message];
}
