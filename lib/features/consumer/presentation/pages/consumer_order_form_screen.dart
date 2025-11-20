import 'package:deluxe/features/consumer/presentation/bloc/consumer_order_bloc.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ConsumerOrderFormScreen extends StatelessWidget {
  final Product product;

  const ConsumerOrderFormScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ConsumerOrderBloc>(),
      child: _ConsumerOrderFormView(product: product),
    );
  }
}

class _ConsumerOrderFormView extends StatefulWidget {
  final Product product;

  const _ConsumerOrderFormView({required this.product});

  @override
  State<_ConsumerOrderFormView> createState() => _ConsumerOrderFormViewState();
}

class _ConsumerOrderFormViewState extends State<_ConsumerOrderFormView> {
  final _quantityController = TextEditingController(text: '1');

  void _submitOrder() {
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final uuid = const Uuid();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to place an order')),
      );
      return;
    }

    // Create a real consumer order
    final newOrder = OrderModel(
      id: uuid.v4(),
      consumerId: user.uid,
      sellerId: widget.product.dispensaryId, // Seller is the Dispensary
      items: [
        widget.product.copyWith(quantity: quantity)
      ], // Update product quantity in the order item
      totalPrice: widget.product.price * quantity,
      status: 'Pending',
      createdAt: DateTime.now(),
      dispensaryName: user.displayName ?? 'Consumer', // Buyer's name
    );

    context.read<ConsumerOrderBloc>().add(PlaceConsumerOrder(order: newOrder));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ${widget.product.name}'),
      ),
      body: BlocListener<ConsumerOrderBloc, ConsumerOrderState>(
        listener: (context, state) {
          if (state is ConsumerOrderPlacementSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order Placed Successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is ConsumerOrderPlacementFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.name,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(widget.product.description),
              const SizedBox(height: 16),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              BlocBuilder<ConsumerOrderBloc, ConsumerOrderState>(
                builder: (context, state) {
                  if (state is ConsumerOrderPlacementInProgress) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitOrder,
                      child: const Text('Place Order'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
