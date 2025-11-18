import 'package:bloc/bloc.dart';
import 'package:deluxe/core/firebase/auth_service.dart';
import 'package:deluxe/features/consumer/domain/repositories/consumer_order_repository.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

part 'order_creation_event.dart';
part 'order_creation_state.dart';

class OrderCreationBloc extends Bloc<OrderCreationEvent, OrderCreationState> {
  final ConsumerOrderRepository _consumerOrderRepository;
  final AuthService _authService;
  final Uuid _uuid = const Uuid();

  OrderCreationBloc({
    required ConsumerOrderRepository consumerOrderRepository,
    required AuthService authService,
  })  : _consumerOrderRepository = consumerOrderRepository,
        _authService = authService,
        super(OrderCreationInitial()) {
    on<CreateOrder>(_onCreateOrder);
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderCreationState> emit,
  ) async {
    emit(OrderCreationInProgress());
    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final newOrder = OrderModel(
        id: _uuid.v4(),
        consumerId: user.uid,
        sellerId: event.product.farmerId, // Assuming product has farmerId
        items: [event.product], // Single item order for now
        totalPrice: event.product.price * event.quantity,
        status: 'Pending',
        createdAt: DateTime.now(),
        dispensaryName: user.displayName ?? user.email ?? 'Unknown Dispensary',
      );

      await _consumerOrderRepository.createOrder(newOrder);
      emit(OrderCreationSuccess());
    } catch (e) {
      emit(OrderCreationFailure(message: e.toString()));
    }
  }
}
