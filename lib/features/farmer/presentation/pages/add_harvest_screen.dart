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
  final _priceController = TextEditingController();
  final _thcController = TextEditingController();
  final _cbdController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedType = 'Indica';
  final List<String> _types = ['Indica', 'Sativa', 'Hybrid', 'CBD'];

  @override
  void dispose() {
    _strainNameController.dispose();
    _weightController.dispose();
    _priceController.dispose();
    _thcController.dispose();
    _cbdController.dispose();
    _descriptionController.dispose();
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

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Harvest added successfully!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Add New Harvest'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.primaryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.eco,
                          color: theme.primaryColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'New Harvest Batch',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Fill in the details below',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Basic Information Section
                _SectionHeader(
                    title: 'Basic Information', icon: Icons.info_outline),
                const SizedBox(height: 12),

                _CustomTextField(
                  controller: _strainNameController,
                  label: 'Strain Name',
                  hint: 'e.g., Purple Haze',
                  icon: Icons.grass,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a strain name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Type Dropdown
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      prefixIcon: Icon(Icons.category),
                      border: InputBorder.none,
                    ),
                    dropdownColor: theme.cardTheme.color,
                    items: _types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedType = newValue!;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 24),

                // Quantity & Pricing Section
                _SectionHeader(title: 'Quantity & Pricing', icon: Icons.scale),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _CustomTextField(
                        controller: _weightController,
                        label: 'Weight (grams)',
                        hint: '1000',
                        icon: Icons.scale,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CustomTextField(
                        controller: _priceController,
                        label: 'Price per gram',
                        hint: '10.00',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Cannabinoid Profile Section
                _SectionHeader(
                    title: 'Cannabinoid Profile (Optional)',
                    icon: Icons.science),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _CustomTextField(
                        controller: _thcController,
                        label: 'THC %',
                        hint: '20.5',
                        icon: Icons.local_fire_department,
                        keyboardType: TextInputType.number,
                        isRequired: false,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CustomTextField(
                        controller: _cbdController,
                        label: 'CBD %',
                        hint: '1.2',
                        icon: Icons.healing,
                        keyboardType: TextInputType.number,
                        isRequired: false,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Description Section
                _SectionHeader(
                    title: 'Description (Optional)', icon: Icons.description),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Add notes about this harvest batch...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _saveHarvest,
                    icon: const Icon(Icons.check_circle, size: 24),
                    label: const Text(
                      'Save Harvest',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isRequired;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
