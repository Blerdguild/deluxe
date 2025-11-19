import 'package:deluxe/features/farmer/presentation/bloc/farmer_order_bloc.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:deluxe/features/farmer/presentation/pages/add_harvest_screen.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Ensure Blocs are loaded
    context.read<HarvestBloc>().add(LoadHarvests());
    // context.read<FarmerOrderBloc>().add(LoadFarmerOrders()); // Assuming this event exists

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ItalVibes',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'x DeluxeBudStudios',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Profile icon handled by shell
                ],
              ),
              const SizedBox(height: 32),

              // --- Summary Grid ---
              GridView.count(
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
                    valueBuilder: (context) => const Text('2', // Mock for now
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    subtitle: 'Action Required',
                  ),
                  _SummaryCard(
                    title: 'Earnings',
                    valueBuilder: (context) => const Text('\$1,200', // Mock
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    subtitle: 'This Month',
                  ),
                  _SummaryCard(
                    title: 'Top Buyer',
                    valueBuilder: (context) => const Text('Green', // Mock
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    subtitle: 'Dispensary',
                  ),
                ],
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
                        // Navigate to Orders tab via Shell (handled by user tapping tab)
                        // Or push screen directly if preferred.
                        // For now, just show a snackbar or do nothing as it's in the tab bar.
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

              // --- Analytics Preview ---
              Text(
                'Analytics',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bar_chart,
                          size: 48, color: theme.primaryColor),
                      const SizedBox(height: 8),
                      Text('Sales Overview', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
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
