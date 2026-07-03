import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/exercise.dart';
import '../providers/auth_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mobile_layout.dart';

class ExerciseProgramScreen extends StatefulWidget {
  const ExerciseProgramScreen({super.key});

  @override
  State<ExerciseProgramScreen> createState() => _ExerciseProgramScreenState();
}

class _ExerciseProgramScreenState extends State<ExerciseProgramScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProgram());
  }

  Future<void> _loadProgram() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null || userId.isEmpty) return;
    final provider = context.read<ExerciseProvider>();
    await provider.loadCurrentPlan(userId);
    await provider.loadExerciseLogs(userId);
  }

  Future<void> _generatePlan() async {
    final provider = context.read<ExerciseProvider>();
    final success = await provider.generatePlanForAnalysis();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'New 4-week exercise plan generated'
              : provider.errorMessage ?? 'Failed to generate plan',
        ),
        backgroundColor: success ? AppTheme.success : AppTheme.destructive,
      ),
    );
    if (success) await _loadProgram();
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentNavIndex: 3,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Exercise Program'),
            actions: [
              IconButton(
                tooltip: 'Generate new plan',
                onPressed: _generatePlan,
                icon: const Icon(Icons.auto_awesome),
              ),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.today), text: 'Today'),
                Tab(icon: Icon(Icons.timeline), text: '4 Weeks'),
              ],
            ),
          ),
          body: Consumer<ExerciseProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading && provider.currentPlan == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.currentPlan == null ||
                  provider.allPlanExercises.isEmpty) {
                return _EmptyPlan(onGenerate: _generatePlan);
              }

              return TabBarView(
                children: [
                  _TodayView(provider: provider, onRefresh: _loadProgram),
                  _TimelineView(provider: provider, onRefresh: _loadProgram),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyPlan extends StatelessWidget {
  final VoidCallback onGenerate;

  const _EmptyPlan({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center,
                size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No active exercise plan',
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Generate a 4-week plan using your saved personal assessment and latest completed image analysis.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onGenerate,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Exercise Plan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayView extends StatelessWidget {
  final ExerciseProvider provider;
  final Future<void> Function() onRefresh;

  const _TodayView({
    required this.provider,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = provider.todaySchedule;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PlanHeader(provider: provider),
          const SizedBox(height: 16),
          if (today == null)
            _RestDayCard(theme: theme)
          else ...[
            Text(
              'Today - ${_formatDate(today.date)}',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...today.exercises.map(
              (exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ExerciseCard(
                  exercise: exercise,
                  onToggle: () => _toggle(context, provider, exercise),
                  onOpen: () => _showExerciseDetails(context, exercise),
                ),
              ),
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _TimelineView extends StatelessWidget {
  final ExerciseProvider provider;
  final Future<void> Function() onRefresh;

  const _TimelineView({
    required this.provider,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = provider.fourWeekTimeline;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        itemCount: days.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return _PlanHeader(provider: provider);
          final day = days[index - 1];
          return Card(
            margin: const EdgeInsets.only(top: 12),
            child: ExpansionTile(
              title: Text(
                'Week ${day.week} - ${_formatDate(day.date)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${day.exercises.length} exercises'),
              children: [
                for (final exercise in day.exercises)
                  ListTile(
                    leading: Icon(
                      exercise.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: exercise.completed
                          ? AppTheme.success
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    title: Text(exercise.name),
                    subtitle: Text('${exercise.reps} • ${exercise.duration}'),
                    onTap: () => _showExerciseDetails(context, exercise),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PlanHeader extends StatelessWidget {
  final ExerciseProvider provider;

  const _PlanHeader({required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plan = provider.currentPlan;
    final total = provider.allPlanExercises.length;
    final completed = provider.completedExercises;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '4-week personalized plan',
            style:
                theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            plan == null
                ? 'Generated from your saved assessment and image analysis.'
                : '${_formatDate(plan.startDate)} to ${_formatDate(plan.endDate)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: total == 0 ? 0 : completed / total),
          const SizedBox(height: 8),
          Text('$completed/$total completed today'),
        ],
      ),
    );
  }
}

class _RestDayCard extends StatelessWidget {
  final ThemeData theme;

  const _RestDayCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(Icons.self_improvement,
                size: 40, color: theme.colorScheme.primary),
            const SizedBox(height: 12),
            Text(
              'No scheduled exercises today',
              style:
                  theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Use the 4 Weeks tab to review the full plan timeline.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final Future<void> Function() onToggle;
  final VoidCallback onOpen;

  const _ExerciseCard({
    required this.exercise,
    required this.onToggle,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onOpen,
        leading: IconButton(
          tooltip: exercise.completed ? 'Mark undone' : 'Mark done',
          icon: Icon(
            exercise.completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: exercise.completed
                ? AppTheme.success
                : theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: onToggle,
        ),
        title: Text(
          exercise.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: exercise.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text('${exercise.reps} • ${exercise.duration}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

Future<void> _toggle(
  BuildContext context,
  ExerciseProvider provider,
  Exercise exercise,
) async {
  final painLevel = context.read<ProfileProvider>().profile.painLevel;
  final wasCompleted = exercise.completed;
  final success = await provider.toggleTodayExercise(
    exercise,
    painLevel: painLevel.clamp(1, 10),
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success
            ? wasCompleted
                ? 'Exercise marked undone'
                : 'Exercise saved for today'
            : provider.errorMessage ?? 'Failed to update exercise',
      ),
      backgroundColor: success ? AppTheme.success : AppTheme.destructive,
    ),
  );
}

void _showExerciseDetails(BuildContext context, Exercise exercise) {
  final theme = Theme.of(context);
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.35,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            exercise.name,
            style:
                theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _DetailChip(Icons.fitness_center, exercise.difficulty),
              _DetailChip(Icons.repeat, exercise.reps),
              _DetailChip(Icons.timer_outlined, exercise.duration),
              if (exercise.restSeconds > 0)
                _DetailChip(Icons.pause, '${exercise.restSeconds}s rest'),
            ],
          ),
          if (exercise.description.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _DetailBlock(title: 'Description', body: exercise.description),
          ],
          const SizedBox(height: 20),
          _DetailBlock(
            title: 'How to perform',
            body: exercise.instructions.trim().isNotEmpty
                ? exercise.instructions
                : 'Perform the movement slowly and with control. Stop if you feel sharp pain and consult a healthcare professional.',
          ),
          if (exercise.targetMuscles.trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _DetailBlock(title: 'Target muscles', body: exercise.targetMuscles),
          ],
          if ((exercise.precautions ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 20),
            _DetailBlock(title: 'Precautions', body: exercise.precautions!),
          ],
        ],
      ),
    ),
  );
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String body;

  const _DetailBlock({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(body),
      ],
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
