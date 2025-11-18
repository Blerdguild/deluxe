import 'package:deluxe/features/farmer/presentation/bloc/farmer_order_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:deluxe/shared/services/service_locator.dart';

class FarmerOrdersScreen extends StatelessWidget {
  const FarmerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FarmerOrderBloc>()..add(LoadFarmerOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: BlocBuilder<FarmerOrderBloc, FarmerOrderState>(
          builder: (context, state) {
            if (state is FarmerOrderLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is FarmerOrderLoaded) {
              return ListView.builder(
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ListTile(
                      title: Text('Order #${order.id.substring(0, 8)}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Buyer: ${order.dispensaryName}'),
                          Text(
                              'Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                          Text('Items: ${order.items.length}'),
                        ],
                      ),
                      trailing: order.status == 'Pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.check,
                                      color: Colors.green),
                                  onPressed: () {
                                    context.read<FarmerOrderBloc>().add(
                                          UpdateOrderStatus(
                                              order.id, 'Accepted'),
                                        );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close,
                                      color: Colors.red),
                                  onPressed: () {
                                    context.read<FarmerOrderBloc>().add(
                                          UpdateOrderStatus(
                                              order.id, 'Declined'),
                                        );
                                  },
                                ),
                              ],
                            )
                          : Text(
                              order.status,
                              style: TextStyle(
                                color: order.status == 'Accepted'
                                    ? Colors.green
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      onTap: () {
                        // TODO: Navigate to detailed order view
                      },
                    ),
                  );
                },
              );
            } else if (state is FarmerOrderError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text('No orders yet.'));
            }
          },
        ),
      ),
    );
  }
}
