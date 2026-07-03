import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/legal_provider.dart';

class MedicalConsentScreen extends StatefulWidget {
  final Widget? child;
  final String? nextRoute;
  final bool allowSkip;

  const MedicalConsentScreen({
    super.key,
    this.child,
    this.nextRoute,
    this.allowSkip = true,
  });

  @override
  State<MedicalConsentScreen> createState() => _MedicalConsentScreenState();
}

class _MedicalConsentScreenState extends State<MedicalConsentScreen> {
  static const String _consentType = 'MEDICAL_DISCLAIMER';
  bool _loaded = false;
  bool _checkingConsent = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final legal = context.read<LegalProvider>();
      await legal.loadConsents();
      if (!mounted) return;
      setState(() {
        _checkingConsent = false;
      });
      if (legal.isConsentGiven(_consentType) && widget.child == null) {
        _continue();
      }
    });
  }

  Future<void> _accept() async {
    final legal = context.read<LegalProvider>();
    final success = await legal.acceptConsent(_consentType);
    if (!mounted) return;
    if (success) {
      if (widget.child != null) {
        setState(() {});
      } else {
        _continue();
      }
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(legal.error ?? 'Failed to save consent'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _continue() {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    final nextRoute = widget.nextRoute ??
        (routeArgs is Map<String, dynamic>
            ? routeArgs['nextRoute'] as String?
            : null);
    final nextArguments = routeArgs is Map<String, dynamic>
        ? routeArgs['nextArguments']
        : null;
    if (nextRoute != null) {
      Navigator.pushReplacementNamed(
        context,
        nextRoute,
        arguments: nextArguments,
      );
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final legal = context.watch<LegalProvider>();
    if (_checkingConsent) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.child != null && legal.isConsentGiven(_consentType)) {
      return widget.child!;
    }

    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Consent'),
        leading: widget.allowSkip || Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  if (widget.child != null) {
                    Navigator.pop(context);
                  } else {
                    _continue();
                  }
                },
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medical_information_outlined,
                        color: Colors.orange,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ScolioCare does not replace a doctor',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Before using AI image analysis or the chatbot, please confirm that you understand these limits.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const _ConsentPoint(
                      icon: Icons.person_search_outlined,
                      title: 'Consult a qualified doctor',
                      body:
                          'The app provides informational support only. Medical decisions should be reviewed with a healthcare professional.',
                    ),
                    const _ConsentPoint(
                      icon: Icons.psychology_alt_outlined,
                      title: 'AI can be wrong',
                      body:
                          'AI analysis and chatbot responses may be inaccurate, incomplete, or unsuitable for your specific condition.',
                    ),
                    const _ConsentPoint(
                      icon: Icons.emergency_outlined,
                      title: 'Do not delay medical care',
                      body:
                          'If symptoms worsen or you have urgent concerns, seek medical help immediately.',
                    ),
                    const _ConsentPoint(
                      icon: Icons.check_circle_outline,
                      title: 'Your choice',
                      body:
                          'You can keep using the rest of the app without accepting, but image analysis and chatbot access require this consent.',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton(
                    onPressed: legal.isLoading ? null : _accept,
                    child: legal.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('I understand and accept'),
                  ),
                  if (widget.allowSkip) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _continue,
                      child: Text(
                        widget.child == null ? 'Not now' : 'Go back',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _ConsentPoint({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
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
