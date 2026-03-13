import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../models/exercise.dart';
import '../widgets/mobile_layout.dart';
import '../theme/app_theme.dart';

class ExerciseProgramScreen extends StatelessWidget {
  const ExerciseProgramScreen({super.key});

  static const _tabKeys = [
    'strengthening',
    'stretching',
    'posture',
    'breathing'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobileLayout(
      currentNavIndex: 3,
      child: DefaultTabController(
        length: 4,
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverAppBar(
              title: const Text('Exercise Program'),
              floating: true,
              pinned: true,
              bottom: TabBar(
                isScrollable: true,
                tabs: const [
                  Tab(text: '💪 Strengthening'),
                  Tab(text: '🧘 Stretching'),
                  Tab(text: '🧍 Posture'),
                  Tab(text: '🌬️ Breathing'),
                ],
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          body: Consumer<ExerciseProvider>(
            builder: (context, provider, _) {
              final cats = provider.categories;
              return TabBarView(
                children: _tabKeys.map((key) {
                  final cat = cats[key];
                  return _ExerciseTab(
                    categoryKey: key,
                    exercises: cat?.exercises ?? [],
                    provider: provider,
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExerciseTab extends StatelessWidget {
  final String categoryKey;
  final List<Exercise> exercises;
  final ExerciseProvider provider;

  const _ExerciseTab({
    required this.categoryKey,
    required this.exercises,
    required this.provider,
  });

  IconData _categoryIcon() {
    switch (categoryKey) {
      case 'strengthening':
        return Icons.fitness_center;
      case 'stretching':
        return Icons.self_improvement;
      case 'posture':
        return Icons.accessibility_new;
      case 'breathing':
        return Icons.air;
      default:
        return Icons.fitness_center;
    }
  }

  String _categoryDescription() {
    switch (categoryKey) {
      case 'strengthening':
        return 'Build core stability and muscle strength to support your spine.';
      case 'stretching':
        return 'Improve flexibility and reduce muscle tension.';
      case 'posture':
        return 'Develop awareness and maintain proper spinal alignment.';
      case 'breathing':
        return 'Enhance lung capacity and relaxation.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = exercises.where((e) => e.completed).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_categoryIcon(), color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_categoryDescription(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                    const SizedBox(height: 4),
                    Text('$completed/${exercises.length} completed',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Progress
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: exercises.isEmpty ? 0 : completed / exercises.length,
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 16),

        // Exercise cards
        for (int i = 0; i < exercises.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ExerciseCard(
              exercise: exercises[i],
              onToggle: () => provider.toggleExercise(categoryKey, i),
            ),
          ),
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final VoidCallback onToggle;

  const _ExerciseCard({required this.exercise, required this.onToggle});

  Color _difficultyColor() {
    switch (exercise.difficulty.toLowerCase()) {
      case 'easy':
        return AppTheme.success;
      case 'medium':
        return AppTheme.warning;
      case 'hard':
        return AppTheme.destructive;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: exercise.completed
                          ? AppTheme.success
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: exercise.completed
                            ? AppTheme.success
                            : theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: exercise.completed
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Text(
                    exercise.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      decoration: exercise.completed
                          ? TextDecoration.lineThrough
                          : null,
                      color: exercise.completed
                          ? theme.colorScheme.onSurfaceVariant
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const SizedBox(width: 48),
                _Tag(Icons.timer_outlined, exercise.duration, theme),
                const SizedBox(width: 8),
                if (exercise.reps.isNotEmpty)
                  _Tag(Icons.repeat, exercise.reps, theme),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _difficultyColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    exercise.difficulty,
                    style: TextStyle(
                      color: _difficultyColor(),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  final ThemeData theme;

  const _Tag(this.icon, this.label, this.theme);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
