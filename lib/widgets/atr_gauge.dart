import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AtrGauge extends StatelessWidget {
  final double angle;
  final double size;

  const AtrGauge({super.key, required this.angle, this.size = 250});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: size,
      height: size / 2 + 40,
      child: CustomPaint(
        painter: _GaugePainter(
          angle: angle,
          primaryColor: theme.colorScheme.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${angle.toStringAsFixed(1)}°',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: _getColorForAngle(angle),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getLabelForAngle(angle),
              style: TextStyle(
                fontSize: 14,
                color: _getColorForAngle(angle),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForAngle(double a) {
    final abs = a.abs();
    if (abs <= 5) return AppTheme.success;
    if (abs <= 7) return AppTheme.warning;
    if (abs <= 10) return Colors.orange;
    return AppTheme.destructive;
  }

  String _getLabelForAngle(double a) {
    final abs = a.abs();
    if (abs <= 5) return 'Normal';
    if (abs <= 7) return 'Borderline';
    if (abs <= 10) return 'Mild';
    return 'Significant';
  }
}

class _GaugePainter extends CustomPainter {
  final double angle;
  final Color primaryColor;

  _GaugePainter({required this.angle, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 20);
    final radius = size.width / 2 - 20;
    const startAngle = math.pi;
    const sweepAngle = math.pi;
    const strokeWidth = 14.0;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Green zone (-5 to 5 mapped to arc)
    _drawArcSegment(
        canvas, center, radius, strokeWidth, -5, 5, AppTheme.success);
    // Yellow zones
    _drawArcSegment(
        canvas, center, radius, strokeWidth, -7, -5, AppTheme.warning);
    _drawArcSegment(
        canvas, center, radius, strokeWidth, 5, 7, AppTheme.warning);
    // Orange zones
    _drawArcSegment(
        canvas, center, radius, strokeWidth, -10, -7, Colors.orange);
    _drawArcSegment(canvas, center, radius, strokeWidth, 7, 10, Colors.orange);
    // Red zones
    _drawArcSegment(
        canvas, center, radius, strokeWidth, -15, -10, AppTheme.destructive);
    _drawArcSegment(
        canvas, center, radius, strokeWidth, 10, 15, AppTheme.destructive);

    // Needle
    final needleAngle = math.pi + (angle + 15) / 30 * math.pi;
    final needleEnd = Offset(
      center.dx + radius * 0.85 * math.cos(needleAngle),
      center.dy + radius * 0.85 * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);

    // Center dot
    canvas.drawCircle(center, 8, Paint()..color = primaryColor);
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  void _drawArcSegment(Canvas canvas, Offset center, double radius,
      double strokeWidth, double fromDeg, double toDeg, Color color) {
    final start = math.pi + (fromDeg + 15) / 30 * math.pi;
    final sweep = (toDeg - fromDeg) / 30 * math.pi;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.angle != angle;
}
