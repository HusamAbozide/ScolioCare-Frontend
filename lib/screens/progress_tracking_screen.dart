import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/api/api_client.dart';
import '../core/models/exercise/exercise_response.dart';
import '../core/models/tracking/progress_tracking.dart';
import '../core/services/exercise_service.dart';
import '../core/services/tracking_service.dart';
import '../providers/auth_provider.dart';
import '../screens/posture_tracking_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/mobile_layout.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _handledInitialTab = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_handledInitialTab) return;
    _handledInitialTab = true;
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      final tabIndex = args['tabIndex'];
      if (tabIndex is int && tabIndex >= 0 && tabIndex < _tabController.length) {
        _tabController.index = tabIndex;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentNavIndex: 4,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            title: const Text('Progress Tracking'),
            floating: true,
            pinned: true,
            bottom: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'ATR History'),
                Tab(text: 'Exercises'),
                Tab(text: 'Pain'),
                Tab(text: 'Posture'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [
            _AtrTab(),
            _ExerciseTab(),
            _PainTab(),
            PostureTrackingScreen(embedded: true),
          ],
        ),
      ),
    );
  }
}

class _AtrTab extends StatefulWidget {
  const _AtrTab();

  @override
  State<_AtrTab> createState() => _AtrTabState();
}

class _AtrTabState extends State<_AtrTab> {
  final TrackingService _trackingService = TrackingService(ApiClient());
  List<ScoliometerReading> _readings = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadReadings());
  }

  Future<void> _loadReadings() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null || userId.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final readings = await _trackingService.getScoliometerHistory(userId);
      readings.sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
      if (!mounted) return;
      setState(() {
        _readings = readings;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load ATR history';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final values = _readings.map((r) => r.readingValue).toList();
    final spots = values
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
        .toList();
    final lastAtr = values.isNotEmpty ? values.last : null;
    final bestAtr =
        values.isNotEmpty ? values.reduce((a, b) => a < b ? a : b) : null;
    final avgAtr = values.isNotEmpty
        ? values.reduce((a, b) => a + b) / values.length
        : null;

    return RefreshIndicator(
      onRefresh: _loadReadings,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Text(_error!,
                      style: const TextStyle(color: AppTheme.destructive)),
            ),
          if (_loading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATR Over Time',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: spots.length < 2
                        ? Center(
                            child: Text(
                              'Not enough data yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                horizontalInterval: 5,
                                getDrawingHorizontalLine: (_) => FlLine(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.1),
                                  strokeWidth: 1,
                                ),
                                getDrawingVerticalLine: (_) => FlLine(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.1),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (_, __, ___, ____) =>
                                        FlDotCirclePainter(
                                      radius: 4,
                                      color: theme.colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: Colors.white,
                                    ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary
                                        .withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  theme,
                  label: 'Last ATR',
                  value:
                      lastAtr != null ? '${lastAtr.toStringAsFixed(1)}°' : '--',
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  theme,
                  label: 'Best ATR',
                  value:
                      bestAtr != null ? '${bestAtr.toStringAsFixed(1)}°' : '--',
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  theme,
                  label: 'Avg ATR',
                  value:
                      avgAtr != null ? '${avgAtr.toStringAsFixed(1)}°' : '--',
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.speed),
              title: const Text('Saved ATR readings'),
              subtitle: Text('${_readings.length} measurements recorded'),
              trailing: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadReadings,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _ExerciseTab extends StatefulWidget {
  const _ExerciseTab();

  @override
  State<_ExerciseTab> createState() => _ExerciseTabState();
}

class _ExerciseTabState extends State<_ExerciseTab> {
  final ExerciseService _exerciseService = ExerciseService(ApiClient());
  List<ExerciseLog> _logs = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadLogs());
  }

  Future<void> _loadLogs() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null || userId.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final logs = await _exerciseService.getExerciseLogs(userId, size: 200);
      if (!mounted) return;
      setState(() {
        _logs = logs;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load exercise progress';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weeklyData = _buildWeeklyData(_logs);
    final completedThisWeek =
        weeklyData.fold<int>(0, (sum, day) => sum + day.completed);
    final activeDays = weeklyData.where((day) => day.completed > 0).length;
    final completionRate = weeklyData.isEmpty
        ? 0
        : ((activeDays / weeklyData.length) * 100).round();
    final streak = _calculateCurrentStreak(_logs);

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Text(_error!,
                      style: const TextStyle(color: AppTheme.destructive)),
            ),
          if (_loading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Exercise Completion',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= weeklyData.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    weeklyData[index].day,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: weeklyData.asMap().entries.map((entry) {
                          final day = entry.value;
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: day.completed.toDouble(),
                                color: day.completed > 0
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.outline,
                                width: 20,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6),
                                ),
                                backDrawRodData: BackgroundBarChartRodData(
                                  show: true,
                                  toY: day.total.toDouble(),
                                  color: theme.colorScheme.primary
                                      .withOpacity(0.1),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exercise Stats',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  _StatRow(theme, 'This week', '$completedThisWeek completed'),
                  _StatRow(theme, 'Active days', '$activeDays/7'),
                  _StatRow(theme, 'Weekly consistency', '$completionRate%'),
                  _StatRow(theme, 'Current streak', '$streak days'),
                  _StatRow(theme, 'Total exercises done', '${_logs.length}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  List<_WeekDay> _buildWeeklyData(List<ExerciseLog> logs) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      final count = logs.where((log) {
        final logged = log.completedAt;
        return logged.year == day.year &&
            logged.month == day.month &&
            logged.day == day.day;
      }).length;
      return _WeekDay(labels[index], count, count < 1 ? 1 : count);
    });
  }

  int _calculateCurrentStreak(List<ExerciseLog> logs) {
    if (logs.isEmpty) return 0;
    final days = logs
        .map((log) {
          final date = log.completedAt;
          return DateTime(date.year, date.month, date.day);
        })
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    var cursor = DateTime(today.year, today.month, today.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }

    var streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

class _PainTab extends StatefulWidget {
  const _PainTab();

  @override
  State<_PainTab> createState() => _PainTabState();
}

class _PainTabState extends State<_PainTab> {
  final TrackingService _trackingService = TrackingService(ApiClient());
  List<PainLevelTracking> _records = [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPain());
  }

  Future<void> _loadPain() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null || userId.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final records = await _trackingService.getPainHistory(userId);
      records.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
      if (!mounted) return;
      setState(() {
        _records = records;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load pain progress';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final painData = _records
        .asMap()
        .entries
        .map((entry) =>
            FlSpot(entry.key.toDouble(), entry.value.painLevel.toDouble()))
        .toList();
    final levels = _records.map((record) => record.painLevel).toList();
    final current = levels.isNotEmpty ? levels.last : null;
    final average = levels.isNotEmpty
        ? levels.reduce((a, b) => a + b) / levels.length
        : null;
    final peak =
        levels.isNotEmpty ? levels.reduce((a, b) => a > b ? a : b) : null;

    return RefreshIndicator(
      onRefresh: _loadPain,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child:
                  Text(_error!,
                      style: const TextStyle(color: AppTheme.destructive)),
            ),
          if (_loading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 12),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pain Level Over Time',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: painData.length < 2
                        ? Center(
                            child: Text(
                              'Update pain level from Edit Profile to build history',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : LineChart(
                            LineChartData(
                              minY: 0,
                              maxY: 10,
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: painData,
                                  isCurved: true,
                                  color: AppTheme.destructive,
                                  barWidth: 3,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color:
                                        AppTheme.destructive.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  theme,
                  label: 'Current',
                  value: current != null ? '$current/10' : '--',
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  theme,
                  label: 'Average',
                  value: average != null
                      ? '${average.toStringAsFixed(1)}/10'
                      : '--',
                  color: AppTheme.warning,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  theme,
                  label: 'Peak',
                  value: peak != null ? '$peak/10' : '--',
                  color: AppTheme.destructive,
                ),
              ),
            ],
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;
  final Color color;

  const _StatCard(
    this.theme, {
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;

  const _StatRow(this.theme, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WeekDay {
  final String day;
  final int completed;
  final int total;

  const _WeekDay(this.day, this.completed, this.total);
}
