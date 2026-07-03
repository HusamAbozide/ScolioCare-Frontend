import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/tracking/progress_tracking.dart';

class TrackingService {
  final ApiClient _apiClient;

  TrackingService(this._apiClient);

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
      ApiConfig.painRecord,
      data: {
        'painLevel': painLevel,
        'area': location,
        'notes': description,
      },
      fromJsonT: (json) =>
          PainLevelTracking.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to record pain');
  }

  Future<ScoliometerReading> recordScoliometer({
    String? progressId,
    required double readingValue,
    String? side,
    String? notes,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return ScoliometerReading(
        readingId: 'mock-scolio-${DateTime.now().millisecondsSinceEpoch}',
        progressId: progressId ?? 'mock-progress',
        readingValue: readingValue,
        unit: 'degrees',
        bodyPositionNotes: notes,
        capturedAt: DateTime.now(),
      );
    }

    final response = await _apiClient.post<ScoliometerReading>(
      ApiConfig.scoliometerRecord,
      data: {
        'angleDegrees': readingValue,
        'side': side,
        'notes': notes,
      },
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
      ApiConfig.postureUpload,
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
      ApiConfig.postureCompare,
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

  Future<List<ProgressTracking>> getProgressHistory(
    String userId, {
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
      ApiConfig.progressByUserId(userId),
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

  Future<Map<String, dynamic>> getProgressSummary(String userId) async {
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

    final response = await _apiClient.get(
      ApiConfig.progressSummary(userId),
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    return {};
  }

  /// Get pain history for user
  Future<List<PainLevelTracking>> getPainHistory(String userId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return List.generate(
        5,
        (index) => PainLevelTracking(
          painTrackingId: 'mock-pain-$index',
          progressId: 'mock-progress-$index',
          painLevel: 5 - index,
          painLocation: 'Lower Back',
          painDescription: 'Mild discomfort',
          recordedAt: DateTime.now().subtract(Duration(days: index * 3)),
        ),
      );
    }

    final response = await _apiClient.get(
      ApiConfig.painHistory(userId),
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) =>
              PainLevelTracking.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get scoliometer history for user
  Future<List<ScoliometerReading>> getScoliometerHistory(String userId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return List.generate(
        5,
        (index) => ScoliometerReading(
          readingId: 'mock-scolio-$index',
          progressId: 'mock-progress-$index',
          readingValue: 5.0 + (index * 0.5),
          unit: 'degrees',
          bodyPositionNotes: 'Forward bend test',
          capturedAt: DateTime.now().subtract(Duration(days: index * 7)),
        ),
      );
    }

    final response = await _apiClient.get(
      ApiConfig.scoliometerHistory(userId),
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) =>
              ScoliometerReading.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get posture photos for user
  Future<List<PosturePhoto>> getPosturePhotos(String userId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return List.generate(
        3,
        (index) => PosturePhoto(
          photoId: 'mock-photo-$index',
          userId: userId,
          photoUrl: '/mock/posture/photo-$index.jpg',
          view: index == 0 ? 'FRONT' : (index == 1 ? 'BACK' : 'SIDE'),
          takenAt: DateTime.now().subtract(Duration(days: index * 30)),
          monthTag: DateTime.now()
              .subtract(Duration(days: index * 30))
              .toIso8601String()
              .substring(0, 7),
          notes: 'Monthly progress photo',
        ),
      );
    }

    final response = await _apiClient.get(
      ApiConfig.postureByUserId(userId),
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => PosturePhoto.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get posture photo comparisons for user
  Future<List<ImageComparison>> getPostureComparisons(String userId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [];
    }

    final response = await _apiClient.get(
      ApiConfig.postureComparisons(userId),
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => ImageComparison.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

}
