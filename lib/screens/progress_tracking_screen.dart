import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../widgets/mobile_layout.dart';
import '../theme/app_theme.dart';

class ProgressTrackingScreen extends StatefulWidget {
  const ProgressTrackingScreen({super.key});

  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
              tabs: const [
                Tab(text: 'ATR History'),
                Tab(text: 'Exercises'),
                Tab(text: 'Pain'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _AtrTab(),
            _ExerciseTab(),
            _PainTab(),
          ],
        ),
      ),
    );
  }
}

class _AtrTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scans = context.watch<ScanProvider>();

    final atrData = scans.atrRecords;
    final spots = atrData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.thoracic);
    }).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Chart card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ATR Over Time',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: spots.length < 2
                      ? Center(
                          child: Text('Not enough data yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant)))
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

        // Achievements
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Achievements',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Achievement('🎯', 'First Scan', true, theme),
                    _Achievement('📈', '5 Readings', true, theme),
                    _Achievement('🏆', '30 Day Streak', false, theme),
                    _Achievement('⭐', 'Improvement', false, theme),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Stats summary
        Row(
          children: [
            Expanded(
              child: _StatCard(
                theme,
                label: 'Last ATR',
                value: atrData.isNotEmpty
                    ? '${atrData.last.thoracic.toStringAsFixed(1)}°'
                    : '--',
                color: AppTheme.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                theme,
                label: 'Best ATR',
                value: atrData.isNotEmpty
                    ? '${atrData.map((r) => r.thoracic).reduce((a, b) => a < b ? a : b).toStringAsFixed(1)}°'
                    : '--',
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                theme,
                label: 'Avg ATR',
                value: atrData.isNotEmpty
                    ? '${(atrData.map((r) => r.thoracic).reduce((a, b) => a + b) / atrData.length).toStringAsFixed(1)}°'
                    : '--',
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ExerciseTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Simulated weekly data
    final weeklyData = [
      _WeekDay('Mon', 4, 5),
      _WeekDay('Tue', 5, 5),
      _WeekDay('Wed', 3, 5),
      _WeekDay('Thu', 5, 5),
      _WeekDay('Fri', 2, 5),
      _WeekDay('Sat', 0, 5),
      _WeekDay('Sun', 0, 5),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weekly Exercise Completion',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${weeklyData[group.x.toInt()].completed}/${weeklyData[group.x.toInt()].total}',
                              TextStyle(color: theme.colorScheme.onSurface),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  weeklyData[value.toInt()].day,
                                  style: theme.textTheme.bodySmall,
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: weeklyData.asMap().entries.map((e) {
                        final i = e.key;
                        final d = e.value;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: d.completed.toDouble(),
                              color: theme.colorScheme.primary,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: d.total.toDouble(),
                                color:
                                    theme.colorScheme.primary.withOpacity(0.1),
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
                Text('Exercise Stats',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                _StatRow(theme, 'This week', '19/35'),
                _StatRow(theme, 'Completion rate', '54%'),
                _StatRow(theme, 'Current streak', '7 days'),
                _StatRow(theme, 'Total exercises done', '156'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _PainTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final painData = [
      FlSpot(0, 6),
      FlSpot(1, 5),
      FlSpot(2, 7),
      FlSpot(3, 4),
      FlSpot(4, 3),
      FlSpot(5, 4),
      FlSpot(6, 3),
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pain Level Over Time',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: 10,
                      gridData: FlGridData(
                        horizontalInterval: 2,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (_) => FlLine(
                          color: theme.colorScheme.onSurface.withOpacity(0.1),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: const FlTitlesData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: painData,
                          isCurved: true,
                          color: AppTheme.destructive,
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) =>
                                FlDotCirclePainter(
                              radius: 4,
                              color: AppTheme.destructive,
                              strokeWidth: 2,
                              strokeColor: Colors.white,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.destructive.withOpacity(0.1),
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
              child: _StatCard(theme,
                  label: 'Current', value: '3/10', color: AppTheme.success),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(theme,
                  label: 'Average', value: '4.6/10', color: AppTheme.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(theme,
                  label: 'Peak', value: '7/10', color: AppTheme.destructive),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _Achievement extends StatelessWidget {
  final String emoji;
  final String label;
  final bool unlocked;
  final ThemeData theme;

  const _Achievement(this.emoji, this.label, this.unlocked, this.theme);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: unlocked
                ? theme.colorScheme.primary.withOpacity(0.1)
                : theme.colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(
                fontSize: 24,
                color: unlocked ? null : Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: unlocked
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;
  final Color color;

  const _StatCard(this.theme,
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold, color: color)),
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

class _WeekDay {
  final String day;
  final int completed;
  final int total;
  const _WeekDay(this.day, this.completed, this.total);
}
