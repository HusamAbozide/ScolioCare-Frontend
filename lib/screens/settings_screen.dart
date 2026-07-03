import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/chat_fab.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          final auth = context.watch<AuthProvider>();
          final fullName = auth.currentUser?.fullName ?? '';
          final displayName = fullName.isNotEmpty ? fullName : 'User';
          final email = auth.currentUser?.email ?? 'user@example.com';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('👤',
                                style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(displayName,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  )),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/edit-profile'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Preferences
                Text('Preferences',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Exercise reminders & updates',
                        trailing: Switch(
                          value: settings.notificationsEnabled,
                          onChanged: (v) => settings.setNotifications(v),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Reduce eye strain',
                        trailing: Switch(
                          value: settings.darkModeEnabled,
                          onChanged: (v) => settings.setDarkMode(v),
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: settings.language,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showLanguageDialog(context, settings),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Data & History
                Text('Data & History',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.history,
                        title: 'Scan History',
                        subtitle: 'View all past scans',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/scan-history'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.description_outlined,
                        title: 'Reports',
                        subtitle: 'Download & share reports',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/reports'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.chat_outlined,
                        title: 'Chat Assistant',
                        subtitle: 'Ask questions about scoliosis',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/chatbot'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Posture & Tracking
                Text('Posture & Tracking',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.photo_camera,
                        title: 'Posture Photos',
                        subtitle: 'Track your posture progress',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/posture-tracking'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Rewards
                Text('Rewards',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.emoji_events_outlined,
                        title: 'Rewards & Achievements',
                        subtitle: 'View your earned rewards',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/rewards'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Security & Account
                Text('Security & Account',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your account password',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/change-password'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.delete_forever,
                        title: 'Delete Account',
                        subtitle: 'Permanently remove your account',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/account-deletion'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Legal
                Text('Legal',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      _SettingsTile(
                        icon: Icons.medical_information_outlined,
                        title: 'Medical Disclaimer',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/medical-disclaimer'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/privacy'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.gavel,
                        title: 'Terms of Service',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(context, '/terms'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: 'Consent Management',
                        subtitle: 'Manage your consent preferences',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, '/consent-management'),
                      ),
                      const Divider(height: 1, indent: 56),
                      _SettingsTile(
                        icon: Icons.info_outline,
                        title: 'About ScolioCare',
                        subtitle: 'Version 1.0.0',
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showAboutDialog(
                          context: context,
                          applicationName: 'ScolioCare',
                          applicationVersion: '1.0.0',
                          applicationLegalese:
                              'ScolioCare is for informational support and does not replace professional medical advice.',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Logout
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (!context.mounted) return;
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (_) => false);
                    },
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sign Out',
                        style: TextStyle(color: Colors.red)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
      floatingActionButton: const ChatFab(),
    );
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settings) {
    final languages = ['English', 'Arabic', 'French', 'Spanish'];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: languages
            .map((lang) => SimpleDialogOption(
                  onPressed: () {
                    settings.setLanguage(lang);
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      if (settings.language == lang)
                        Icon(Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20)
                      else
                        const SizedBox(width: 20),
                      const SizedBox(width: 12),
                      Text(lang),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: theme.colorScheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w500)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
