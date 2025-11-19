import 'package:deluxe/features/farmer/domain/entities/harvest.dart';
import 'package:deluxe/features/farmer/presentation/bloc/harvest_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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

  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();
  bool _isUploadingImage = false;
  String? _currentImageURL;

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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) return;

      setState(() => _isUploadingImage = true);

      // Compress image
      final dir = await getTemporaryDirectory();
      final targetPath =
          p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

      final XFile? compressedImage =
          await FlutterImageCompress.compressAndGetFile(
        image.path,
        targetPath,
        quality: 70,
        minWidth: 800,
        minHeight: 800,
      );

      if (compressedImage == null) throw Exception('Image compression failed');

      final File file = File(compressedImage.path);
      final String fileName =
          'harvest_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _storage.ref().child('harvest_images').child(fileName);

      // Upload task
      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();

      setState(() {
        _currentImageURL = downloadUrl;
        _isUploadingImage = false;
      });
    } catch (e) {
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveHarvest() {
    if (_formKey.currentState!.validate()) {
      final newHarvest = Harvest(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        strainName: _strainNameController.text,
        weight: double.parse(_weightController.text),
        harvestDate: DateTime.now(),
        imageUrl: _currentImageURL,
      );

      context.read<HarvestBloc>().add(AddHarvest(newHarvest));

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary),
              const SizedBox(width: 8),
              const Text('Harvest added successfully!'),
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
                // Image Upload Section
                Center(
                  child: GestureDetector(
                    onTap: _isUploadingImage ? null : _pickImage,
                    child: Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        color: theme.cardTheme.color,
                        borderRadius: BorderRadius.circular(16),
                        image: _currentImageURL != null
                            ? DecorationImage(
                                image: NetworkImage(_currentImageURL!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        border: Border.all(
                          color: theme.primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: _isUploadingImage
                          ? const Center(child: CircularProgressIndicator())
                          : (_currentImageURL == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo,
                                        size: 40,
                                        color: theme.primaryColor
                                            .withOpacity(0.5)),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add Harvest Photo',
                                      style: TextStyle(
                                        color:
                                            theme.primaryColor.withOpacity(0.5),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : null),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

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
