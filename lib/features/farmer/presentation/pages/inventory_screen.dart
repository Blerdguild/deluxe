import 'package:deluxe/features/farmer/presentation/bloc/farmer_inventory_bloc.dart';
import 'package:deluxe/features/farmer/presentation/pages/edit_product_screen.dart';
import 'package:deluxe/shared/models/product_model.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FarmerInventoryBloc>()..add(LoadInventory()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Inventory'),
        ),
        body: BlocBuilder<FarmerInventoryBloc, FarmerInventoryState>(
          builder: (context, state) {
            if (state is FarmerInventoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FarmerInventoryError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is FarmerInventoryLoaded) {
              if (state.products.isEmpty) {
                return const Center(
                    child: Text('No products found. Add a harvest first!'));
              }
              return ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(product.name),
                      subtitle:
                          Text('Price: \$${product.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.token),
                            tooltip: 'Tokenize',
                            onPressed: () =>
                                _showTokenizeDialog(context, product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditProductScreen(product: product),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        // Optional: Navigate to details
                      },
                    ),
                  );
                },
              );
            }
            return const Center(child: Text('Loading inventory...'));
          },
        ),
      ),
    );
  }

  Future<void> _showTokenizeDialog(
      BuildContext context, Product product) async {
    final supplyController = TextEditingController(text: '100');
    return showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Tokenize ${product.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Create NFTs for this harvest.'),
              const SizedBox(height: 16),
              TextField(
                controller: supplyController,
                decoration: const InputDecoration(
                  labelText: 'Supply (Quantity)',
                  hintText: 'e.g. 100',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final supply = int.tryParse(supplyController.text) ?? 0;
                if (supply > 0) {
                  // Use the Bloc provided by the parent BlocProvider
                  context.read<FarmerInventoryBloc>().add(
                        TokenizeProduct(product: product, supply: supply),
                      );
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Minting started... Check console/wallet.'),
                    ),
                  );
                }
              },
              child: const Text('Mint'),
            ),
          ],
        );
      },
    );
  }
}
