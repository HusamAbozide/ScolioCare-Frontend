import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/scoliometer_provider.dart';
import '../widgets/mobile_layout.dart';
import '../widgets/atr_gauge.dart';
import '../theme/app_theme.dart';

class ScoliometerScreen extends StatelessWidget {
  const ScoliometerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MobileLayout(
      currentNavIndex: 2,
      child: Consumer<ScoliometerProvider>(
        builder: (context, scolio, _) {
          final classification = scolio.getClassification(scolio.currentAngle);
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Scoliometer'),
                floating: true,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Info card
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
                            Icon(Icons.info_outline,
                                color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Place the phone flat on your back while bending forward to measure the Angle of Trunk Rotation (ATR).',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Gauge
                      AtrGauge(
                        angle: scolio.currentAngle,
                        size: 280,
                      ),
                      const SizedBox(height: 16),

                      // Current reading
                      Text(
                        '${scolio.currentAngle.toStringAsFixed(1)}°',
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _classificationColor(classification.label)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          classification.label,
                          style: TextStyle(
                            color: _classificationColor(classification.label),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: scolio.calibrate,
                              icon: const Icon(Icons.tune),
                              label: const Text('Calibrate'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: scolio.isMeasuring
                                  ? () {
                                      scolio.stopMeasuring();
                                    }
                                  : () {
                                      scolio.startMeasuring();
                                    },
                              icon: Icon(scolio.isMeasuring
                                  ? Icons.stop
                                  : Icons.play_arrow),
                              label:
                                  Text(scolio.isMeasuring ? 'Stop' : 'Measure'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(0, 48),
                                backgroundColor: scolio.isMeasuring
                                    ? AppTheme.destructive
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Save button
                      if (!scolio.isMeasuring && scolio.currentAngle.abs() > 0)
                        FilledButton.icon(
                          onPressed: () {
                            scolio.saveMeasurement();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Measurement saved!'),
                                backgroundColor: AppTheme.success,
                              ),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Save Measurement'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                            backgroundColor: AppTheme.success,
                          ),
                        ),

                      const SizedBox(height: 24),

                      // ATR Scale reference
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ATR Classification Scale',
                                  style: theme.textTheme.titleSmall
                                      ?.copyWith(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              _ScaleRow(
                                  theme, '0° - 5°', 'Normal', AppTheme.success),
                              _ScaleRow(
                                  theme, '5° - 10°', 'Mild', AppTheme.success),
                              _ScaleRow(theme, '10° - 20°', 'Moderate',
                                  AppTheme.warning),
                              _ScaleRow(theme, '> 20°', 'Severe',
                                  AppTheme.destructive),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _classificationColor(String label) {
    switch (label.toLowerCase()) {
      case 'normal':
        return AppTheme.success;
      case 'borderline':
      case 'mild':
        return AppTheme.warning;
      case 'significant':
        return AppTheme.destructive;
      default:
        return Colors.grey;
    }
  }
}

class _ScaleRow extends StatelessWidget {
  final ThemeData theme;
  final String range;
  final String label;
  final Color color;

  const _ScaleRow(this.theme, this.range, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(range, style: theme.textTheme.bodySmall),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
