import 'dart:io';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../../models/posture_photo.dart';

class PostureService {
  final ApiClient _apiClient;

  PostureService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Upload a posture photo
  /// Note: For multipart uploads, use the imaging service pattern or extend ApiClient
  Future<PosturePhoto> uploadPosturePhoto({
    required File imageFile,
    required String viewAngle,
    String? notes,
  }) async {
    // For now, this would need backend implementation
    // In a real scenario, you'd use multipart/form-data upload
    throw UnimplementedError(
        'Multipart upload requires additional ApiClient support');
  }

  /// Get all posture photos for a user
  Future<List<PosturePhoto>> getUserPosturePhotos(String userId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.postureByUserId(userId),
        fromJsonT: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) => PosturePhoto.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to fetch posture photos');
      }
    } catch (e) {
      throw Exception('Error fetching posture photos: $e');
    }
  }

  /// Compare two posture photos
  Future<PostureComparison> comparePosturePhotos({
    required String beforePhotoId,
    required String afterPhotoId,
    String? notes,
  }) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        ApiConfig.postureCompare,
        data: {
          'beforePhotoId': beforePhotoId,
          'afterPhotoId': afterPhotoId,
          if (notes != null) 'notes': notes,
        },
        fromJsonT: (json) => json as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        return PostureComparison.fromJson(response.data!);
      } else {
        throw Exception(response.message ?? 'Failed to compare posture photos');
      }
    } catch (e) {
      throw Exception('Error comparing posture photos: $e');
    }
  }

  /// Get all comparisons for a user
  Future<List<PostureComparison>> getUserComparisons(String userId) async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        ApiConfig.postureComparisons(userId),
        fromJsonT: (json) => json as List<dynamic>,
      );

      if (response.success && response.data != null) {
        return response.data!
            .map((json) =>
                PostureComparison.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(response.message ?? 'Failed to fetch comparisons');
      }
    } catch (e) {
      throw Exception('Error fetching comparisons: $e');
    }
  }

  /// Get mock posture photos for development/testing
  List<PosturePhoto> getMockPosturePhotos() {
    return [
      PosturePhoto(
        id: '1',
        userId: 'user1',
        imageUrl: 'https://via.placeholder.com/400x600',
        capturedAt: DateTime.now().subtract(const Duration(days: 30)),
        viewAngle: 'FRONT',
        notes: 'Initial posture photo',
      ),
      PosturePhoto(
        id: '2',
        userId: 'user1',
        imageUrl: 'https://via.placeholder.com/400x600',
        capturedAt: DateTime.now().subtract(const Duration(days: 20)),
        viewAngle: 'BACK',
        notes: 'Back view for comparison',
      ),
      PosturePhoto(
        id: '3',
        userId: 'user1',
        imageUrl: 'https://via.placeholder.com/400x600',
        capturedAt: DateTime.now().subtract(const Duration(days: 7)),
        viewAngle: 'LEFT',
        notes: 'Left side profile',
      ),
      PosturePhoto(
        id: '4',
        userId: 'user1',
        imageUrl: 'https://via.placeholder.com/400x600',
        capturedAt: DateTime.now(),
        viewAngle: 'FRONT',
        notes: 'Latest posture photo',
      ),
    ];
  }

  /// Get mock comparisons for development/testing
  List<PostureComparison> getMockComparisons() {
    final mockPhotos = getMockPosturePhotos();
    return [
      PostureComparison(
        id: 'comp1',
        userId: 'user1',
        beforePhoto: mockPhotos[0],
        afterPhoto: mockPhotos[3],
        comparisonDate: DateTime.now(),
        improvementScore: 0.75,
        analysisResult: {
          'shoulderAlignment': 'improved',
          'spineAlignment': 'improved',
          'hipLevel': 'stable',
        },
        notes: '30-day progress - significant improvement',
      ),
    ];
  }
}
