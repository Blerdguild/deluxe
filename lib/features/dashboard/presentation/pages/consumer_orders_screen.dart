import 'package:deluxe/features/consumer/presentation/bloc/consumer_order_bloc.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ConsumerOrdersScreen extends StatelessWidget {
  const ConsumerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ConsumerOrderBloc>()..add(LoadConsumerOrders()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
        ),
        body: BlocBuilder<ConsumerOrderBloc, ConsumerOrderState>(
          builder: (context, state) {
            if (state is ConsumerOrderLoadInProgress) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ConsumerOrderLoadSuccess) {
              if (state.orders.isEmpty) {
                return const Center(child: Text('No orders placed yet.'));
              }
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
                          Text(
                              'Date: ${DateFormat.yMMMd().format(order.createdAt)}'),
                          Text(
                              'Total: \$${order.totalPrice.toStringAsFixed(2)}'),
                          Text('Status: ${order.status}'),
                          if (order.items.isNotEmpty)
                            Text('Items: ${order.items.length}'),
                        ],
                      ),
                      trailing: Icon(
                        Icons.circle,
                        color: _getStatusColor(order.status),
                        size: 12,
                      ),
                      onTap: () {
                        // TODO: Navigate to order details
                      },
                    ),
                  );
                },
              );
            } else if (state is ConsumerOrderLoadFailure) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'declined':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
