import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ---------------------------------------------------------------------------
// AtrGauge — visually mimics a Bunnell scoliometer:
//   • Rectangular body with rounded bottom "saddle" edge
//   • Dual-color inclinometer arc with degree markings
//   • Central weighted bubble / pendulum needle that swings freely
//   • Tick marks at every 1° and labels at every 5°
//   • Left/right asymmetry highlight bands
// ---------------------------------------------------------------------------
class AtrGauge extends StatelessWidget {
  final double angle;
  final double size;
  final bool isActive;

  const AtrGauge({
    super.key,
    required this.angle,
    this.size = 300,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size * 0.72,
      child: CustomPaint(
        painter: _BunnellPainter(
          angle: angle,
          isDark: isDark,
          isActive: isActive,
          primaryColor: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _BunnellPainter extends CustomPainter {
  final double angle;
  final bool isDark;
  final bool isActive;
  final Color primaryColor;

  static const double _rangeMax = 15.0;
  static const double _totalDeg = 30.0;

  _BunnellPainter({
    required this.angle,
    required this.isDark,
    required this.isActive,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyColor =
        isDark ? const Color(0xFF1F1A2E) : const Color(0xFFECEAF0);
    final borderColor =
        isDark ? const Color(0xFF44395C) : const Color(0xFFBBB4CC);

    final bodyRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, h * 0.88),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
      bottomLeft: const Radius.circular(32),
      bottomRight: const Radius.circular(32),
    );

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(isDark ? 0.4 : 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(bodyRect.shift(const Offset(0, 4)), shadowPaint);

    canvas.drawRRect(bodyRect, Paint()..color = bodyColor);
    canvas.drawRRect(
      bodyRect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final brandRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(0, 0, w, h * 0.12),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    );
    canvas.drawRRect(
      brandRect,
      Paint()..color = primaryColor.withOpacity(isDark ? 0.9 : 0.85),
    );

    _drawText(
      canvas,
      'ScolioMetric™',
      Offset(w / 2, h * 0.06),
      fontSize: 9,
      color: Colors.white,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
    );

    final arcCenter = Offset(w / 2, h * 0.88);
    final arcRadius = w * 0.38;
    const arcStart = math.pi;
    const arcSweep = math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcRadius),
      arcStart,
      arcSweep,
      false,
      Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.07)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 28
        ..strokeCap = StrokeCap.butt,
    );

    _drawBand(canvas, arcCenter, arcRadius, -15, -10, AppTheme.destructive, 26);
    _drawBand(canvas, arcCenter, arcRadius, -10, -7, Colors.orange, 26);
    _drawBand(canvas, arcCenter, arcRadius, -7, -5, AppTheme.warning, 26);
    _drawBand(canvas, arcCenter, arcRadius, -5, 5, AppTheme.success, 26);
    _drawBand(canvas, arcCenter, arcRadius, 5, 7, AppTheme.warning, 26);
    _drawBand(canvas, arcCenter, arcRadius, 7, 10, Colors.orange, 26);
    _drawBand(canvas, arcCenter, arcRadius, 10, 15, AppTheme.destructive, 26);

    canvas.drawArc(
      Rect.fromCircle(center: arcCenter, radius: arcRadius - 14),
      arcStart,
      arcSweep,
      false,
      Paint()
        ..color = bodyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    for (int deg = -15; deg <= 15; deg++) {
      final isMajor = deg % 5 == 0;
      final isZero = deg == 0;
      final radAngle = _degToArcRad(deg.toDouble());

      final innerR = arcRadius - 14;
      final outerR = arcRadius +
          (isZero
              ? 18
              : isMajor
                  ? 14
                  : 7);

      final p1 = Offset(
        arcCenter.dx + innerR * math.cos(radAngle),
        arcCenter.dy + innerR * math.sin(radAngle),
      );
      final p2 = Offset(
        arcCenter.dx + outerR * math.cos(radAngle),
        arcCenter.dy + outerR * math.sin(radAngle),
      );

      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = isZero
              ? (isDark ? Colors.white : Colors.black87)
              : (isDark ? Colors.white54 : Colors.black54)
          ..strokeWidth = isZero
              ? 2.0
              : isMajor
                  ? 1.5
                  : 0.8
          ..strokeCap = StrokeCap.round,
      );

      if (isMajor) {
        final labelR = arcRadius + (isZero ? 28 : 26);
        final labelPos = Offset(
          arcCenter.dx + labelR * math.cos(radAngle),
          arcCenter.dy + labelR * math.sin(radAngle),
        );
        final label = deg == 0 ? '0' : '${deg.abs()}';
        _drawText(
          canvas,
          label,
          labelPos,
          fontSize: isZero ? 10 : 8,
          color: isZero
              ? (isDark ? Colors.white : Colors.black87)
              : (isDark ? Colors.white60 : Colors.black54),
          fontWeight: isZero ? FontWeight.bold : FontWeight.normal,
        );
      }
    }

    _drawText(
      canvas,
      'L',
      Offset(w * 0.06, h * 0.72),
      fontSize: 11,
      color: AppTheme.destructive,
      fontWeight: FontWeight.bold,
    );
    _drawText(
      canvas,
      'R',
      Offset(w * 0.94, h * 0.72),
      fontSize: 11,
      color: AppTheme.destructive,
      fontWeight: FontWeight.bold,
    );

    final clampedAngle = angle.clamp(-14.0, 14.0);
    final needleRadAngle = _degToArcRad(clampedAngle);

    final needlePivot = arcCenter;
    final needleTip = Offset(
      needlePivot.dx + (arcRadius - 18) * math.cos(needleRadAngle),
      needlePivot.dy + (arcRadius - 18) * math.sin(needleRadAngle),
    );

    canvas.drawLine(
      needlePivot.translate(1, 1),
      needleTip.translate(1, 1),
      Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      needlePivot,
      needleTip,
      Paint()
        ..color = _colorForAngle(angle)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(needlePivot, 7,
        Paint()..color = isDark ? const Color(0xFF2D2048) : Colors.white);
    canvas.drawCircle(
        needlePivot,
        7,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5);
    canvas.drawCircle(needlePivot, 4, Paint()..color = _colorForAngle(angle));
    canvas.drawCircle(needlePivot, 2, Paint()..color = Colors.white);

    final bubbleWindowRect = RRect.fromRectAndCorners(
      Rect.fromCenter(center: Offset(w / 2, h * 0.22), width: 44, height: 14),
      topLeft: const Radius.circular(7),
      topRight: const Radius.circular(7),
      bottomLeft: const Radius.circular(7),
      bottomRight: const Radius.circular(7),
    );

    canvas.drawRRect(
      bubbleWindowRect,
      Paint()..color = (isDark ? Colors.black : const Color(0xFFD6E8D6)),
    );
    canvas.drawRRect(
      bubbleWindowRect,
      Paint()
        ..color = AppTheme.success.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    final bubbleOffset = (angle.clamp(-6.0, 6.0) / 6.0) * 12.0;
    canvas.drawCircle(
      Offset(w / 2 + bubbleOffset, h * 0.22),
      4,
      Paint()..color = AppTheme.success.withOpacity(isActive ? 0.95 : 0.5),
    );

    _drawText(
      canvas,
      'LEVEL',
      Offset(w / 2, h * 0.30),
      fontSize: 6.5,
      color: isDark ? Colors.white38 : Colors.black38,
      letterSpacing: 1.2,
    );

    final zeroRad = _degToArcRad(0);
    canvas.drawLine(
      Offset(arcCenter.dx + (arcRadius - 28) * math.cos(zeroRad),
          arcCenter.dy + (arcRadius - 28) * math.sin(zeroRad)),
      Offset(arcCenter.dx + (arcRadius + 4) * math.cos(zeroRad),
          arcCenter.dy + (arcRadius + 4) * math.sin(zeroRad)),
      Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.35)
        ..strokeWidth = 1.0,
    );

    final saddlePaint = Paint()
      ..color = primaryColor.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final saddlePath = Path()
      ..moveTo(w * 0.05, h * 0.88)
      ..quadraticBezierTo(w / 2, h * 1.02, w * 0.95, h * 0.88);
    canvas.drawPath(saddlePath, saddlePaint);
  }

  double _degToArcRad(double deg) {
    final t = (deg + _rangeMax) / _totalDeg;
    return math.pi + t * math.pi;
  }

  void _drawBand(Canvas canvas, Offset center, double radius, double fromDeg,
      double toDeg, Color color, double trackWidth) {
    final start = _degToArcRad(fromDeg);
    final sweep = (toDeg - fromDeg) / _totalDeg * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackWidth.toDouble()
        ..strokeCap = StrokeCap.butt,
    );
  }

  Color _colorForAngle(double a) {
    final abs = a.abs();
    if (abs <= 5) return AppTheme.success;
    if (abs <= 7) return AppTheme.warning;
    if (abs <= 10) return Colors.orange;
    return AppTheme.destructive;
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 10,
    Color color = Colors.white,
    FontWeight fontWeight = FontWeight.normal,
    double letterSpacing = 0,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BunnellPainter old) =>
      old.angle != angle || old.isActive != isActive || old.isDark != isDark;
}
