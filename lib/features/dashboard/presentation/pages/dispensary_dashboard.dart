import 'package:deluxe/features/dispensary/presentation/bloc/dispensary_sales_bloc.dart';
import 'package:deluxe/features/dispensary/presentation/bloc/wholesale_order_bloc.dart';
import 'package:deluxe/features/dashboard/bloc/product_bloc.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class DispensaryDashboardView extends StatelessWidget {
  const DispensaryDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<DispensarySalesBloc>()..add(LoadDispensarySales()),
        ),
        BlocProvider(
          create: (context) =>
              sl<WholesaleOrderBloc>()..add(LoadWholesaleOrders()),
        ),
        BlocProvider(
          create: (context) => sl<ProductBloc>()..add(LoadRetailProducts()),
        ),
      ],
      child: const _DashboardContent(),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Dashboard',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Summary Cards
              BlocBuilder<DispensarySalesBloc, DispensarySalesState>(
                builder: (context, salesState) {
                  return BlocBuilder<WholesaleOrderBloc, WholesaleOrderState>(
                    builder: (context, purchasesState) {
                      return BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, inventoryState) {
                          final salesOrders =
                              salesState is DispensarySalesLoaded
                                  ? salesState.orders
                                  : <OrderModel>[];
                          final purchaseOrders =
                              purchasesState is WholesaleOrderLoadSuccess
                                  ? purchasesState.orders
                                  : <OrderModel>[];
                          final products = inventoryState is ProductLoaded
                              ? inventoryState.products
                              : [];

                          // Calculate metrics
                          final totalSales = salesOrders
                              .where((o) =>
                                  o.status.toLowerCase() == 'completed' ||
                                  o.status.toLowerCase() == 'ready for pickup')
                              .fold(0.0, (sum, o) => sum + o.totalPrice);

                          final pendingSales = salesOrders
                              .where((o) => o.status.toLowerCase() == 'pending')
                              .length;

                          final lowStockCount =
                              products.where((p) => p.quantity <= 10).length;

                          final pendingPurchases = purchaseOrders
                              .where((o) => o.status.toLowerCase() == 'pending')
                              .length;

                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.4,
                            children: [
                              _SummaryCard(
                                title: 'Total Sales',
                                value: 'R${totalSales.toStringAsFixed(2)}',
                                icon: Icons.attach_money,
                                color: Colors.green,
                              ),
                              _SummaryCard(
                                title: 'Pending Orders',
                                value: pendingSales.toString(),
                                icon: Icons.pending_actions,
                                color: Colors.orange,
                              ),
                              _SummaryCard(
                                title: 'Low Stock Items',
                                value: lowStockCount.toString(),
                                icon: Icons.warning,
                                color: lowStockCount > 0
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              _SummaryCard(
                                title: 'Pending Purchases',
                                value: pendingPurchases.toString(),
                                icon: Icons.shopping_cart,
                                color: Colors.blue,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 32),

              // Recent Sales
              Text(
                'Recent Sales',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<DispensarySalesBloc, DispensarySalesState>(
                builder: (context, state) {
                  if (state is DispensarySalesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is DispensarySalesLoaded) {
                    final recentOrders = state.orders.take(5).toList();

                    if (recentOrders.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            'No sales yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: recentOrders
                          .map((order) => _OrderTile(order: order))
                          .toList(),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(height: 32),

              // Inventory Alerts
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoaded) {
                    final lowStockProducts =
                        state.products.where((p) => p.quantity <= 10).toList();

                    if (lowStockProducts.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              'Inventory Alerts',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${lowStockProducts.length} items are running low on stock',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...lowStockProducts.take(3).map(
                                    (product) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              product.name,
                                              style: theme.textTheme.bodyMedium,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: product.quantity <= 0
                                                  ? Colors.red
                                                  : Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Qty: ${product.quantity}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;

  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8)}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.dispensaryName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy').format(order.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'R${order.totalPrice.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.blue;
      case 'declined':
        return Colors.red;
      case 'ready for pickup':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
