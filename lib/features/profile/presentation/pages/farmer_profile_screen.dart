import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:deluxe/features/auth/bloc/auth_bloc.dart';
import 'package:deluxe/features/profile/presentation/pages/edit_farmer_profile_screen.dart';
import 'package:deluxe/shared/models/farmer_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({super.key});

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = _auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = FarmerProfile.fromDocument(snapshot.data!);

          return CustomScrollView(
            slivers: [
              // App Bar with Profile Header
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                elevation: 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: _ProfileHeader(profile: profile),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditFarmerProfileScreen(profile: profile),
                        ),
                      );
                      if (result != null && mounted) {
                        setState(() {}); // Refresh
                      }
                    },
                  ),
                ],
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Farm Information
                      if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                        _SectionTitle(title: 'About', icon: Icons.info_outline),
                        const SizedBox(height: 12),
                        _CleanInfoContainer(
                          child: Text(
                            profile.bio!,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Contact Information
                      _SectionTitle(
                          title: 'Contact', icon: Icons.contact_phone),
                      const SizedBox(height: 12),
                      if (profile.phoneNumber != null) ...[
                        _CleanInfoRow(
                          icon: Icons.phone,
                          label: 'Phone',
                          value: profile.phoneNumber!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      if (profile.location != null) ...[
                        _CleanInfoRow(
                          icon: Icons.location_on,
                          label: 'Location',
                          value: profile.location!,
                        ),
                        const SizedBox(height: 12),
                      ],
                      _CleanInfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: profile.email,
                      ),

                      const SizedBox(height: 24),

                      // Farm Details
                      if (profile.farmType != null ||
                          profile.farmSize != null ||
                          profile.yearsInBusiness != null) ...[
                        _SectionTitle(title: 'Farm Details', icon: Icons.eco),
                        const SizedBox(height: 12),
                        if (profile.farmType != null) ...[
                          _CleanInfoRow(
                            icon: Icons.category,
                            label: 'Farm Type',
                            value: profile.farmType!,
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (profile.farmSize != null) ...[
                          _CleanInfoRow(
                            icon: Icons.straighten,
                            label: 'Farm Size',
                            value: '${profile.farmSize} acres',
                          ),
                          const SizedBox(height: 12),
                        ],
                        if (profile.yearsInBusiness != null) ...[
                          _CleanInfoRow(
                            icon: Icons.calendar_today,
                            label: 'Years in Business',
                            value: '${profile.yearsInBusiness} years',
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],

                      // Wallet Information
                      if (profile.walletAddress != null &&
                          profile.walletAddress!.isNotEmpty) ...[
                        _SectionTitle(
                            title: 'Blockchain',
                            icon: Icons.account_balance_wallet),
                        const SizedBox(height: 12),
                        _CleanInfoRow(
                          icon: Icons.wallet,
                          label: 'Wallet Address',
                          value:
                              '${profile.walletAddress!.substring(0, 6)}...${profile.walletAddress!.substring(profile.walletAddress!.length - 4)}',
                          isMonospace: true,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Preferences
                      _SectionTitle(title: 'Preferences', icon: Icons.settings),
                      const SizedBox(height: 12),
                      _CleanPreferenceRow(
                        icon: Icons.notifications,
                        label: 'Notifications',
                        value: profile.notificationsEnabled,
                      ),
                      const SizedBox(height: 12),
                      _CleanPreferenceRow(
                        icon: Icons.auto_awesome,
                        label: 'Auto-accept Orders',
                        value: profile.autoAcceptOrders,
                      ),

                      const SizedBox(height: 32),

                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _showLogoutDialog(context);
                          },
                          icon: const Icon(Icons.logout, size: 24),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
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
            ],
          );
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardTheme.color,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}

// Profile Header Widget
class _ProfileHeader extends StatelessWidget {
  final FarmerProfile profile;

  const _ProfileHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.primaryColor.withOpacity(0.3),
            theme.scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 60,
              backgroundImage: profile.photoURL != null
                  ? NetworkImage(profile.photoURL!)
                  : null,
              child: profile.photoURL == null
                  ? const Icon(Icons.agriculture, size: 50)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              profile.displayName ?? 'No Name',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (profile.farmName != null) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.eco, size: 16, color: theme.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    profile.farmName!,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.primaryColor.withOpacity(0.5)),
              ),
              child: Text(
                'Farmer',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Section Title Widget
class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
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

// Clean Info Container
class _CleanInfoContainer extends StatelessWidget {
  final Widget child;

  const _CleanInfoContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}

// Clean Info Row Widget
class _CleanInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isMonospace;

  const _CleanInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: theme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Clean Preference Row Widget
class _CleanPreferenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;

  const _CleanPreferenceRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: theme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: value
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value ? 'Enabled' : 'Disabled',
              style: TextStyle(
                color: value ? Colors.green : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
