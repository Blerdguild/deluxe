import 'package:bloc/bloc.dart';
import 'package:deluxe/features/farmer/domain/entities/farmer_order.dart';
import 'package:deluxe/features/farmer/domain/repositories/farmer_order_repository.dart';
import 'package:equatable/equatable.dart';

part 'farmer_order_event.dart';
part 'farmer_order_state.dart';

class FarmerOrderBloc extends Bloc<FarmerOrderEvent, FarmerOrderState> {
  final FarmerOrderRepository _farmerOrderRepository;

  FarmerOrderBloc({required FarmerOrderRepository farmerOrderRepository})
      : _farmerOrderRepository = farmerOrderRepository,
        super(FarmerOrderInitial()) {
    on<LoadFarmerOrders>(_onLoadFarmerOrders);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
  }

  void _onLoadFarmerOrders(
    LoadFarmerOrders event,
    Emitter<FarmerOrderState> emit,
  ) async {
    emit(FarmerOrderLoading());
    try {
      final orders = await _farmerOrderRepository.getOrders();
      emit(FarmerOrderLoaded(orders));
    } catch (e) {
      emit(FarmerOrderError(e.toString()));
    }
  }

  void _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<FarmerOrderState> emit,
  ) async {
    try {
      await _farmerOrderRepository.updateOrderStatus(event.orderId, event.newStatus);
      // After updating, reload the orders to reflect the change.
      add(LoadFarmerOrders());
    } catch (e) {
      // If the update fails, we can emit an error or handle it as needed.
      // For now, we'll just reload to ensure UI consistency.
      emit(FarmerOrderError(e.toString()));
    }
  }
}
