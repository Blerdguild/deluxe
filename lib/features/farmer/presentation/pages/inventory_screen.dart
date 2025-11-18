import 'package:deluxe/features/farmer/presentation/bloc/farmer_inventory_bloc.dart';
import 'package:deluxe/features/farmer/presentation/pages/edit_product_screen.dart';
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
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProductScreen(product: product),
                          ),
                        ).then((_) {
                          // Refresh inventory when coming back (though stream should handle it)
                          // context.read<FarmerInventoryBloc>().add(LoadInventory());
                        });
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
}
