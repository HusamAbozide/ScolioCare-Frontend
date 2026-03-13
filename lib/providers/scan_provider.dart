import 'package:flutter/material.dart';
import '../models/scan_record.dart';

class ScanProvider extends ChangeNotifier {
  final List<ScanRecord> _scans = [
    ScanRecord(
        id: 1,
        date: DateTime(2024, 6, 15),
        severity: 'Mild',
        curveType: 'Thoracic'),
    ScanRecord(
        id: 2,
        date: DateTime(2024, 5, 10),
        severity: 'Mild',
        curveType: 'Thoracic'),
    ScanRecord(
        id: 3,
        date: DateTime(2024, 4, 5),
        severity: 'Mild',
        curveType: 'Thoracic'),
    ScanRecord(
        id: 4,
        date: DateTime(2024, 3, 1),
        severity: 'Moderate',
        curveType: 'Thoracic'),
    ScanRecord(
        id: 5,
        date: DateTime(2024, 2, 1),
        severity: 'Moderate',
        curveType: 'Thoracic'),
  ];

  final List<AtrRecord> _atrRecords = [
    AtrRecord(
        id: 1,
        date: DateTime(2024, 6, 15),
        thoracic: 5,
        lumbar: 3,
        thoracicChange: -1,
        lumbarChange: 0),
    AtrRecord(
        id: 2,
        date: DateTime(2024, 5, 10),
        thoracic: 6,
        lumbar: 3,
        thoracicChange: -1,
        lumbarChange: -1),
    AtrRecord(
        id: 3,
        date: DateTime(2024, 4, 5),
        thoracic: 7,
        lumbar: 4,
        thoracicChange: 0,
        lumbarChange: 0),
    AtrRecord(
        id: 4,
        date: DateTime(2024, 3, 1),
        thoracic: 7,
        lumbar: 4,
        thoracicChange: -1,
        lumbarChange: -1),
    AtrRecord(id: 5, date: DateTime(2024, 2, 1), thoracic: 8, lumbar: 5),
  ];

  List<ScanRecord> get scans => List.unmodifiable(_scans);
  List<AtrRecord> get atrRecords => List.unmodifiable(_atrRecords);
  ScanRecord? get latestScan => _scans.isNotEmpty ? _scans.first : null;
  AtrRecord? get latestAtr => _atrRecords.isNotEmpty ? _atrRecords.first : null;

  void addScan(ScanRecord scan) {
    _scans.insert(0, scan);
    notifyListeners();
  }

  void addAtrRecord(AtrRecord record) {
    _atrRecords.insert(0, record);
    notifyListeners();
  }

  String getSeverityForAngle(double angle) {
    final abs = angle.abs();
    if (abs <= 5) return 'Normal';
    if (abs <= 7) return 'Borderline';
    if (abs <= 10) return 'Mild';
    return 'Significant';
  }
}
