import 'package:deluxe/features/farmer/presentation/bloc/farmer_inventory_bloc.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController _priceController;
  late TextEditingController _descriptionController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _priceController =
        TextEditingController(text: widget.product.price.toString());
    _descriptionController =
        TextEditingController(text: widget.product.description);
  }

  @override
  void dispose() {
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<
          FarmerInventoryBloc>(), // We use a fresh bloc here just for the update action
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit ${widget.product.name}'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _priceController,
                  decoration:
                      const InputDecoration(labelText: 'Price per Unit'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                BlocConsumer<FarmerInventoryBloc, FarmerInventoryState>(
                  listener: (context, state) {
                    if (state is FarmerInventoryError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                    // We can't easily detect "success" here without a specific Success state or callback,
                    // but since we don't emit a new state on success in the Bloc (it relies on stream),
                    // we might want to just pop after a short delay or assume success if no error.
                    // For now, let's just have a "Save" button that pops on await completion.
                  },
                  builder: (context, state) {
                    if (state is FarmerInventoryLoading) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final updatedProduct = Product(
                            id: widget.product.id,
                            name: widget.product.name,
                            type: widget.product.type,
                            price: double.parse(_priceController.text),
                            rating: widget.product.rating,
                            reviewCount: widget.product.reviewCount,
                            imageUrl: widget.product.imageUrl,
                            description: _descriptionController.text,
                            dispensaryId: widget.product.dispensaryId,
                            farmerId: widget.product.farmerId,
                            farmerName: widget.product.farmerName,
                            weight: widget.product.weight,
                          );

                          context
                              .read<FarmerInventoryBloc>()
                              .add(UpdateProduct(updatedProduct));
                          Navigator.pop(context); // Optimistic pop
                        }
                      },
                      child: const Text('Save Changes'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
