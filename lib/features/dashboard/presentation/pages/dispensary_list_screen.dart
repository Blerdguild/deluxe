import 'package:deluxe/features/dashboard/bloc/dispensary_bloc.dart';
import 'package:deluxe/features/dashboard/presentation/widgets/dispensary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DispensaryListScreen extends StatelessWidget {
  const DispensaryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DispensaryBloc, DispensaryState>(
      builder: (context, state) {
        if (state is DispensaryLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DispensaryLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.dispensaries.length,
            itemBuilder: (context, index) {
              return DispensaryCard(dispensary: state.dispensaries[index]);
            },
          );
        }
        if (state is DispensaryError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text('Something went wrong!'));
      },
    );
  }
}
