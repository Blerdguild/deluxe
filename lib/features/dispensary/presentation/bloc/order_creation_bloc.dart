
import 'package:bloc/bloc.dart';
import 'package:deluxe/features/farmer/domain/entities/farmer_order.dart';
import 'package:deluxe/features/farmer/domain/repositories/farmer_order_repository.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'order_creation_event.dart';
part 'order_creation_state.dart';

class OrderCreationBloc extends Bloc<OrderCreationEvent, OrderCreationState> {
  final FarmerOrderRepository _farmerOrderRepository;
  final Uuid _uuid = const Uuid();

  OrderCreationBloc({required FarmerOrderRepository farmerOrderRepository})
      : _farmerOrderRepository = farmerOrderRepository,
        super(OrderCreationInitial()) {
    on<CreateOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderCreationState> emit,
  ) async {
    emit(OrderCreationInProgress());
    try {
      final newOrder = FarmerOrder(
        id: _uuid.v4(), // Generate a unique ID
        strainName: event.product.name,
        quantity: event.quantity.toDouble(),
        dispensaryName: 'The Dispensary', // Hardcoded for now
        status: 'Pending',
        orderDate: DateTime.now(),
      );

      await _farmerOrderRepository.addOrder(newOrder);
      emit(OrderCreationSuccess());
    } catch (e) {
      emit(OrderCreationFailure(message: e.toString()));
    }
  }
}
