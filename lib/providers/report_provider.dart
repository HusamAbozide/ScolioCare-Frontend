import 'package:flutter/material.dart';
import '../core/services/report_service.dart';
import '../core/models/report/report.dart';

class ReportProvider extends ChangeNotifier {
  final ReportService _reportService;

  List<Report> _reports = [];
  bool _isLoading = false;
  bool _isGenerating = false;
  String? _error;
  String? _lastGeneratedReportId;

  ReportProvider(this._reportService);

  List<Report> get reports => List.unmodifiable(_reports);
  bool get isLoading => _isLoading;
  bool get isGenerating => _isGenerating;
  String? get error => _error;
  String? get lastGeneratedReportId => _lastGeneratedReportId;

  Future<void> loadReports() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _reports = await _reportService.getReportList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load reports: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Report?> generateReport(String analysisId) async {
    try {
      _isGenerating = true;
      _error = null;
      notifyListeners();

      final report = await _reportService.generateReport(analysisId);

      _lastGeneratedReportId = report.reportId;

      // Add to local list if not already present
      if (!_reports.any((r) => r.reportId == report.reportId)) {
        _reports.insert(0, report);
      }

      _isGenerating = false;
      notifyListeners();

      return report;
    } catch (e) {
      _error = 'Failed to generate report: $e';
      _isGenerating = false;
      notifyListeners();
      return null;
    }
  }

  Future<Report?> getReport(String reportId) async {
    try {
      _error = null;

      final report = await _reportService.getReport(reportId);

      // Update local cache
      final index = _reports.indexWhere((r) => r.reportId == reportId);
      if (index != -1) {
        _reports[index] = report;
      } else {
        _reports.insert(0, report);
      }

      notifyListeners();
      return report;
    } catch (e) {
      _error = 'Failed to get report: $e';
      notifyListeners();
      return null;
    }
  }

  Future<String?> downloadReport(String reportId) async {
    try {
      _error = null;
      notifyListeners();

      final filePath = await _reportService.downloadReport(reportId);

      // Update status in local cache
      final index = _reports.indexWhere((r) => r.reportId == reportId);
      if (index != -1) {
        _reports[index] = Report(
          reportId: _reports[index].reportId,
          analysisId: _reports[index].analysisId,
          generatedAt: _reports[index].generatedAt,
          severityLevel: _reports[index].severityLevel,
          curveType: _reports[index].curveType,
          confidenceScore: _reports[index].confidenceScore,
          summaryJson: _reports[index].summaryJson,
          disclaimerText: _reports[index].disclaimerText,
          reportNotes: _reports[index].reportNotes,
          pdfUrl: _reports[index].pdfUrl,
          status: 'COMPLETED',
        );
      }

      notifyListeners();
      return filePath;
    } catch (e) {
      _error = 'Failed to download report: $e';
      notifyListeners();
      return null;
    }
  }

  Future<String?> checkReportStatus(String reportId) async {
    try {
      final statusData = await _reportService.getReportStatus(reportId);
      final status = statusData['status'] as String;

      // Update local cache
      final index = _reports.indexWhere((r) => r.reportId == reportId);
      if (index != -1) {
        _reports[index] = Report(
          reportId: _reports[index].reportId,
          analysisId: _reports[index].analysisId,
          generatedAt: _reports[index].generatedAt,
          severityLevel: _reports[index].severityLevel,
          curveType: _reports[index].curveType,
          confidenceScore: _reports[index].confidenceScore,
          summaryJson: _reports[index].summaryJson,
          disclaimerText: _reports[index].disclaimerText,
          reportNotes: _reports[index].reportNotes,
          pdfUrl: _reports[index].pdfUrl,
          status: status,
        );
      }

      notifyListeners();
      return status;
    } catch (e) {
      // Silently fail for status checks
      return null;
    }
  }

  /// Polls report status until it's completed or failed (max 30 attempts, 2s intervals)
  Future<bool> waitForReportCompletion(String reportId) async {
    int attempts = 0;
    const maxAttempts = 30;
    const pollInterval = Duration(seconds: 2);

    while (attempts < maxAttempts) {
      final status = await checkReportStatus(reportId);

      if (status == 'COMPLETED') {
        return true;
      } else if (status == 'FAILED') {
        _error = 'Report generation failed';
        notifyListeners();
        return false;
      }

      await Future.delayed(pollInterval);
      attempts++;
    }

    _error = 'Report generation timeout';
    notifyListeners();
    return false;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
