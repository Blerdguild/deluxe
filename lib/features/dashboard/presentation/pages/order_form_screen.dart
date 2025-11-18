
import 'package:deluxe/features/dispensary/presentation/bloc/order_creation_bloc.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrderFormScreen extends StatelessWidget {
  final Product product;

  const OrderFormScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderCreationBloc>(),
      child: _OrderFormView(product: product),
    );
  }
}

class _OrderFormView extends StatefulWidget {
  final Product product;

  const _OrderFormView({Key? key, required this.product}) : super(key: key);

  @override
  State<_OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends State<_OrderFormView> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      final quantity = int.tryParse(_quantityController.text);
      if (quantity != null) {
        context.read<OrderCreationBloc>().add(
              CreateOrder(
                product: widget.product,
                quantity: quantity,
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderCreationBloc, OrderCreationState>(
      listener: (context, state) {
        if (state is OrderCreationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Order placed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
        if (state is OrderCreationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to place order: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Place Order for ${widget.product.name}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'By Farmer: ${widget.product.farmerName}', // Assuming product has a farmerName
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Price: \$${widget.product.price.toStringAsFixed(2)} per unit',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a quantity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid quantity';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<OrderCreationBloc, OrderCreationState>(
                  builder: (context, state) {
                    if (state is OrderCreationInProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: _submitOrder,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Submit Order'),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
