import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/farmer/presentation/bloc/farmer_order_bloc.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:deluxe/features/farmer/presentation/pages/add_harvest_screen.dart';
import 'package:deluxe/shared/models/farmer_profile.dart';
import 'package:deluxe/shared/models/order_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;

    // Ensure Blocs are loaded
    context.read<HarvestBloc>().add(LoadHarvests());
    context.read<FarmerOrderBloc>().add(LoadFarmerOrders());

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Dynamic Header ---
              StreamBuilder<DocumentSnapshot>(
                stream: user != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots()
                    : null,
                builder: (context, snapshot) {
                  String farmerName = 'Set Your Farm Name';

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final profile = FarmerProfile.fromDocument(snapshot.data!);
                    farmerName = profile.farmName ?? 'Set Your Farm Name';
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ItalVibes',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  'x ',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    farmerName,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- Summary Grid ---
              BlocBuilder<FarmerOrderBloc, FarmerOrderState>(
                builder: (context, orderState) {
                  List<OrderModel> orders = [];
                  if (orderState is FarmerOrderLoaded) {
                    orders = orderState.orders;
                  }

                  // Calculate metrics
                  final pendingOrders = orders
                      .where((o) => o.status.toLowerCase() == 'pending')
                      .length;

                  final earnings = orders
                      .where((o) =>
                          o.status.toLowerCase() == 'accepted' ||
                          o.status.toLowerCase() == 'completed')
                      .fold(0.0, (sum, o) => sum + o.totalPrice);

                  final topBuyer = _calculateTopBuyer(orders);

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      _SummaryCard(
                        title: 'Total Products',
                        valueBuilder: (context) =>
                            BlocBuilder<HarvestBloc, HarvestState>(
                          builder: (context, state) {
                            if (state is HarvestLoaded) {
                              return Text(state.harvests.length.toString(),
                                  style: theme.textTheme.headlineMedium);
                            }
                            return const Text('...',
                                style: TextStyle(fontSize: 24));
                          },
                        ),
                        subtitle: 'Active Batches',
                      ),
                      _SummaryCard(
                        title: 'Orders Pending',
                        valueBuilder: (context) => Text(
                          pendingOrders.toString(),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: pendingOrders > 0 ? Colors.orange : null,
                          ),
                        ),
                        subtitle: 'Action Required',
                      ),
                      _SummaryCard(
                        title: 'Earnings',
                        valueBuilder: (context) => Text(
                          NumberFormat.currency(symbol: '\$').format(earnings),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        subtitle: 'Total Revenue',
                      ),
                      _SummaryCard(
                        title: 'Top Buyer',
                        valueBuilder: (context) => Text(
                          topBuyer,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: 'Most Frequent',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // --- Quick Actions ---
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.add,
                      label: 'Add Product',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<HarvestBloc>(),
                              child: const AddHarvestScreen(),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.list_alt,
                      label: 'View Orders',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Switch to Orders tab to view details')),
                        );
                      },
                      isSecondary: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- Analytics Chart ---
              Text(
                'Sales Overview (7 Days)',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              BlocBuilder<FarmerOrderBloc, FarmerOrderState>(
                builder: (context, state) {
                  if (state is FarmerOrderLoaded && state.orders.isNotEmpty) {
                    return _AnalyticsChart(orders: state.orders);
                  } else if (state is FarmerOrderLoaded &&
                      state.orders.isEmpty) {
                    return Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No sales data yet',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()));
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateTopBuyer(List<OrderModel> orders) {
    if (orders.isEmpty) return 'N/A';

    final buyerCounts = <String, int>{};
    for (var order in orders) {
      final key = order.dispensaryName;
      buyerCounts[key] = (buyerCounts[key] ?? 0) + 1;
    }

    if (buyerCounts.isEmpty) return 'N/A';

    final topBuyer =
        buyerCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    return topBuyer;
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final WidgetBuilder valueBuilder;
  final String subtitle;

  const _SummaryCard({
    required this.title,
    required this.valueBuilder,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          valueBuilder(context),
          const SizedBox(height: 8),
          Text(title,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(subtitle, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSecondary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: isSecondary ? theme.cardTheme.color : theme.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 32,
                color: isSecondary
                    ? theme.iconTheme.color
                    : theme.colorScheme.onPrimary),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSecondary
                    ? theme.textTheme.bodyLarge?.color
                    : theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsChart extends StatelessWidget {
  final List<OrderModel> orders;

  const _AnalyticsChart({required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Process data: Group sales by day for the last 7 days
    final now = DateTime.now();
    final Map<int, double> salesByDay = {};

    // Initialize last 7 days with 0
    for (int i = 6; i >= 0; i--) {
      salesByDay[i] = 0.0;
    }

    for (var order in orders) {
      if (order.status.toLowerCase() == 'accepted' ||
          order.status.toLowerCase() == 'completed') {
        final difference = now.difference(order.createdAt).inDays;
        if (difference >= 0 && difference < 7) {
          final xIndex = 6 - difference;
          salesByDay[xIndex] = (salesByDay[xIndex] ?? 0) + order.totalPrice;
        }
      }
    }

    final spots = salesByDay.entries
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 100,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final date = now.subtract(Duration(days: 6 - value.toInt()));
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('E').format(date), // Mon, Tue, etc.
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 500,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const Text('');
                  return Text(
                    NumberFormat.compact().format(value),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 6,
          minY: 0,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor,
                  theme.primaryColor.withOpacity(0.5)
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    theme.primaryColor.withOpacity(0.2),
                    theme.primaryColor.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    NumberFormat.currency(symbol: '\$').format(barSpot.y),
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}
