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
                      title: Text(order.strainName),
                      subtitle: Text(
                          '${order.quantity}g - Ordered by ${order.dispensaryName}'),
                      trailing: order.status == 'Pending'
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<FarmerOrderBloc>().add(
                                          UpdateOrderStatus(order.id, 'Accepted'),
                                        );
                                  },
                                  child: const Text('Accept'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<FarmerOrderBloc>().add(
                                          UpdateOrderStatus(order.id, 'Declined'),
                                        );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text('Decline'),
                                ),
                              ],
                            )
                          : Text(order.status),
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
