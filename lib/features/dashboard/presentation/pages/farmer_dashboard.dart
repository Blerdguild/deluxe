import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:deluxe/features/farmer/presentation/pages/farmer_orders_screen.dart';
import 'package:deluxe/features/farmer/presentation/pages/inventory_screen.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({super.key});

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Dashboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Harvests'),
            Tab(text: 'Orders'),
            Tab(text: 'Inventory'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BlocProvider(
            create: (context) => sl<HarvestBloc>()..add(LoadHarvests()),
            child: BlocBuilder<HarvestBloc, HarvestState>(
              builder: (context, state) {
                if (state is HarvestLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is HarvestLoaded) {
                  return HarvestList(harvests: state.harvests);
                } else if (state is HarvestError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          const FarmerOrdersScreen(),
          const InventoryScreen(),
        ],
      ),
    );
  }
}

class HarvestList extends StatelessWidget {
  final List<Harvest> harvests;

  const HarvestList({super.key, required this.harvests});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: harvests.length,
      itemBuilder: (context, index) {
        final harvest = harvests[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(harvest.strainName),
            subtitle: Text('Harvested on: ${harvest.harvestDate}'),
            trailing: Text('${harvest.weight}g'),
          ),
        );
      },
    );
  }
}
