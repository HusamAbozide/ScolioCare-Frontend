import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  bool _hydrated = false;
  String? _gender;
  String? _diagnosisTime;
  String? _currentTreatment;

  static const _weaknessOptions = [
    {'value': 'neck', 'label': 'Neck'},
    {'value': 'shoulders', 'label': 'Shoulders'},
    {'value': 'upper-back', 'label': 'Upper back'},
    {'value': 'lower-back', 'label': 'Lower back'},
    {'value': 'hips', 'label': 'Hips'},
    {'value': 'core', 'label': 'Core'},
    {'value': 'knees', 'label': 'Knees'},
    {'value': 'ankles', 'label': 'Ankles'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<ProfileProvider>();
      await provider.fetchProfile();
      if (mounted) _hydrate(provider);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _hydrate(ProfileProvider provider) {
    final profile = provider.profile;
    _firstNameController.text = profile.firstName ?? '';
    _lastNameController.text = profile.lastName ?? '';
    _ageController.text = profile.age?.toString() ?? '';
    _heightController.text = profile.heightCm?.toStringAsFixed(0) ?? '';
    _weightController.text = profile.weightKg?.toStringAsFixed(0) ?? '';
    _gender = profile.gender?.toUpperCase();
    _diagnosisTime = profile.diagnosisTime;
    _currentTreatment = profile.currentTreatment;
    _hydrated = true;
    setState(() {});
  }

  Future<void> _save(ProfileProvider provider) async {
    provider.setPersonalDetails(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
      gender: _gender,
      heightCm: double.tryParse(_heightController.text.trim()),
      weightKg: double.tryParse(_weightController.text.trim()),
      diagnosisTime: _diagnosisTime,
      currentTreatment: _currentTreatment,
    );

    await provider.saveProfile(recordPainChange: true);

    if (!mounted) return;
    if (provider.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage!),
          backgroundColor: AppTheme.destructive,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        if (!_hydrated && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_hydrated) _hydrate(provider);
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Profile'),
          ),
          body: provider.isLoading && !_hydrated
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Section(
                        title: 'Personal details',
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _firstNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'First name',
                                      prefixIcon: Icon(Icons.person_outline),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _lastNameController,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    decoration: const InputDecoration(
                                      labelText: 'Last name',
                                      prefixIcon: Icon(Icons.badge_outlined),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Age',
                                suffixText: 'years',
                                prefixIcon: Icon(Icons.cake_outlined),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _heightController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Height',
                                      suffixText: 'cm',
                                      prefixIcon: Icon(Icons.height),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _weightController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Weight',
                                      suffixText: 'kg',
                                      prefixIcon: Icon(Icons.monitor_weight),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'Daily condition',
                        child: Column(
                          children: [
                            _MetricSlider(
                              title: 'Pain level',
                              value: provider.profile.painLevel,
                              minLabel: 'Low',
                              maxLabel: 'High',
                              icon: Icons.favorite_outline,
                              color: _painColor(provider.profile.painLevel),
                              onChanged: provider.setPainLevel,
                            ),
                            const SizedBox(height: 12),
                            _MetricSlider(
                              title: 'Activity level',
                              value: provider.profile.activityLevel,
                              minLabel: 'Resting',
                              maxLabel: 'Active',
                              icon: Icons.directions_walk,
                              color: theme.colorScheme.primary,
                              onChanged: provider.setActivityLevel,
                            ),
                            const SizedBox(height: 12),
                            _MetricSlider(
                              title: 'Flexibility',
                              value: provider.profile.flexibilityLevel,
                              minLabel: 'Stiff',
                              maxLabel: 'Flexible',
                              icon: Icons.self_improvement,
                              color: AppTheme.success,
                              onChanged: provider.setFlexibilityLevel,
                            ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'Medical context',
                        child: Column(
                          children: [
                            DropdownButtonFormField<String>(
                              value: _gender,
                              decoration: const InputDecoration(
                                labelText: 'Gender',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'MALE', child: Text('Male')),
                                DropdownMenuItem(
                                    value: 'FEMALE', child: Text('Female')),
                                DropdownMenuItem(
                                    value: 'OTHER', child: Text('Other')),
                              ],
                              onChanged: (value) =>
                                  setState(() => _gender = value),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _diagnosisTime,
                              decoration: const InputDecoration(
                                labelText: 'Diagnosis timing',
                                prefixIcon: Icon(Icons.event_note_outlined),
                              ),
                              items: const [
                                'Less than 1 year ago',
                                '1-3 years ago',
                                '3-5 years ago',
                                'More than 5 years ago',
                                'Not diagnosed yet',
                              ]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _diagnosisTime = value),
                            ),
                            const SizedBox(height: 12),
                            DropdownButtonFormField<String>(
                              value: _currentTreatment,
                              decoration: const InputDecoration(
                                labelText: 'Current treatment',
                                prefixIcon: Icon(Icons.medical_services),
                              ),
                              items: const [
                                'No treatment',
                                'Observation only',
                                'Physical therapy',
                                'Bracing',
                                'Post-surgery',
                              ]
                                  .map(
                                    (value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) =>
                                  setState(() => _currentTreatment = value),
                            ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'Focus areas',
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _weaknessOptions.map((area) {
                            final value = area['value']!;
                            final selected =
                                provider.profile.weaknessAreas.contains(value);
                            return FilterChip(
                              label: Text(area['label']!),
                              selected: selected,
                              onSelected: (_) =>
                                  provider.toggleWeaknessArea(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 88),
                    ],
                  ),
                ),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: FilledButton.icon(
              onPressed: provider.isLoading ? null : () => _save(provider),
              icon: provider.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Save changes'),
            ),
          ),
        );
      },
    );
  }

  Color _painColor(int level) {
    if (level <= 3) return AppTheme.success;
    if (level <= 6) return AppTheme.warning;
    return AppTheme.destructive;
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MetricSlider extends StatelessWidget {
  final String title;
  final int value;
  final String minLabel;
  final String maxLabel;
  final IconData icon;
  final Color color;
  final ValueChanged<int> onChanged;

  const _MetricSlider({
    required this.title,
    required this.value,
    required this.minLabel,
    required this.maxLabel,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '$value/10',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            activeColor: color,
            onChanged: (next) => onChanged(next.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: theme.textTheme.bodySmall),
              Text(maxLabel, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
