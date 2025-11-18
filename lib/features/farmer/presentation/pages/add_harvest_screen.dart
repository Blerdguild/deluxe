
import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddHarvestScreen extends StatefulWidget {
  const AddHarvestScreen({super.key});

  @override
  State<AddHarvestScreen> createState() => _AddHarvestScreenState();
}

class _AddHarvestScreenState extends State<AddHarvestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _strainNameController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void dispose() {
    _strainNameController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _saveHarvest() {
    if (_formKey.currentState!.validate()) {
      final newHarvest = Harvest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        strainName: _strainNameController.text,
        weight: double.parse(_weightController.text),
        harvestDate: DateTime.now(),
      );

      context.read<HarvestBloc>().add(AddHarvest(newHarvest));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Harvest'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _strainNameController,
                decoration: const InputDecoration(
                  labelText: 'Strain Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a strain name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (grams)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveHarvest,
                  child: const Text('Save Harvest'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
