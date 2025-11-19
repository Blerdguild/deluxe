import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/shared/models/dispensary_profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EditDispensaryProfileScreen extends StatefulWidget {
  final DispensaryProfile profile;

  const EditDispensaryProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditDispensaryProfileScreen> createState() =>
      _EditDispensaryProfileScreenState();
}

class _EditDispensaryProfileScreenState
    extends State<EditDispensaryProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  late final TextEditingController _dispensaryNameController;
  late final TextEditingController _ownerNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _businessLicenseController;
  late final TextEditingController _taxIdController;
  late final TextEditingController _walletController;

  List<String> _selectedCertifications = [];
  bool _deliveryAvailable = false;
  bool _pickupAvailable = true;
  bool _notificationsEnabled = true;
  bool _autoAcceptOrders = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _currentLogoURL;

  final List<String> _availableCertifications = [
    'Licensed',
    'Organic',
    'Lab Tested',
    'Sustainable',
    'Fair Trade',
    'Local',
  ];

  final List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  Map<String, String> _operatingHours = {};

  @override
  void initState() {
    super.initState();
    _dispensaryNameController =
        TextEditingController(text: widget.profile.dispensaryName);
    _ownerNameController =
        TextEditingController(text: widget.profile.ownerName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _addressController = TextEditingController(text: widget.profile.address);
    _businessLicenseController =
        TextEditingController(text: widget.profile.businessLicense);
    _taxIdController = TextEditingController(text: widget.profile.taxId);
    _walletController =
        TextEditingController(text: widget.profile.walletAddress);

    _selectedCertifications = widget.profile.certifications;
    _deliveryAvailable = widget.profile.deliveryAvailable;
    _pickupAvailable = widget.profile.pickupAvailable;
    _notificationsEnabled = widget.profile.notificationsEnabled;
    _autoAcceptOrders = widget.profile.autoAcceptOrders;
    _currentLogoURL = widget.profile.logoURL;
    _operatingHours = Map.from(widget.profile.operatingHours);
  }

  @override
  void dispose() {
    _dispensaryNameController.dispose();
    _ownerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _businessLicenseController.dispose();
    _taxIdController.dispose();
    _walletController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedProfile = widget.profile.copyWith(
        dispensaryName: _dispensaryNameController.text.trim(),
        ownerName: _ownerNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        businessLicense: _businessLicenseController.text.trim(),
        taxId: _taxIdController.text.trim(),
        walletAddress: _walletController.text.trim(),
        certifications: _selectedCertifications,
        deliveryAvailable: _deliveryAvailable,
        pickupAvailable: _pickupAvailable,
        notificationsEnabled: _notificationsEnabled,
        autoAcceptOrders: _autoAcceptOrders,
        logoURL: _currentLogoURL,
        operatingHours: _operatingHours,
      );

      await _firestore
          .collection('users')
          .doc(widget.profile.uid)
          .update(updatedProfile.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle,
                    color: Theme.of(context).colorScheme.onPrimary),
                const SizedBox(width: 8),
                const Text('Profile updated successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context, updatedProfile);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
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
          'dispensary_logo_${widget.profile.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _storage.ref().child('dispensary_logos').child(fileName);

      // Upload task
      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();

      setState(() {
        _currentLogoURL = downloadUrl;
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

  void _setOperatingHours(String day) {
    showDialog(
      context: context,
      builder: (context) {
        final controller =
            TextEditingController(text: _operatingHours[day] ?? '');
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          title: Text('Set hours for $day'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g., 9AM-9PM or Closed',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (controller.text.trim().isEmpty) {
                    _operatingHours.remove(day);
                  } else {
                    _operatingHours[day] = controller.text.trim();
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Dispensary Profile'),
        elevation: 0,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
              tooltip: 'Save',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo Upload
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.cardTheme.color,
                      backgroundImage: _currentLogoURL != null
                          ? CachedNetworkImageProvider(_currentLogoURL!)
                          : null,
                      child: _isUploadingImage
                          ? const CircularProgressIndicator()
                          : (_currentLogoURL == null
                              ? const Icon(Icons.store, size: 50)
                              : null),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.scaffoldBackgroundColor,
                            width: 3,
                          ),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt,
                              color: theme.colorScheme.onPrimary, size: 20),
                          onPressed: _isUploadingImage ? null : _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Basic Information
              _SectionHeader(title: 'Basic Information', icon: Icons.store),
              const SizedBox(height: 12),
              _CustomTextField(
                controller: _dispensaryNameController,
                label: 'Dispensary Name',
                icon: Icons.store_outlined,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter dispensary name'
                    : null,
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _ownerNameController,
                label: 'Owner Name',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter owner name'
                    : null,
              ),

              const SizedBox(height: 24),

              // Contact Information
              _SectionHeader(title: 'Contact', icon: Icons.contact_phone),
              const SizedBox(height: 12),
              _CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _addressController,
                label: 'Address',
                icon: Icons.location_on,
                maxLines: 2,
              ),

              const SizedBox(height: 24),

              // Business Information
              _SectionHeader(
                  title: 'Business Information', icon: Icons.business),
              const SizedBox(height: 12),
              _CustomTextField(
                controller: _businessLicenseController,
                label: 'Business License (Optional)',
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _taxIdController,
                label: 'Tax ID (Optional)',
                icon: Icons.receipt_long,
              ),
              const SizedBox(height: 16),

              // Certifications
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified,
                            size: 20, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Certifications',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableCertifications.map((cert) {
                        final isSelected =
                            _selectedCertifications.contains(cert);
                        return FilterChip(
                          label: Text(cert),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCertifications.add(cert);
                              } else {
                                _selectedCertifications.remove(cert);
                              }
                            });
                          },
                          selectedColor: theme.primaryColor.withOpacity(0.3),
                          checkmarkColor: theme.primaryColor,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected
                                  ? theme.primaryColor
                                  : Colors.grey[800]!,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Operating Hours
              _SectionHeader(title: 'Operating Hours', icon: Icons.access_time),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: _weekdays.map((day) {
                    return ListTile(
                      leading:
                          Icon(Icons.calendar_today, color: theme.primaryColor),
                      title: Text(day),
                      subtitle: Text(_operatingHours[day] ?? 'Not set'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _setOperatingHours(day),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 24),

              // Service Options
              _SectionHeader(
                  title: 'Service Options', icon: Icons.local_shipping),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Delivery Available'),
                      subtitle: const Text('Offer delivery service'),
                      value: _deliveryAvailable,
                      onChanged: (value) {
                        setState(() => _deliveryAvailable = value);
                      },
                      secondary: Icon(Icons.delivery_dining,
                          color: theme.primaryColor),
                    ),
                    SwitchListTile(
                      title: const Text('Pickup Available'),
                      subtitle: const Text('Allow in-store pickup'),
                      value: _pickupAvailable,
                      onChanged: (value) {
                        setState(() => _pickupAvailable = value);
                      },
                      secondary: Icon(Icons.store, color: theme.primaryColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Blockchain
              _SectionHeader(
                  title: 'Blockchain', icon: Icons.account_balance_wallet),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _CustomTextField(
                      controller: _walletController,
                      label: 'Wallet Address',
                      icon: Icons.wallet,
                      readOnly: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.link, color: theme.primaryColor),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Wallet connection coming soon!')),
                        );
                      },
                      tooltip: 'Connect Wallet',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Preferences
              _SectionHeader(title: 'Preferences', icon: Icons.settings),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Enable Notifications'),
                      subtitle: const Text('Receive order updates'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() => _notificationsEnabled = value);
                      },
                      secondary:
                          Icon(Icons.notifications, color: theme.primaryColor),
                    ),
                    SwitchListTile(
                      title: const Text('Auto-accept Orders'),
                      subtitle: const Text(
                          'Automatically accept all incoming orders'),
                      value: _autoAcceptOrders,
                      onChanged: (value) {
                        setState(() => _autoAcceptOrders = value);
                      },
                      secondary:
                          Icon(Icons.auto_awesome, color: theme.primaryColor),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveProfile,
                  icon: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: theme.colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 24),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Changes',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
    );
  }
}

// Section Header Widget
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

// Custom Text Field Widget
class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int maxLines;
  final bool readOnly;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.maxLines = 1,
    this.readOnly = false,
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
        maxLines: maxLines,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
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
