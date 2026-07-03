import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/scan_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_fab.dart';

class AnalysisResultsScreen extends StatelessWidget {
  const AnalysisResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysis = context.watch<ScanProvider>().currentAnalysis;
    final severity = analysis?.severity?.severityLevel ?? 'Unavailable';
    final curveType = analysis?.curve?.curveType ?? 'Unavailable';
    final confidence = analysis?.confidenceScore;
    final explanation = _extractExplanation(analysis?.summaryText);
    final analyzedAt = analysis?.analyzedAt ?? analysis?.createdAt;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SummaryCard(
              theme: theme,
              severity: _formatSeverity(severity),
              curveType: _formatEnum(curveType),
              confidence: confidence,
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Key Findings',
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 520;
                  return GridView.count(
                    crossAxisCount: isWide ? 2 : 1,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: isWide ? 3.4 : 4.2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    children: [
                      _MetricTile(
                        theme: theme,
                        icon: Icons.monitor_heart,
                        label: 'Severity',
                        value: _formatSeverity(severity),
                      ),
                      _MetricTile(
                        theme: theme,
                        icon: Icons.straighten,
                        label: 'Curve Type',
                        value: _formatEnum(curveType),
                      ),
                      _MetricTile(
                        theme: theme,
                        icon: Icons.verified,
                        label: 'Confidence',
                        value: confidence != null
                            ? '${(confidence * 100).toStringAsFixed(0)}%'
                            : 'Not provided',
                      ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'AI Explanation',
              child: Text(
                explanation,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Analysis Details',
              child: Column(
                children: [
                  _DetailRow(
                    theme,
                    'Status',
                    _formatEnum(analysis?.status ?? 'Unavailable'),
                    Icons.task_alt,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    theme,
                    'Analyzed At',
                    analyzedAt != null
                        ? _formatDateTime(analyzedAt)
                        : 'Not provided',
                    Icons.schedule,
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    theme,
                    'Analysis ID',
                    analysis?.analysisId ?? 'Not provided',
                    Icons.tag,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Section(
              title: 'Next Steps',
              child: Column(
                children: [
                  _RecommendationItem(
                    theme,
                    'Medical Review',
                    'Review this AI result with a qualified healthcare professional.',
                    Icons.medical_services,
                  ),
                  const SizedBox(height: 12),
                  _RecommendationItem(
                    theme,
                    'Keep Records',
                    'Save this result with your X-ray history for future comparison.',
                    Icons.folder_copy,
                  ),
                  const SizedBox(height: 12),
                  _RecommendationItem(
                    theme,
                    'Supportive Exercise',
                    'Use personalized exercises only as supportive guidance.',
                    Icons.fitness_center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: analysis?.analysisId == null
                  ? null
                  : () async {
                      final exerciseProvider = context.read<ExerciseProvider>();
                      final success = await exerciseProvider
                          .generatePlanForAnalysis(analysis!.analysisId);
                      if (!context.mounted) return;
                      if (success) {
                        Navigator.pushNamed(context, '/exercises');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              exerciseProvider.errorMessage ??
                                  'Failed to generate exercise plan',
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.fitness_center),
              label: const Text('Generate Exercise Program'),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/reports'),
              icon: const Icon(Icons.download),
              label: const Text('Download Report'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: const ChatFab(),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ThemeData theme;
  final String severity;
  final String curveType;
  final double? confidence;

  const _SummaryCard({
    required this.theme,
    required this.severity,
    required this.curveType,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2340)
            : const Color(0xFFF0ECF5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.biotech, color: AppTheme.success),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  severity,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  '$curveType curve'
                  '${confidence != null ? ' • ${(confidence! * 100).toStringAsFixed(0)}% confidence' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.theme,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF241D34)
            : const Color(0xFFF7F5FA),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _extractExplanation(String? summaryText) {
  if (summaryText == null || summaryText.trim().isEmpty) {
    return 'This AI analysis should be reviewed by a healthcare professional.';
  }

  try {
    final decoded = jsonDecode(summaryText);
    if (decoded is Map<String, dynamic>) {
      final interpretation = decoded['interpretation'] as String?;
      if (interpretation != null && interpretation.trim().isNotEmpty) {
        return interpretation;
      }
    }
  } catch (_) {
    // The backend may return plain text or raw model output.
  }

  return summaryText;
}

String _formatEnum(String value) {
  if (value.isEmpty) return 'Unavailable';
  return value
      .split('_')
      .map((part) => part.isEmpty
          ? part
          : '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}')
      .join(' ');
}

String _formatSeverity(String value) {
  final formatted = _formatEnum(value);
  return formatted == 'Normal' || formatted == 'Unavailable'
      ? formatted
      : '$formatted Scoliosis';
}

String _formatDateTime(DateTime value) {
  final date = '${value.year}-${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
  final time = '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
  return '$date $time';
}

class _DetailRow extends StatelessWidget {
  final ThemeData theme;
  final String label;
  final String value;
  final IconData icon;

  const _DetailRow(this.theme, this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: theme.colorScheme.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final ThemeData theme;
  final String title;
  final String description;
  final IconData icon;

  const _RecommendationItem(
      this.theme, this.title, this.description, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2D2340)
            : const Color(0xFFF0ECF5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
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
