import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/legal_provider.dart';

class ConsentManagementScreen extends StatefulWidget {
  const ConsentManagementScreen({super.key});

  @override
  State<ConsentManagementScreen> createState() =>
      _ConsentManagementScreenState();
}

class _ConsentManagementScreenState extends State<ConsentManagementScreen> {
  final List<ConsentType> _consentTypes = [
    ConsentType(
      type: 'MEDICAL_DISCLAIMER',
      title: 'Medical Disclaimer',
      description:
          'Consent to use the app for informational purposes and understand it is not a replacement for professional medical advice.',
      icon: Icons.medical_information,
      required: true,
    ),
    ConsentType(
      type: 'DATA_PROCESSING',
      title: 'Data Processing',
      description:
          'Allow processing of your personal health data for analysis and recommendations.',
      icon: Icons.data_usage,
      required: true,
    ),
    ConsentType(
      type: 'NOTIFICATIONS',
      title: 'Notifications',
      description:
          'Receive notifications about exercises, appointments, and progress updates.',
      icon: Icons.notifications,
      required: false,
    ),
    ConsentType(
      type: 'ANALYTICS',
      title: 'Analytics',
      description:
          'Help improve the app by sharing anonymous usage data and analytics.',
      icon: Icons.analytics,
      required: false,
    ),
    ConsentType(
      type: 'MARKETING',
      title: 'Marketing Communications',
      description:
          'Receive updates about new features, tips, and promotional content.',
      icon: Icons.campaign,
      required: false,
    ),
  ];

  Future<void> _toggleConsent(ConsentType consent, bool newValue) async {
    final legalProvider = context.read<LegalProvider>();
    bool success;

    if (newValue) {
      success = await legalProvider.acceptConsent(consent.type);
    } else {
      if (consent.required) {
        if (!mounted) return;
        _showRequiredConsentDialog(consent);
        return;
      }
      success = await legalProvider.withdrawConsent(consent.type);
    }

    if (!mounted) return;

    if (success) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? '${consent.title} consent accepted'
                : '${consent.title} consent withdrawn',
          ),
          backgroundColor: newValue ? Colors.green : Colors.orange,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            legalProvider.error ?? 'Failed to update consent',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRequiredConsentDialog(ConsentType consent) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            const Text('Required Consent'),
          ],
        ),
        content: Text(
          'This consent is required to use the app. Withdrawing it will limit or prevent access to core features.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showConsentDetails(ConsentType consent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        consent.icon,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            consent.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          if (consent.required)
                            Text(
                              'Required',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Description',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          consent.description,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'What this means',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getDetailedDescription(consent.type),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    height: 1.5,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Close button
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getDetailedDescription(String type) {
    switch (type) {
      case 'MEDICAL_DISCLAIMER':
        return 'By accepting this consent, you acknowledge that ScolioCare is designed to provide information and support for scoliosis management, but does not replace professional medical advice, diagnosis, or treatment. Always consult with qualified healthcare providers for medical decisions.';
      case 'DATA_PROCESSING':
        return 'This consent allows us to process your health data, including images, measurements, and progress tracking information to provide personalized recommendations and analysis. Your data is encrypted and stored securely.';
      case 'NOTIFICATIONS':
        return 'Enabling notifications allows the app to send you reminders for exercises, appointments, and updates about your progress. You can customize notification preferences in settings.';
      case 'ANALYTICS':
        return 'Anonymous usage data helps us understand how the app is used and identify areas for improvement. No personally identifiable information is shared.';
      case 'MARKETING':
        return 'Receive occasional emails or in-app messages about new features, wellness tips, and updates. You can unsubscribe at any time.';
      default:
        return 'Additional information about this consent type.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consent Management'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<LegalProvider>(
        builder: (context, legalProvider, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Manage your consent preferences. Required consents are necessary for core app functionality.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Consent items
                ..._consentTypes.map((consent) {
                  final isGiven = legalProvider.isConsentGiven(consent.type);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  consent.icon,
                                  color: theme.colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            consent.title,
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (consent.required)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.red.withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              'Required',
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: isGiven,
                                onChanged: (value) =>
                                    _toggleConsent(consent, value),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            consent.description,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _showConsentDetails(consent),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Learn more',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ConsentType {
  final String type;
  final String title;
  final String description;
  final IconData icon;
  final bool required;

  ConsentType({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.required,
  });
}
