import 'package:flutter/material.dart';
import 'dart:io';
import '../models/scan_record.dart';
import '../core/api/api_client.dart';
import '../core/services/imaging_service.dart';
import '../core/models/imaging/image_asset.dart';
import '../core/models/imaging/ai_analysis.dart';
import '../core/api/api_exception.dart';

class ScanProvider extends ChangeNotifier {
  final ImagingService _imagingService = ImagingService(ApiClient());

  final List<ScanRecord> _scans = [];
  final List<AtrRecord> _atrRecords = [];

  bool _isLoading = false;
  bool _isUploading = false;
  bool _isAnalyzing = false;
  String? _errorMessage;

  ImageAsset? _currentImage;
  AIAnalysis? _currentAnalysis;

  List<ScanRecord> get scans => List.unmodifiable(_scans);
  List<AtrRecord> get atrRecords => List.unmodifiable(_atrRecords);
  ScanRecord? get latestScan => _scans.isNotEmpty ? _scans.first : null;
  AtrRecord? get latestAtr => _atrRecords.isNotEmpty ? _atrRecords.first : null;

  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isAnalyzing => _isAnalyzing;
  String? get errorMessage => _errorMessage;
  ImageAsset? get currentImage => _currentImage;
  AIAnalysis? get currentAnalysis => _currentAnalysis;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<ImageAsset?> uploadImage(File imageFile, String bodyView,
      {bool fromCamera = true}) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final imageAsset = await _imagingService.uploadImage(
        imageFile,
        bodyView,
        fromCamera: fromCamera,
      );

      _currentImage = imageAsset;

      // Automatically validate the image
      if (imageAsset.isValid) {
        await triggerAnalysis(imageAsset.imageId);
      }

      return imageAsset;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return null;
    } catch (e) {
      _errorMessage = 'Failed to upload image';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> triggerAnalysis(String imageId) async {
    _isAnalyzing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analysis = await _imagingService.triggerAnalysis(imageId);
      _currentAnalysis = analysis;

      // Poll for completion if status is PENDING or PROCESSING
      if (analysis.status == 'PENDING' || analysis.status == 'PROCESSING') {
        await _pollAnalysisStatus(analysis.analysisId);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to start analysis';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> _pollAnalysisStatus(String analysisId) async {
    int attempts = 0;
    const maxAttempts = 60; // 5 minutes max (5 seconds interval)

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));

      try {
        final analysis = await _imagingService.getAnalysis(analysisId);
        _currentAnalysis = analysis;
        notifyListeners();

        if (analysis.status == 'COMPLETED') {
          // Add to scan history
          if (analysis.severity != null && analysis.curve != null) {
            _scans.insert(
              0,
              ScanRecord(
                id: _scans.length + 1,
                date: analysis.analyzedAt ?? DateTime.now(),
                severity: analysis.severity!.severityLevel,
                curveType: analysis.curve!.curveType,
              ),
            );
          }
          break;
        } else if (analysis.status == 'FAILED') {
          _errorMessage = analysis.errorMessage ?? 'Analysis failed';
          break;
        }
      } catch (e) {
        // Continue polling on error
      }

      attempts++;
    }

    if (attempts >= maxAttempts) {
      _errorMessage = 'Analysis timeout';
    }
  }

  Future<void> loadAnalysisHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analyses = await _imagingService.getAnalysisHistory();

      _scans.clear();
      for (var analysis in analyses) {
        if (analysis.severity != null && analysis.curve != null) {
          _scans.add(
            ScanRecord(
              id: _scans.length + 1,
              date: analysis.analyzedAt ?? DateTime.now(),
              severity: analysis.severity!.severityLevel,
              curveType: analysis.curve!.curveType,
            ),
          );
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load history';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
