
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:deluxe/features/farmer/presentation/pages/add_harvest_screen.dart';
import 'package:deluxe/shared/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HarvestsScreen extends StatelessWidget {
  const HarvestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<HarvestBloc>()..add(LoadHarvests()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Harvests'),
        ),
        body: BlocBuilder<HarvestBloc, HarvestState>(
          builder: (context, state) {
            if (state is HarvestLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HarvestLoaded) {
              return HarvestList(harvests: state.harvests);
            } else if (state is HarvestError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Please load harvests.'));
          },
        ),
        floatingActionButton: Builder(builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: BlocProvider.of<HarvestBloc>(context),
                    child: const AddHarvestScreen(),
                  ),
                ),
              );
            },
            child: const Icon(Icons.add),
          );
        }),
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
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: ListTile(
            title: Text(harvest.strainName),
            subtitle: Text('Weight: \${harvest.weight}g'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\${harvest.harvestDate.toLocal()}'.split(' ')[0],
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    context.read<HarvestBloc>().add(DeleteHarvest(harvest.id));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
