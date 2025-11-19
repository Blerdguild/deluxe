import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/shared/models/farmer_profile.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EditFarmerProfileScreen extends StatefulWidget {
  final FarmerProfile profile;

  const EditFarmerProfileScreen({
    super.key,
    required this.profile,
  });

  @override
  State<EditFarmerProfileScreen> createState() =>
      _EditFarmerProfileScreenState();
}

class _EditFarmerProfileScreenState extends State<EditFarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _picker = ImagePicker();

  late final TextEditingController _displayNameController;
  late final TextEditingController _farmNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final TextEditingController _bioController;
  late final TextEditingController _farmSizeController;
  late final TextEditingController _yearsController;
  late final TextEditingController _walletController;
  late final TextEditingController _businessLicenseController;
  late final TextEditingController _taxIdController;

  String? _selectedFarmType;
  List<String> _selectedCertifications = [];
  bool _notificationsEnabled = true;
  bool _autoAcceptOrders = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _currentPhotoURL;

  final List<String> _farmTypes = [
    'Organic',
    'Indoor',
    'Outdoor',
    'Greenhouse',
    'Hydroponic',
    'Mixed',
  ];

  final List<String> _availableCertifications = [
    'Organic',
    'Fair Trade',
    'Rainforest Alliance',
    'Non-GMO',
    'Biodynamic',
    'Sustainable',
  ];

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.profile.displayName);
    _farmNameController = TextEditingController(text: widget.profile.farmName);
    _phoneController = TextEditingController(text: widget.profile.phoneNumber);
    _locationController = TextEditingController(text: widget.profile.location);
    _bioController = TextEditingController(text: widget.profile.bio);
    _farmSizeController =
        TextEditingController(text: widget.profile.farmSize?.toString());
    _yearsController =
        TextEditingController(text: widget.profile.yearsInBusiness?.toString());
    _walletController =
        TextEditingController(text: widget.profile.walletAddress);
    _businessLicenseController =
        TextEditingController(text: widget.profile.businessLicense);
    _taxIdController = TextEditingController(text: widget.profile.taxId);

    _selectedFarmType = widget.profile.farmType;
    _selectedCertifications = widget.profile.certifications ?? [];
    _notificationsEnabled = widget.profile.notificationsEnabled;
    _autoAcceptOrders = widget.profile.autoAcceptOrders;
    _currentPhotoURL = widget.profile.photoURL;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _farmNameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    _farmSizeController.dispose();
    _yearsController.dispose();
    _walletController.dispose();
    _businessLicenseController.dispose();
    _taxIdController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final updatedProfile = widget.profile.copyWith(
        displayName: _displayNameController.text.trim(),
        farmName: _farmNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        bio: _bioController.text.trim(),
        farmType: _selectedFarmType,
        farmSize: double.tryParse(_farmSizeController.text),
        yearsInBusiness: int.tryParse(_yearsController.text),
        walletAddress: _walletController.text.trim(),
        businessLicense: _businessLicenseController.text.trim(),
        taxId: _taxIdController.text.trim(),
        certifications: _selectedCertifications,
        notificationsEnabled: _notificationsEnabled,
        autoAcceptOrders: _autoAcceptOrders,
        photoURL: _currentPhotoURL,
      );

      await _firestore
          .collection('users')
          .doc(widget.profile.uid)
          .update(updatedProfile.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Profile updated successfully!'),
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
          'profile_${widget.profile.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref =
          _storage.ref().child('profile_images').child(fileName);

      // Upload task
      await ref.putFile(file);
      final String downloadUrl = await ref.getDownloadURL();

      setState(() {
        _currentPhotoURL = downloadUrl;
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

  void _connectWallet() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wallet connection coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.cardTheme.color,
                      backgroundImage: _currentPhotoURL != null
                          ? CachedNetworkImageProvider(_currentPhotoURL!)
                          : null,
                      child: _isUploadingImage
                          ? const CircularProgressIndicator()
                          : (_currentPhotoURL == null
                              ? const Icon(Icons.agriculture, size: 50)
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
                          icon: const Icon(Icons.camera_alt,
                              color: Colors.white, size: 20),
                          onPressed: _isUploadingImage ? null : _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Basic Information
              _SectionHeader(title: 'Basic Information', icon: Icons.person),
              const SizedBox(height: 12),
              _CustomTextField(
                controller: _displayNameController,
                label: 'Display Name',
                icon: Icons.person_outline,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter your name'
                    : null,
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _farmNameController,
                label: 'Farm Name',
                icon: Icons.agriculture,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter your farm name'
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
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on,
              ),

              const SizedBox(height: 24),

              // Farm Details
              _SectionHeader(title: 'Farm Details', icon: Icons.eco),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedFarmType,
                  decoration: const InputDecoration(
                    labelText: 'Farm Type',
                    prefixIcon: Icon(Icons.category),
                    border: InputBorder.none,
                  ),
                  dropdownColor: theme.cardTheme.color,
                  items: _farmTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedFarmType = value);
                  },
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _CustomTextField(
                      controller: _farmSizeController,
                      label: 'Size (acres)',
                      icon: Icons.straighten,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _CustomTextField(
                      controller: _yearsController,
                      label: 'Years in Biz',
                      icon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _CustomTextField(
                controller: _bioController,
                label: 'Farm Description',
                icon: Icons.description,
                maxLines: 4,
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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[500],
                          ),
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
                      onPressed: _connectWallet,
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                    ),
                    // No divider here, just clean spacing if needed
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
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
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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

// Clean Section Header - Matches AddHarvestScreen
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

// Clean Custom Text Field - Matches AddHarvestScreen EXACTLY
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
            borderSide: BorderSide.none, // Borderless look
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: validator,
      ),
    );
  }
}
