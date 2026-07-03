import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_fab.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final profile = profileProvider.profile;
    final fullName = authProvider.currentUser?.fullName ?? '';
    final displayName = fullName.isNotEmpty
        ? fullName
        : (profile.name.isNotEmpty ? profile.name : 'User');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                displayName.isNotEmpty
                                    ? displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            if (authProvider.currentUser?.email != null)
                              Text(
                                authProvider.currentUser!.email,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Profile Information
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Height & Weight
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.height,
                                label: 'Height',
                                value: profile.heightCm != null
                                    ? '${profile.heightCm} cm'
                                    : 'Not set',
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.monitor_weight,
                                label: 'Weight',
                                value: profile.weightKg != null
                                    ? '${profile.weightKg} kg'
                                    : 'Not set',
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Activity & Pain Level
                        Row(
                          children: [
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.directions_run,
                                label: 'Activity Level',
                                value: _getActivityLabel(profile.activityLevel),
                                theme: theme,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _InfoCard(
                                icon: Icons.favorite,
                                label: 'Pain Level',
                                value: '${profile.painLevel}/10',
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Weakness Areas
                        if (profile.weaknessAreas.isNotEmpty) ...[
                          Text(
                            'Focus Areas',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: profile.weaknessAreas.map((area) {
                              return Chip(
                                label: Text(_formatAreaName(area)),
                                backgroundColor:
                                    theme.colorScheme.primary.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Account Actions
                        Text(
                          'Account',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Card(
                          child: Column(
                            children: [
                              ListTile(
                                leading: Icon(Icons.edit,
                                    color: theme.colorScheme.primary),
                                title: const Text('Edit Profile'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(context, '/edit-profile');
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.lock,
                                    color: theme.colorScheme.primary),
                                title: const Text('Change Password'),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () =>
                                    Navigator.pushNamed(context, '/change-password'),
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: Icon(Icons.logout,
                                    color: AppTheme.destructive),
                                title: Text(
                                  'Logout',
                                  style: TextStyle(color: AppTheme.destructive),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Logout'),
                                      content: const Text(
                                          'Are you sure you want to logout?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Logout'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    await context
                                        .read<AuthProvider>()
                                        .signOut();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        '/login',
                                        (route) => false,
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: const ChatFab(),
    );
  }

  String _getActivityLabel(int level) {
    if (level <= 3) return 'Low';
    if (level <= 7) return 'Moderate';
    return 'High';
  }

  String _formatAreaName(String area) {
    return area
        .split('-')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
