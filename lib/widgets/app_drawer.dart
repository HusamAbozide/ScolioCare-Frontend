/*import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final currentUser = authProvider.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    currentUser?.firstName?.isNotEmpty == true
                        ? currentUser!.firstName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  currentUser?.firstName != null &&
                          currentUser?.lastName != null
                      ? '${currentUser!.firstName} ${currentUser.lastName}'
                      : 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (currentUser?.email != null)
                  Text(
                    currentUser!.email,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),

          // Dashboard
          ListTile(
            leading: Icon(Icons.home, color: theme.colorScheme.primary),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),

          const Divider(),

          // Profile
          ListTile(
            leading: Icon(Icons.person, color: theme.colorScheme.primary),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/profile');
            },
          ),

          // Notifications
          ListTile(
            leading:
                Icon(Icons.notifications, color: theme.colorScheme.primary),
            title: const Text('Notifications'),
            trailing: notificationProvider.unreadCount > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.destructive,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 20, minHeight: 20),
                    child: Text(
                      '${notificationProvider.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : null,
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/notifications');
            },
          ),

          // Settings
          ListTile(
            leading: Icon(Icons.settings, color: theme.colorScheme.primary),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/settings');
            },
          ),

          const Divider(),

          // Reports
          ListTile(
            leading: Icon(Icons.description, color: theme.colorScheme.primary),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/reports');
            },
          ),

          // Scan History
          ListTile(
            leading: Icon(Icons.history, color: theme.colorScheme.primary),
            title: const Text('Scan History'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/scan-history');
            },
          ),

          const Divider(),

          // Help & Support
          ListTile(
            leading:
                Icon(Icons.help, color: theme.colorScheme.onSurfaceVariant),
            title: const Text('Help & Support'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon!')),
              );
            },
          ),

          // About
          ListTile(
            leading:
                Icon(Icons.info, color: theme.colorScheme.onSurfaceVariant),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              showAboutDialog(
                context: context,
                applicationName: 'ScolioCare',
                applicationVersion: '1.0.0',
                applicationIcon: Icon(
                  Icons.favorite,
                  size: 40,
                  color: theme.colorScheme.primary,
                ),
                children: [
                  const Text(
                    'Your personal scoliosis management companion',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // Logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  }
                }
              },
              icon: Icon(Icons.logout, color: AppTheme.destructive),
              label: Text(
                'Logout',
                style: TextStyle(color: AppTheme.destructive),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppTheme.destructive),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
*/