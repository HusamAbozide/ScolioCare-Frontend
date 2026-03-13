import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _selectedGender;
  String? _diagnosisTime;
  String? _scoliosisType;
  String? _currentTreatment;
  int _selectedAvatar = 0;

  static const _avatars = ['👤', '👨', '👩', '🧑', '👦', '👧'];

  static const _weaknessOptions = [
    {'value': 'neck', 'label': 'Neck'},
    {'value': 'shoulders', 'label': 'Shoulders'},
    {'value': 'arms', 'label': 'Arms'},
    {'value': 'wrists', 'label': 'Wrists/Hands'},
    {'value': 'upper-back', 'label': 'Upper Back'},
    {'value': 'lower-back', 'label': 'Lower Back'},
    {'value': 'hips', 'label': 'Hips'},
    {'value': 'knees', 'label': 'Knees'},
    {'value': 'ankles', 'label': 'Ankles/Feet'},
    {'value': 'core', 'label': 'Core/Abdomen'},
  ];

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProfileProvider>(
      builder: (context, provider, _) {
        final step = provider.currentStep;
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Header with progress
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (step > 1)
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: provider.previousStep,
                            ),
                          const Spacer(),
                          Text(
                            'Step $step of ${ProfileProvider.totalSteps}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: provider.progress,
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: _buildStep(step, provider, theme),
                  ),
                ),

                // Next button
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: FilledButton.icon(
                    onPressed: () {
                      if (step == ProfileProvider.totalSteps) {
                        provider.saveProfile();
                        Navigator.pushReplacementNamed(context, '/dashboard');
                      } else {
                        provider.nextStep();
                      }
                    },
                    icon: const Icon(Icons.chevron_right),
                    label: Text(
                      step == ProfileProvider.totalSteps
                          ? 'Finish'
                          : 'Continue',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(int step, ProfileProvider provider, ThemeData theme) {
    switch (step) {
      case 1:
        return _buildPersonalInfo(theme);
      case 2:
        return _buildMedicalHistory(theme);
      case 3:
        return _buildPhysicalAssessment(provider, theme);
      case 4:
        return _buildFlexibilityActivity(provider, theme);
      case 5:
        return _buildPainLevel(provider, theme);
      case 6:
        return _buildSummary(provider, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Let\'s get to know you',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('This information helps us personalize your experience',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),

        // Avatars
        Text('Choose an avatar', style: theme.textTheme.labelLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: List.generate(_avatars.length, (i) {
            return GestureDetector(
              onTap: () => setState(() => _selectedAvatar = i),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2340) : const Color(0xFFF0ECF5),
                  border: Border.all(
                    color: i == _selectedAvatar
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Center(
                  child:
                      Text(_avatars[i], style: const TextStyle(fontSize: 24)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Age & Gender
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Age', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '25'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Gender', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(hintText: 'Select'),
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text('Male')),
                      DropdownMenuItem(value: 'female', child: Text('Female')),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Height & Weight
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Height (cm)', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _heightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '170'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Weight (kg)', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '65'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicalHistory(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Medical History',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Help us understand your scoliosis condition',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        _buildDropdown(
          theme,
          'When were you diagnosed?',
          _diagnosisTime,
          [
            'Less than 1 year ago',
            '1-3 years ago',
            '3-5 years ago',
            'More than 5 years ago',
            'Not diagnosed yet',
          ],
          (v) => setState(() => _diagnosisTime = v),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          theme,
          'Type of scoliosis (if known)',
          _scoliosisType,
          [
            'Idiopathic',
            'Congenital',
            'Neuromuscular',
            'Degenerative',
            'Unknown'
          ],
          (v) => setState(() => _scoliosisType = v),
        ),
        const SizedBox(height: 16),
        _buildDropdown(
          theme,
          'Current treatment',
          _currentTreatment,
          [
            'No treatment',
            'Observation only',
            'Physical therapy',
            'Bracing',
            'Post-surgery',
          ],
          (v) => setState(() => _currentTreatment = v),
        ),
      ],
    );
  }

  Widget _buildDropdown(ThemeData theme, String label, String? value,
      List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(hintText: 'Select'),
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildPhysicalAssessment(ProfileProvider provider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Physical Assessment',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Tell us about any weakness areas or limitations',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.warning_amber, size: 16, color: AppTheme.warning),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select any areas where you experience weakness, pain, or limited mobility.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 3,
          children: _weaknessOptions.map((area) {
            final isSelected =
                provider.profile.weaknessAreas.contains(area['value']);
            return InkWell(
              onTap: () => provider.toggleWeaknessArea(area['value']!),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2340) : const Color(0xFFF0ECF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (_) =>
                            provider.toggleWeaknessArea(area['value']!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        area['label']!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        if (provider.profile.weaknessAreas.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 20, color: AppTheme.success),
                  const SizedBox(width: 8),
                  Text(
                    'No significant weakness areas',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFlexibilityActivity(ProfileProvider provider, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Flexibility & Activity Level',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Help us customize your exercise program',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),

        // Flexibility
        _buildSliderCard(
          theme,
          title: 'Flexibility Level',
          subtitle: 'How flexible do you consider yourself?',
          value: provider.profile.flexibilityLevel,
          min: 1,
          max: 10,
          leftLabel: 'Very Stiff',
          rightLabel: 'Very Flexible',
          emojis: ['🔒', '🤸‍♀️', '🧘‍♀️'],
          emojiLabels: ['Stiff', 'Moderate', 'Flexible'],
          onChanged: (v) => provider.setFlexibilityLevel(v),
        ),
        const SizedBox(height: 24),

        // Activity
        _buildSliderCard(
          theme,
          title: 'Activity Level',
          subtitle: 'How active are you in your daily life?',
          value: provider.profile.activityLevel,
          min: 1,
          max: 10,
          leftLabel: 'Sedentary',
          rightLabel: 'Very Active',
          emojis: ['🛋️', '🚶‍♀️', '🏃‍♀️'],
          emojiLabels: ['Low', 'Moderate', 'High'],
          onChanged: (v) => provider.setActivityLevel(v),
        ),
      ],
    );
  }

  Widget _buildSliderCard(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required int value,
    required int min,
    required int max,
    required String leftLabel,
    required String rightLabel,
    required List<String> emojis,
    required List<String> emojiLabels,
    required ValueChanged<int> onChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(subtitle,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(leftLabel, style: theme.textTheme.bodySmall),
                Text('$value/$max',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
                Text(rightLabel, style: theme.textTheme.bodySmall),
              ],
            ),
            Slider(
              value: value.toDouble(),
              min: min.toDouble(),
              max: max.toDouble(),
              divisions: max - min,
              onChanged: (v) => onChanged(v.round()),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (i) {
                final isActive = (i == 0 && value <= 3) ||
                    (i == 1 && value > 3 && value <= 7) ||
                    (i == 2 && value > 7);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2340) : const Color(0xFFF0ECF5),
                    borderRadius: BorderRadius.circular(12),
                    border: isActive
                        ? Border.all(color: theme.colorScheme.primary, width: 2)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(emojis[i], style: const TextStyle(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text(emojiLabels[i], style: theme.textTheme.bodySmall),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPainLevel(ProfileProvider provider, ThemeData theme) {
    final level = provider.profile.painLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Pain Level',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('How would you rate your average daily back pain?',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('No pain', style: theme.textTheme.bodySmall),
                    Text('$level',
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        )),
                    Text('Severe', style: theme.textTheme.bodySmall),
                  ],
                ),
                Slider(
                  value: level.toDouble(),
                  min: 0,
                  max: 10,
                  divisions: 10,
                  onChanged: (v) => provider.setPainLevel(v.round()),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                      11, (i) => Text('$i', style: theme.textTheme.bodySmall)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPainEmoji(theme, '😊', 'Mild', level <= 3),
            _buildPainEmoji(theme, '😐', 'Moderate', level > 3 && level <= 6),
            _buildPainEmoji(theme, '😣', 'Severe', level > 6),
          ],
        ),
      ],
    );
  }

  Widget _buildPainEmoji(
      ThemeData theme, String emoji, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2340) : const Color(0xFFF0ECF5),
        borderRadius: BorderRadius.circular(12),
        border: active
            ? Border.all(color: theme.colorScheme.primary, width: 2)
            : null,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildSummary(ProfileProvider provider, ThemeData theme) {
    final p = provider.profile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Review your information before proceeding',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _summaryRow(
                    theme,
                    'Weakness Areas',
                    p.weaknessAreas.isEmpty
                        ? 'None'
                        : p.weaknessAreas.join(', ')),
                _summaryRow(theme, 'Flexibility', '${p.flexibilityLevel}/10'),
                _summaryRow(theme, 'Activity Level', '${p.activityLevel}/10'),
                _summaryRow(theme, 'Pain Level', '${p.painLevel}/10'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: AppTheme.success),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Your personalized exercise program will be created based on this information.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
