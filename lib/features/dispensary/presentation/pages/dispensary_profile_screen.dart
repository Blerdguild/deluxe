import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:deluxe/shared/models/dispensary_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:deluxe/features/dispensary/presentation/pages/edit_dispensary_profile_screen.dart';

class DispensaryProfileScreen extends StatelessWidget {
  const DispensaryProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.watch<AuthBloc>().state;

    if (authState is! Authenticated) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    final userId = authState.userId;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store,
                      size: 64, color: theme.primaryColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'Profile not found',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Please create your dispensary profile'),
                ],
              ),
            );
          }

          final profile = DispensaryProfile.fromDocument(snapshot.data!);

          return CustomScrollView(
            slivers: [
              // Header with gradient and logo
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.scaffoldBackgroundColor,
                          backgroundImage: profile.logoURL != null
                              ? CachedNetworkImageProvider(profile.logoURL!)
                              : null,
                          child: profile.logoURL == null
                              ? Icon(Icons.store,
                                  size: 50, color: theme.primaryColor)
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          profile.dispensaryName.isEmpty
                              ? 'Set Your Dispensary Name'
                              : profile.dispensaryName,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditDispensaryProfileScreen(profile: profile),
                        ),
                      );
                    },
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),

              // Profile Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Contact Information
                    _SectionHeader(
                        title: 'Contact Information',
                        icon: Icons.contact_phone),
                    const SizedBox(height: 12),
                    _CleanInfoContainer(
                      children: [
                        _CleanInfoRow(
                            icon: Icons.person,
                            label: 'Owner',
                            value: profile.ownerName),
                        _CleanInfoRow(
                            icon: Icons.email,
                            label: 'Email',
                            value: profile.email),
                        _CleanInfoRow(
                            icon: Icons.phone,
                            label: 'Phone',
                            value: profile.phoneNumber.isEmpty
                                ? 'Not set'
                                : profile.phoneNumber),
                        _CleanInfoRow(
                            icon: Icons.location_on,
                            label: 'Address',
                            value: profile.address.isEmpty
                                ? 'Not set'
                                : profile.address),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Business Details
                    _SectionHeader(
                        title: 'Business Details', icon: Icons.business),
                    const SizedBox(height: 12),
                    _CleanInfoContainer(
                      children: [
                        _CleanInfoRow(
                            icon: Icons.badge,
                            label: 'License',
                            value: profile.businessLicense ?? 'Not set'),
                        _CleanInfoRow(
                            icon: Icons.receipt_long,
                            label: 'Tax ID',
                            value: profile.taxId ?? 'Not set'),
                        _CleanInfoRow(
                            icon: Icons.verified,
                            label: 'Certifications',
                            value: profile.certifications.isEmpty
                                ? 'None'
                                : profile.certifications.join(', ')),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Service Options
                    _SectionHeader(
                        title: 'Service Options', icon: Icons.local_shipping),
                    const SizedBox(height: 12),
                    _CleanInfoContainer(
                      children: [
                        _CleanInfoRow(
                            icon: Icons.delivery_dining,
                            label: 'Delivery',
                            value: profile.deliveryAvailable
                                ? 'Available'
                                : 'Not available'),
                        _CleanInfoRow(
                            icon: Icons.store,
                            label: 'Pickup',
                            value: profile.pickupAvailable
                                ? 'Available'
                                : 'Not available'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Operating Hours
                    if (profile.operatingHours.isNotEmpty) ...[
                      _SectionHeader(
                          title: 'Operating Hours', icon: Icons.access_time),
                      const SizedBox(height: 12),
                      _CleanInfoContainer(
                        children: profile.operatingHours.entries.map((entry) {
                          return _CleanInfoRow(
                              icon: Icons.calendar_today,
                              label: entry.key,
                              value: entry.value);
                        }).toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Blockchain
                    _SectionHeader(
                        title: 'Blockchain',
                        icon: Icons.account_balance_wallet),
                    const SizedBox(height: 12),
                    _CleanInfoContainer(
                      children: [
                        _CleanInfoRow(
                            icon: Icons.wallet,
                            label: 'Wallet Address',
                            value: profile.walletAddress ?? 'Not connected'),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context
                              .read<AuthBloc>()
                              .add(const AuthLogoutRequested());
                        },
                        icon: const Icon(Icons.logout, size: 24),
                        label: const Text(
                          'Logout',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Section Header Widget
class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.primaryColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

// Clean Info Container
class _CleanInfoContainer extends StatelessWidget {
  final List<Widget> children;

  const _CleanInfoContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// Clean Info Row
class _CleanInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _CleanInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: Colors.grey[500]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
