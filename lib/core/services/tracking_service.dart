import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/tracking/progress_tracking.dart';

class TrackingService {
  final ApiClient _apiClient;

  TrackingService(this._apiClient);

  Future<ProgressTracking> createProgress({
    String? planId,
    required DateTime date,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ProgressTracking(
        progressId: 'mock-progress-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'mock-user-123',
        planId: planId,
        trackingDate: date,
        overallProgressPercentage: 75.0,
        source: 'MANUAL',
        createdAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post<ProgressTracking>(
      '/progress/create',
      data: {
        'planId': planId,
        'trackingDate': date.toIso8601String(),
      },
      fromJsonT: (json) =>
          ProgressTracking.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to create progress');
  }

  Future<PainLevelTracking> recordPain({
    required String progressId,
    required int painLevel,
    String? location,
    String? description,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return PainLevelTracking(
        painTrackingId: 'mock-pain-${DateTime.now().millisecondsSinceEpoch}',
        progressId: progressId,
        painLevel: painLevel,
        painLocation: location,
        painDescription: description,
        recordedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post<PainLevelTracking>(
      '/pain/record',
      data: PainLevelTracking(
        painTrackingId: '',
        progressId: progressId,
        painLevel: painLevel,
        painLocation: location,
        painDescription: description,
        recordedAt: DateTime.now(),
      ).toJson(),
      fromJsonT: (json) =>
          PainLevelTracking.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to record pain');
  }

  Future<ScoliometerReading> recordScoliometer({
    required String progressId,
    required double readingValue,
    String? notes,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ScoliometerReading(
        readingId: 'mock-scolio-${DateTime.now().millisecondsSinceEpoch}',
        progressId: progressId,
        readingValue: readingValue,
        unit: 'degrees',
        bodyPositionNotes: notes,
        capturedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post<ScoliometerReading>(
      '/scaliometer/record',
      data: ScoliometerReading(
        readingId: '',
        progressId: progressId,
        readingValue: readingValue,
        unit: 'degrees',
        bodyPositionNotes: notes,
        capturedAt: DateTime.now(),
      ).toJson(),
      fromJsonT: (json) =>
          ScoliometerReading.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to record scoliometer');
  }

  Future<PosturePhoto> uploadPosturePhoto({
    required File photoFile,
    required String view,
    String? notes,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      final now = DateTime.now();
      return PosturePhoto(
        photoId: 'mock-photo-${now.millisecondsSinceEpoch}',
        userId: 'mock-user-123',
        photoUrl: photoFile.path,
        view: view,
        takenAt: now,
        monthTag: '${now.year}-${now.month.toString().padLeft(2, '0')}',
        notes: notes,
      );
    }

    final fileName = photoFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(photoFile.path, filename: fileName),
      'view': view,
      'notes': notes,
    });

    final response = await _apiClient.postMultipart<PosturePhoto>(
      '/posture/upload',
      formData: formData,
      fromJsonT: (json) => PosturePhoto.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to upload posture photo');
  }

  Future<ImageComparison> comparePhotos({
    required String oldPhotoId,
    required String newPhotoId,
    required String progressId,
    String? notes,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ImageComparison(
        comparisonId: 'mock-compare-${DateTime.now().millisecondsSinceEpoch}',
        progressId: progressId,
        oldPhotoId: oldPhotoId,
        newPhotoId: newPhotoId,
        comparisonNotes: notes,
        comparedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post<ImageComparison>(
      '/posture/compare',
      data: {
        'oldPhotoId': oldPhotoId,
        'newPhotoId': newPhotoId,
        'progressId': progressId,
        'comparisonNotes': notes,
      },
      fromJsonT: (json) =>
          ImageComparison.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to compare photos');
  }

  Future<List<ProgressTracking>> getProgressHistory({
    int page = 0,
    int size = 20,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return List.generate(
        5,
        (index) => ProgressTracking(
          progressId: 'mock-progress-$index',
          userId: 'mock-user-123',
          trackingDate: DateTime.now().subtract(Duration(days: index * 7)),
          overallProgressPercentage: 70.0 + (index * 2.5),
          source: 'EXERCISE_PROGRESS',
          createdAt: DateTime.now().subtract(Duration(days: index * 7)),
        ),
      );
    }

    final response = await _apiClient.get(
      '/progress/mock-user-123/history',
      queryParameters: {'page': page, 'size': size},
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map(
              (item) => ProgressTracking.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> getProgressSummary() async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {
        'overallProgress': 75.0,
        'painTrend': 'IMPROVING',
        'exerciseAdherence': 78.5,
        'latestScoliometerReading': 5.2,
        'totalSessions': 24,
        'currentStreak': 7,
      };
    }

    final response = await _apiClient.get('/summary/mock-user-123');

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    return {};
  }
}
