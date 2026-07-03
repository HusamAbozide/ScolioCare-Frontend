import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/scoliometer_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/atr_gauge.dart';
import '../widgets/mobile_layout.dart';

class ScoliometerScreen extends StatefulWidget {
  const ScoliometerScreen({super.key});

  @override
  State<ScoliometerScreen> createState() => _ScoliometerScreenState();
}

class _ScoliometerScreenState extends State<ScoliometerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _instructionsExpanded = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileLayout(
      currentNavIndex: 2,
      child: Consumer<ScoliometerProvider>(
        builder: (context, scolio, _) {
          final notice = scolio.captureNotice;
          if (notice != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(notice),
                  backgroundColor: AppTheme.success,
                ),
              );
              scolio.consumeCaptureNotice();
            });
          }

          return OrientationBuilder(
            builder: (context, orientation) {
              if (orientation == Orientation.landscape) {
                return _LandscapeMeasurementView(
                  scolio: scolio,
                  pulseCtrl: _pulseCtrl,
                );
              }

              return _PortraitSetupView(
                scolio: scolio,
                instructionsExpanded: _instructionsExpanded,
                onToggleInstructions: () {
                  setState(() {
                    _instructionsExpanded = !_instructionsExpanded;
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _PortraitSetupView extends StatelessWidget {
  final ScoliometerProvider scolio;
  final bool instructionsExpanded;
  final VoidCallback onToggleInstructions;

  const _PortraitSetupView({
    required this.scolio,
    required this.instructionsExpanded,
    required this.onToggleInstructions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: Row(
            children: [
              Icon(Icons.monitor_heart_outlined, color: AppTheme.primary),
              const SizedBox(width: 8),
              const Text('Scoliometer'),
            ],
          ),
          floating: true,
          snap: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RotatePromptCard(theme: theme),
                const SizedBox(height: 12),
                _InstructionsPanel(
                  expanded: instructionsExpanded,
                  onToggle: onToggleInstructions,
                  theme: theme,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LandscapeMeasurementView extends StatelessWidget {
  final ScoliometerProvider scolio;
  final AnimationController pulseCtrl;

  const _LandscapeMeasurementView({
    required this.scolio,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final classification = scolio.getClassification(scolio.currentAngle);
    final classColor = _classColor(classification.label);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final gaugeSize =
                  (constraints.maxHeight * 0.70).clamp(300.0, 420.0);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AtrGauge(
                            angle: scolio.currentAngle,
                            size: gaugeSize,
                            isActive: scolio.isMeasuring,
                          ),
                          const SizedBox(width: 16),
                          SizedBox(
                            width: 250,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: scolio.calibrate,
                                        icon: const Icon(Icons.tune, size: 18),
                                        label: const Text(
                                          'Calibrate',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: const Size(0, 54),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: FilledButton.icon(
                                        onPressed: scolio.isMeasuring
                                            ? () => scolio.stopMeasuring()
                                            : () => scolio.startMeasuring(),
                                        icon: Icon(
                                          scolio.isMeasuring
                                              ? Icons.stop
                                              : Icons.play_arrow,
                                          size: 20,
                                        ),
                                        label: Text(
                                          scolio.isMeasuring ? 'Stop' : 'Start',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        style: FilledButton.styleFrom(
                                          minimumSize: const Size(0, 54),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          backgroundColor: scolio.isMeasuring
                                              ? AppTheme.destructive
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                OutlinedButton.icon(
                                  onPressed: () => _showGuides(context),
                                  icon:
                                      const Icon(Icons.info_outline, size: 16),
                                  label: const Text(
                                    'Guide',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    minimumSize: const Size(0, 42),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      _AngleReadout(
                        angle: scolio.currentAngle,
                        classification: classification,
                        classColor: classColor,
                        stability: scolio.stabilityProgress,
                        isMeasuring: scolio.isMeasuring,
                        pulseCtrl: pulseCtrl,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scolio.orientationStatus == OrientationStatus.ok
                            ? 'Hold the phone steady. The circle fills and auto-saves when stable.'
                            : 'Adjust the phone orientation before capturing.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showGuides(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Measurement Guide'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Placement Guide',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Place the phone across the back with both thumbs supporting it underneath. Keep it level and centered over the spine.',
              ),
              const SizedBox(height: 10),
              const _ThumbDiagram(),
              const SizedBox(height: 14),
              Text(
                'Measurement Guide',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Rotate the phone clockwise and anticlockwise until the reading stabilizes. Use the Calibrate button first if needed, then start measurement.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      );
    },
  );
}

class _AngleReadout extends StatelessWidget {
  final double angle;
  final ATRClassification classification;
  final Color classColor;
  final double stability;
  final bool isMeasuring;
  final AnimationController pulseCtrl;

  const _AngleReadout({
    required this.angle,
    required this.classification,
    required this.classColor,
    required this.stability,
    required this.isMeasuring,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 64,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (isMeasuring)
            SizedBox(
              width: 44,
              height: 44,
              child: AnimatedBuilder(
                animation: pulseCtrl,
                builder: (context, _) {
                  final progress =
                      stability > 0.05 ? stability.clamp(0.0, 1.0) : null;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 4,
                        backgroundColor: classColor.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(classColor),
                      ),
                      if (stability >= 1)
                        Icon(Icons.check, color: classColor, size: 20)
                      else
                        Text(
                          '${(stability * 100).clamp(0, 99).toStringAsFixed(0)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: classColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  );
                },
              ),
            )
          else
            const SizedBox(width: 44),
          const SizedBox(width: 8),
          Text(
            '${angle.toStringAsFixed(1)}°',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: classColor,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: classColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: classColor.withOpacity(0.35)),
            ),
            child: Text(
              classification.label,
              style: TextStyle(
                color: classColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbDiagram extends StatelessWidget {
  const _ThumbDiagram();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final border = isDark ? const Color(0xFF44395C) : const Color(0xFFBBB4CC);
    final bg = isDark ? const Color(0xFF1F1A2E) : const Color(0xFFECEAF0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thumb Placement',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 6),
          Center(child: _PhoneBottomView(isDark: isDark)),
          const SizedBox(height: 6),
          _DiagramStep(
            icon: Icons.looks_one_rounded,
            color: AppTheme.primary,
            text: 'Thumbs flat under the phone, one on each side',
          ),
          const SizedBox(height: 2),
          _DiagramStep(
            icon: Icons.looks_two_rounded,
            color: AppTheme.primary,
            text: 'Let the phone rest on the spine with a stable base',
          ),
          const SizedBox(height: 2),
          _DiagramStep(
            icon: Icons.looks_3_rounded,
            color: AppTheme.primary,
            text: 'Rotate clockwise and anticlockwise across the back',
          ),
        ],
      ),
    );
  }
}

class _PhoneBottomView extends StatelessWidget {
  final bool isDark;
  const _PhoneBottomView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      height: 48,
      child: CustomPaint(painter: _PhoneBottomPainter(isDark: isDark)),
    );
  }
}

class _PhoneBottomPainter extends CustomPainter {
  final bool isDark;
  const _PhoneBottomPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final phonePaint = Paint()
      ..color = isDark ? const Color(0xFF2D2048) : const Color(0xFFD4CFDF);
    final phoneBorder = Paint()
      ..color = isDark ? const Color(0xFF6B5C8A) : const Color(0xFF9980B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final thumbPaint = Paint()
      ..color = isDark ? const Color(0xFF4A3968) : const Color(0xFFE8DFF5);
    final thumbBorder = Paint()
      ..color = AppTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final spinePath = Paint()
      ..color = AppTheme.primary.withOpacity(0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final phoneRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(w * 0.2, 2, w * 0.6, h * 0.48),
      topLeft: const Radius.circular(4),
      topRight: const Radius.circular(4),
      bottomLeft: const Radius.circular(10),
      bottomRight: const Radius.circular(10),
    );
    canvas.drawRRect(phoneRect, phonePaint);
    canvas.drawRRect(phoneRect, phoneBorder);

    final leftThumb = Path()
      ..moveTo(w * 0.04, h * 0.42)
      ..quadraticBezierTo(w * 0.02, h * 0.88, w * 0.22, h * 0.92)
      ..quadraticBezierTo(w * 0.32, h * 0.90, w * 0.26, h * 0.50)
      ..close();
    canvas.drawPath(leftThumb, thumbPaint);
    canvas.drawPath(leftThumb, thumbBorder);

    final rightThumb = Path()
      ..moveTo(w * 0.96, h * 0.42)
      ..quadraticBezierTo(w * 0.98, h * 0.88, w * 0.78, h * 0.92)
      ..quadraticBezierTo(w * 0.68, h * 0.90, w * 0.74, h * 0.50)
      ..close();
    canvas.drawPath(rightThumb, thumbPaint);
    canvas.drawPath(rightThumb, thumbBorder);

    canvas.drawCircle(
      Offset(w / 2, h * 0.76),
      4,
      Paint()..color = AppTheme.primary.withOpacity(0.6),
    );
    for (int i = 0; i < 3; i++) {
      canvas.drawLine(
        Offset(w / 2, h * 0.56 + i * 7),
        Offset(w / 2, h * 0.61 + i * 7),
        spinePath,
      );
    }

    final arrowPaint = Paint()
      ..color = AppTheme.primary.withOpacity(0.5)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.13, h * 0.66), Offset(w * 0.22, h * 0.66), arrowPaint);
    canvas.drawLine(
        Offset(w * 0.78, h * 0.66), Offset(w * 0.87, h * 0.66), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant _PhoneBottomPainter old) => old.isDark != isDark;
}

class _DiagramStep extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _DiagramStep(
      {required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ],
    );
  }
}

class _CompactRegionSide extends StatelessWidget {
  final ScoliometerProvider scolio;
  final ThemeData theme;

  const _CompactRegionSide({required this.scolio, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('REGION',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 4),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CompactChip(
                label: 'Thoracic',
                selected: scolio.selectedRegion == 'thoracic',
                onTap: () => scolio.setRegion('thoracic'),
              ),
              const SizedBox(width: 6),
              _CompactChip(
                label: 'Thoracolumbar',
                selected: scolio.selectedRegion == 'thoracolumbar',
                onTap: () => scolio.setRegion('thoracolumbar'),
              ),
              const SizedBox(width: 6),
              _CompactChip(
                label: 'Lumbar',
                selected: scolio.selectedRegion == 'lumbar',
                onTap: () => scolio.setRegion('lumbar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text('SIDE',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 1,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 4),
        Row(
          children: [
            _CompactChip(
              label: 'Left',
              selected: scolio.selectedSide == 'left',
              onTap: () => scolio.setSide('left'),
            ),
            const SizedBox(width: 6),
            _CompactChip(
              label: 'Right',
              selected: scolio.selectedSide == 'right',
              onTap: () => scolio.setSide('right'),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompactChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CompactChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary
              : theme.colorScheme.outline.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final ScoliometerProvider scolio;
  final Color classColor;

  const _ActionButtons({required this.scolio, required this.classColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scolio.sensorError != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppTheme.destructive.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              scolio.sensorError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.destructive,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: scolio.calibrate,
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Calibrate', style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 42),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: scolio.isMeasuring
                    ? () {
                        scolio.stopMeasuring();
                      }
                    : () {
                        scolio.startMeasuring();
                      },
                icon: Icon(scolio.isMeasuring ? Icons.stop : Icons.play_arrow,
                    size: 16),
                label: Text(
                  scolio.isMeasuring ? 'Stop' : 'Measure',
                  style: const TextStyle(fontSize: 13),
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  backgroundColor:
                      scolio.isMeasuring ? AppTheme.destructive : null,
                ),
              ),
            ),
          ],
        ),
        if (!scolio.isMeasuring && scolio.currentAngle.abs() >= 0.5) ...[
          const SizedBox(height: 6),
          FilledButton.icon(
            onPressed: scolio.saveMeasurement,
            icon: const Icon(Icons.save_alt, size: 16),
            label: const Text('Save', style: TextStyle(fontSize: 13)),
            style: FilledButton.styleFrom(
              backgroundColor: classColor,
              minimumSize: const Size(double.infinity, 42),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ],
    );
  }
}

class _OrientationBanner extends StatelessWidget {
  final OrientationStatus status;
  const _OrientationBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final msg = status == OrientationStatus.pitchWarning
        ? 'Tilt the phone more upright — don\'t tip forward or back'
        : 'Phone is too flat — hold it more vertically';
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.warning.withOpacity(0.5)),
      ),
      child: Text(msg,
          style: const TextStyle(
              color: AppTheme.warning,
              fontSize: 11,
              fontWeight: FontWeight.w500),
          textAlign: TextAlign.center),
    );
  }
}

class _RotatePromptCard extends StatelessWidget {
  final ThemeData theme;
  const _RotatePromptCard({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primary.withOpacity(0.1),
          AppTheme.secondary.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.screen_rotation, color: AppTheme.primary, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rotate to landscape',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Hold the phone horizontally. Measure while rotating clockwise and anticlockwise over the spine.',
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

class _InstructionsPanel extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final ThemeData theme;

  const _InstructionsPanel({
    required this.expanded,
    required this.onToggle,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.menu_book_outlined, color: AppTheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'How to measure',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: const [
                  _InstructionStep(
                    number: '1',
                    title: 'Set the phone horizontally',
                    body:
                        'Keep the device in landscape with the screen facing up.',
                  ),
                  _InstructionStep(
                    number: '2',
                    title: 'Place over the spine',
                    body:
                        'Rest the phone on the patient while keeping both thumbs aligned underneath.',
                  ),
                  _InstructionStep(
                    number: '3',
                    title: 'Rotate slowly',
                    body:
                        'Sweep clockwise and anticlockwise until the reading stabilizes and auto-saves.',
                    last: true,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  final String number;
  final String title;
  final String body;
  final bool last;

  const _InstructionStep({
    required this.number,
    required this.title,
    required this.body,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
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

Color _classColor(String label) {
  switch (label.toLowerCase()) {
    case 'normal':
      return AppTheme.success;
    case 'borderline':
      return AppTheme.warning;
    case 'positive screen':
      return Colors.orange;
    case 'significant':
      return AppTheme.destructive;
    default:
      return Colors.grey;
  }
}
