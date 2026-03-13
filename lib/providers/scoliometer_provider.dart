import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ScoliometerProvider extends ChangeNotifier {
  double _currentAngle = 0;
  bool _isMeasuring = false;
  bool _calibrated = false;
  double _calibrationOffset = 0;
  String _selectedRegion = 'thoracic';
  String? _sensorError;
  final List<double> _angleHistory = [];
  final List<MeasurementRecord> _savedMeasurements = [];

  StreamSubscription<AccelerometerEvent>? _sensorSubscription;

  double get currentAngle => _currentAngle;
  bool get isMeasuring => _isMeasuring;
  bool get calibrated => _calibrated;
  String get selectedRegion => _selectedRegion;
  String? get sensorError => _sensorError;
  List<MeasurementRecord> get savedMeasurements =>
      List.unmodifiable(_savedMeasurements);

  void setRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  double _smoothAngle(double newAngle) {
    _angleHistory.add(newAngle);
    if (_angleHistory.length > 5) {
      _angleHistory.removeAt(0);
    }

    const weights = [1.0, 2.0, 3.0, 4.0, 5.0];
    double weightedSum = 0;
    double totalWeight = 0;

    for (int i = 0; i < _angleHistory.length; i++) {
      final weight = i < weights.length ? weights[i] : 1.0;
      weightedSum += _angleHistory[i] * weight;
      totalWeight += weight;
    }

    return weightedSum / totalWeight;
  }

  void startMeasuring() {
    _sensorError = null;
    _angleHistory.clear();

    try {
      _sensorSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          // Calculate tilt angle from the accelerometer
          // atan2(x, z) gives the lateral tilt — exactly what a scoliometer measures
          final rawAngle = atan2(event.x, event.z) * 180 / pi;
          final adjusted = rawAngle - _calibrationOffset;
          final smoothed = _smoothAngle(adjusted);
          _currentAngle = smoothed.clamp(-15.0, 15.0);
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
    notifyListeners();
  }

  void calibrate() {
    _calibrationOffset += _currentAngle;
    _currentAngle = 0;
    _angleHistory.clear();
    _calibrated = true;
    notifyListeners();
  }

  void saveMeasurement() {
    _savedMeasurements.insert(
      0,
      MeasurementRecord(
        region: _selectedRegion,
        angle: _currentAngle,
        timestamp: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  ATRClassification getClassification(double angle) {
    final absAngle = angle.abs();
    if (absAngle <= 5) {
      return ATRClassification('Normal', 'No significant asymmetry detected');
    } else if (absAngle <= 7) {
      return ATRClassification(
          'Borderline', 'Minor asymmetry - consider monitoring');
    } else if (absAngle <= 10) {
      return ATRClassification(
          'Mild', 'Possible scoliosis - consult a specialist');
    } else {
      return ATRClassification(
          'Significant', 'Professional evaluation recommended');
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
  final double angle;
  final DateTime timestamp;

  const MeasurementRecord({
    required this.region,
    required this.angle,
    required this.timestamp,
  });
}

class ATRClassification {
  final String label;
  final String description;

  const ATRClassification(this.label, this.description);
}
