import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnalysisResultsScreen extends StatelessWidget {
  const AnalysisResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Spine Visualization
            Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2340) : const Color(0xFFF0ECF5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Simplified spine SVG representation
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: _SpinePainter(
                        color: theme.colorScheme.primary,
                      ),
                      size: const Size(80, 200),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Spine Curvature Analysis',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
              ),
            ),

            // Severity Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('12°',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.success,
                              )),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Mild Scoliosis',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your spine shows a mild curvature that typically requires monitoring and exercise therapy.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Detailed Measurements',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 16),
                      _DetailRow(
                          theme, 'Curve Type', 'Thoracic', Icons.straighten),
                      const SizedBox(height: 12),
                      _DetailRow(
                          theme, 'Cobb Angle', '12°', Icons.architecture),
                      const SizedBox(height: 12),
                      _DetailRow(
                          theme, 'Apex Location', 'T8-T10', Icons.location_on),
                      const SizedBox(height: 12),
                      _DetailRow(theme, 'Rotation', 'Mild clockwise',
                          Icons.rotate_right),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recommendations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb,
                              color: AppTheme.warning, size: 20),
                          const SizedBox(width: 8),
                          Text('Recommendations',
                              style: theme.textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _RecommendationItem(
                        theme,
                        'Regular Exercise',
                        'Follow the personalized exercise program to strengthen your core and improve posture.',
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 12),
                      _RecommendationItem(
                        theme,
                        'Regular Monitoring',
                        'Continue tracking your ATR measurements every 2-4 weeks.',
                        Icons.monitor_heart,
                      ),
                      const SizedBox(height: 12),
                      _RecommendationItem(
                        theme,
                        'Consult a Specialist',
                        'Consider visiting an orthopedic specialist for a comprehensive evaluation.',
                        Icons.medical_services,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  FilledButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/exercises'),
                    icon: const Icon(Icons.fitness_center),
                    label: const Text('View Exercise Program'),
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
          ],
        ),
      ),
    );
  }
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
          child: Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        Text(value,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
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
        color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2D2340) : const Color(0xFFF0ECF5),
        borderRadius: BorderRadius.circular(12),
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
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpinePainter extends CustomPainter {
  final Color color;
  _SpinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;

    // Draw a simplified spine with mild curve
    path.moveTo(w / 2, 0);
    path.cubicTo(w / 2 + 10, h * 0.2, w / 2 + 15, h * 0.4, w / 2 + 5, h * 0.5);
    path.cubicTo(w / 2 - 5, h * 0.6, w / 2 - 10, h * 0.8, w / 2, h);

    canvas.drawPath(path, paint);

    // Draw vertebrae dots
    for (var i = 0; i <= 10; i++) {
      final t = i / 10.0;
      final x = w / 2 + 15 * (0.5 - (t - 0.4).abs()) * 2 * (t < 0.5 ? 1 : -1);
      final y = h * t;
      canvas.drawCircle(Offset(x, y), 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
