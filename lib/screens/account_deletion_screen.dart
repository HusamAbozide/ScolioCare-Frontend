import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../widgets/app_header.dart';
import '../theme/app_theme.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({Key? key}) : super(key: key);

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _confirmDeletion = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    if (!_confirmDeletion) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm account deletion'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show final confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Final Confirmation'),
          ],
        ),
        content: const Text(
          'This action CANNOT be undone. All your data will be permanently deleted. Are you absolutely sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Delete My Account'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final profileProvider = context.read<ProfileProvider>();
      final success = await profileProvider.deleteAccount(
        password: _passwordController.text,
      );

      if (success && mounted) {
        // Clear all data and logout
        final authProvider = context.read<AuthProvider>();
        await authProvider.signOut();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to welcome screen
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/welcome',
          (route) => false,
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              profileProvider.error ?? 'Failed to delete account',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          AppBar(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delete Account'),
                Text(
                  'Permanently remove your account',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Warning Card
                  Card(
                    color: Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              size: 64, color: Colors.red[700]),
                          const SizedBox(height: 16),
                          Text(
                            'Warning: This Action is Permanent!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Once deleted, your account cannot be recovered',
                            style: TextStyle(color: Colors.red[800]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // What will be deleted
                  const Text(
                    'What will be deleted:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDeletionItem(
                    Icons.person,
                    'Your Profile',
                    'All personal information and medical history',
                  ),
                  _buildDeletionItem(
                    Icons.photo_library,
                    'All Images',
                    'Spine scans, analysis results, and posture photos',
                  ),
                  _buildDeletionItem(
                    Icons.fitness_center,
                    'Exercise Data',
                    'Your exercise plans, logs, and progress tracking',
                  ),
                  _buildDeletionItem(
                    Icons.description,
                    'Reports',
                    'All generated PDF reports and analysis history',
                  ),
                  _buildDeletionItem(
                    Icons.chat,
                    'Chat History',
                    'All conversations with the AI assistant',
                  ),
                  _buildDeletionItem(
                    Icons.notifications,
                    'Notifications',
                    'All notification history and preferences',
                  ),
                  const SizedBox(height: 24),

                  // Password Confirmation
                  const Text(
                    'Confirm Your Password:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Confirmation Checkbox
                  Card(
                    child: CheckboxListTile(
                      value: _confirmDeletion,
                      onChanged: (value) {
                        setState(() {
                          _confirmDeletion = value ?? false;
                        });
                      },
                      title: const Text(
                        'I understand that this action is permanent and cannot be undone',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'All my data will be permanently deleted',
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Delete Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Delete My Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel - Keep My Account',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Support Contact
                  Card(
                    color: Colors.blue[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.help_outline, color: Colors.blue[700]),
                          const SizedBox(height: 8),
                          Text(
                            'Need help or have questions?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Contact support before deleting your account',
                            style: TextStyle(color: Colors.blue[800]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeletionItem(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.red[700]),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.delete_forever, color: Colors.red),
      ),
    );
  }
}
