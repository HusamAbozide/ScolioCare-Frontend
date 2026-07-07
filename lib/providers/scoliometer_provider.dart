import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/api/api_client.dart';
import '../core/services/tracking_service.dart';


enum OrientationStatus { ok, pitchWarning, flatWarning }

enum MeasurementConfidence { high, medium, low }


class BilateralReading {
  final double? leftAngle;
  final double? rightAngle;
  final MeasurementConfidence confidence;

  const BilateralReading({
    this.leftAngle,
    this.rightAngle,
    required this.confidence,
  });

  double? get atr {
    if (leftAngle == null || rightAngle == null) return null;
    return (leftAngle! - rightAngle!).abs();
  }

  bool get isComplete => leftAngle != null && rightAngle != null;
}


class ExamSession {
  final DateTime startedAt;
  final Map<String, BilateralReading> readings = {};

  ExamSession() : startedAt = DateTime.now();

  bool get isComplete =>
      readings.containsKey('thoracic') &&
      readings['thoracic']!.isComplete &&
      readings.containsKey('thoracolumbar') &&
      readings['thoracolumbar']!.isComplete &&
      readings.containsKey('lumbar') &&
      readings['lumbar']!.isComplete;
}

class ScoliometerProvider extends ChangeNotifier {
  final TrackingService _trackingService = TrackingService(ApiClient());

  double _currentAngle = 0;
  bool _isMeasuring = false;
  bool _calibrated = false;

  
  double _calibrationOffset = 0;
  double _calibrationPitch = 0; // pitch correction captured at calibration

  String _selectedRegion = 'thoracic';
  String _selectedSide = 'left'; // 'left' | 'right'
  String? _sensorError;
  String? _captureNotice;
  String? _saveError;
  OrientationStatus _orientationStatus = OrientationStatus.ok;
  double _pitchAngle = 0; 
  double _signalVariance = 0; 
  double _stabilityProgress = 0.0;

  final List<double> _angleHistory = [];
  final List<double> _varianceWindow = [];
  final List<MeasurementRecord> _savedMeasurements = [];
  DateTime? _stableSince;
  double? _stableReferenceAngle;
  bool _autoCapturedInSession = false;

  ExamSession? _currentSession;

  static const int _smoothingWindow = 8;
  static const int _varianceWindowSize = 20;
  static const double _jitterDeadZone = 0.20;
  static const double _baseMaxStepPerSample = 0.70;
  static const double _boostedMaxStepPerSample = 1.40;
  static const double _boostThreshold = 2.0;
  static const double _stableBand = 1.0;
  static const double _minAutoCaptureAngle = 0.0;
  static const Duration _requiredStableDuration = Duration(milliseconds: 1000);

  static const double _maxAllowedPitchDeviation = 12.0;

  static const double _minTiltFromFlat = 15.0;

  static const Map<String, double> _angleClampByRegion = {
    'thoracic': 15.0,
    'thoracolumbar': 18.0,
    'lumbar': 20.0,
    'cervical': 15.0,
  };

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  double get currentAngle => _currentAngle;
  bool get isMeasuring => _isMeasuring;
  bool get calibrated => _calibrated;
  String get selectedRegion => _selectedRegion;
  String get selectedSide => _selectedSide;
  String? get sensorError => _sensorError;
  String? get captureNotice => _captureNotice;
  String? get saveError => _saveError;
  OrientationStatus get orientationStatus => _orientationStatus;
  double get pitchAngle => _pitchAngle;
  double get signalVariance => _signalVariance;
  double get stabilityProgress => _stabilityProgress;
  ExamSession? get currentSession => _currentSession;
  List<MeasurementRecord> get savedMeasurements =>
      List.unmodifiable(_savedMeasurements);

  MeasurementConfidence get currentConfidence {
    if (_signalVariance < 0.10) return MeasurementConfidence.high;
    if (_signalVariance < 0.40) return MeasurementConfidence.medium;
    return MeasurementConfidence.low;
  }

  double get uncertaintyRange {
    switch (currentConfidence) {
      case MeasurementConfidence.high:
        return 0.3;
      case MeasurementConfidence.medium:
        return 0.8;
      case MeasurementConfidence.low:
        return 1.5;
    }
  }

  void consumeCaptureNotice() {
    _captureNotice = null;
  }

  void consumeSaveError() {
    _saveError = null;
  }

  void setRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void setSide(String side) {
    _selectedSide = side;
    notifyListeners();
  }


  void startExamSession() {
    _currentSession = ExamSession();
    notifyListeners();
  }

  void endExamSession() {
    _currentSession = null;
    notifyListeners();
  }


  double _smoothAngle(double newAngle) {
    _angleHistory.add(newAngle);
    if (_angleHistory.length > _smoothingWindow) {
      _angleHistory.removeAt(0);
    }
    double weightedSum = 0;
    double totalWeight = 0;
    for (int i = 0; i < _angleHistory.length; i++) {
      final weight = i + 1.0;
      weightedSum += _angleHistory[i] * weight;
      totalWeight += weight;
    }
    return weightedSum / totalWeight;
  }

  double _stabilizeAngle(double nextAngle) {
    final delta = nextAngle - _currentAngle;
    if (delta.abs() < _jitterDeadZone) return _currentAngle;
    final maxStep = delta.abs() >= _boostThreshold
        ? _boostedMaxStepPerSample
        : _baseMaxStepPerSample;
    final limitedDelta = delta.clamp(-maxStep, maxStep);
    return _currentAngle + limitedDelta;
  }

  void _updateVariance(double angle) {
    _varianceWindow.add(angle);
    if (_varianceWindow.length > _varianceWindowSize) {
      _varianceWindow.removeAt(0);
    }
    if (_varianceWindow.length < 3) return;
    final mean =
        _varianceWindow.reduce((a, b) => a + b) / _varianceWindow.length;
    final variance = _varianceWindow
            .map((v) => (v - mean) * (v - mean))
            .reduce((a, b) => a + b) /
        _varianceWindow.length;
    _signalVariance = variance;
  }

  bool _updateOrientationGuard(double x, double y, double z) {

    _pitchAngle = atan2(x, sqrt(y * y + z * z)) * 180 / pi;

    final correctedPitch = _pitchAngle - _calibrationPitch;

    final tiltFromFlat = atan2(sqrt(x * x + y * y), z.abs()) * 180 / pi;
    if (tiltFromFlat < _minTiltFromFlat) {
      _orientationStatus = OrientationStatus.flatWarning;
      return false;
    }

    if (correctedPitch.abs() > _maxAllowedPitchDeviation) {
      _orientationStatus = OrientationStatus.pitchWarning;
      return false;
    }

    _orientationStatus = OrientationStatus.ok;
    return true;
  }

  bool _checkAndAutoCapture(double angle) {
    if (_autoCapturedInSession) return false;
    if (angle.abs() < _minAutoCaptureAngle) {
      _stableSince = null;
      _stableReferenceAngle = null;
      _stabilityProgress = 0.0;
      return false;
    }

    final now = DateTime.now();
    if (_stableReferenceAngle == null || _stableSince == null) {
      _stableReferenceAngle = angle;
      _stableSince = now;
      _stabilityProgress = 0.05;
      return false;
    }

    if ((angle - _stableReferenceAngle!).abs() <= _stableBand) {
      _stableReferenceAngle = (_stableReferenceAngle! * 0.8) + (angle * 0.2);
      final elapsed = now.difference(_stableSince!);
      _stabilityProgress =
          (elapsed.inMilliseconds / _requiredStableDuration.inMilliseconds)
              .clamp(0.0, 1.0);

      if (elapsed >= _requiredStableDuration) {
        _saveCurrentReading(auto: true);
        _captureNotice =
            'Auto-saved: ${angle.toStringAsFixed(1)}° (${currentConfidence.name}, ±${uncertaintyRange.toStringAsFixed(1)}°)';
        _autoCapturedInSession = true;
        _isMeasuring = false;
        _stabilityProgress = 1.0;
        _sensorSubscription?.cancel();
        _sensorSubscription = null;
        return true;
      }
      return false;
    }

    _stableReferenceAngle = angle;
    _stableSince = now;
    _stabilityProgress = 0.0;
    return false;
  }


  void startMeasuring() {
    _sensorError = null;
    _captureNotice = null;
    _angleHistory.clear();
    _varianceWindow.clear();
    _stableSince = null;
    _stableReferenceAngle = null;
    _autoCapturedInSession = false;
    _signalVariance = 0;
    _stabilityProgress = 0.0;

    try {
      _sensorSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          _updateOrientationGuard(event.x, event.y, event.z);

          final rawAngle = atan2(event.y, event.z) * 180 / pi;
          final adjusted = rawAngle - _calibrationOffset;
          final smoothed = _smoothAngle(adjusted);
          final stabilized = _stabilizeAngle(smoothed);

          final clamp = _angleClampByRegion[_selectedRegion] ?? 15.0;
          _currentAngle = stabilized.clamp(-clamp, clamp);

          _updateVariance(_currentAngle);

          _checkAndAutoCapture(_currentAngle);

          notifyListeners();
        },
        onError: (error) {
          _sensorError = 'Sensor error: $error';
          _isMeasuring = false;
          notifyListeners();
        },
      );
      _isMeasuring = true;
      if (!_calibrated) _calibrated = true;
      notifyListeners();
    } catch (e) {
      _sensorError = 'Could not access device sensors: $e';
      notifyListeners();
    }
  }

  void stopMeasuring() {
    _sensorSubscription?.cancel();
    _sensorSubscription = null;
    _isMeasuring = false;
    _stableSince = null;
    _stableReferenceAngle = null;
    _stabilityProgress = 0.0;
    notifyListeners();
  }

  void calibrate() {
    _calibrationOffset += _currentAngle;
    _calibrationPitch = _pitchAngle; // lock in current pitch as the baseline
    _currentAngle = 0;
    _angleHistory.clear();
    _varianceWindow.clear();
    _calibrated = true;
    notifyListeners();
  }


  void _saveCurrentReading({bool auto = false}) {
    final record = MeasurementRecord(
      region: _selectedRegion,
      side: _selectedSide,
      angle: _currentAngle,
      confidence: currentConfidence,
      uncertaintyRange: uncertaintyRange,
      timestamp: DateTime.now(),
      autoCapture: auto,
    );

    _savedMeasurements.insert(0, record);
    unawaited(_persistReading(record));

    if (_currentSession != null) {
      final existing = _currentSession!.readings[_selectedRegion] ??
          BilateralReading(confidence: currentConfidence);
      final updated = _selectedSide == 'left'
          ? BilateralReading(
              leftAngle: _currentAngle,
              rightAngle: existing.rightAngle,
              confidence: currentConfidence,
            )
          : BilateralReading(
              leftAngle: existing.leftAngle,
              rightAngle: _currentAngle,
              confidence: currentConfidence,
            );
      _currentSession!.readings[_selectedRegion] = updated;
    }
  }

  void saveMeasurement() {
    _saveCurrentReading(auto: false);
    notifyListeners();
  }

  Future<void> _persistReading(MeasurementRecord record) async {
    try {
      _saveError = null;
      await _trackingService.recordScoliometer(
        readingValue: record.angle.abs(),
        side: record.side.toUpperCase(),
        notes:
            '${record.region} ${record.autoCapture ? "auto" : "manual"} capture; confidence=${record.confidence.name}; uncertainty=±${record.uncertaintyRange.toStringAsFixed(1)}°',
      );
    } catch (e) {
      _saveError = 'Saved locally, but backend sync failed: $e';
      notifyListeners();
    }
  }


  ATRClassification getClassification(double angle) {
    final absAngle = angle.abs();
    if (absAngle <= 5) {
      return const ATRClassification(
          'Normal', 'No significant asymmetry detected');
    } else if (absAngle <= 7) {
      return const ATRClassification(
          'Borderline', 'Minor asymmetry — consider monitoring');
    } else if (absAngle <= 10) {
      return const ATRClassification(
          'Positive screen', 'Referral to specialist recommended (ATR ≥ 7°)');
    } else {
      return const ATRClassification(
          'Significant', 'Professional evaluation strongly recommended');
    }
  }

  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}



class MeasurementRecord {
  final String region;
  final String side;
  final double angle;
  final MeasurementConfidence confidence;
  final double uncertaintyRange;
  final DateTime timestamp;
  final bool autoCapture;

  const MeasurementRecord({
    required this.region,
    required this.side,
    required this.angle,
    required this.confidence,
    required this.uncertaintyRange,
    required this.timestamp,
    this.autoCapture = false,
  });
}

class ATRClassification {
  final String label;
  final String description;

  const ATRClassification(this.label, this.description);
}
