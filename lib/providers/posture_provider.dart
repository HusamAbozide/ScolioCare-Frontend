import 'dart:io';
import 'package:flutter/foundation.dart';
import '../core/services/posture_service.dart';
import '../core/api/api_config.dart';
import '../models/posture_photo.dart';

class PostureProvider with ChangeNotifier {
  final PostureService _postureService;

  List<PosturePhoto> _photos = [];
  List<PostureComparison> _comparisons = [];
  bool _isLoading = false;
  String? _error;

  PostureProvider({PostureService? postureService})
      : _postureService = postureService ?? PostureService();

  // Getters
  List<PosturePhoto> get photos => _photos;
  List<PostureComparison> get comparisons => _comparisons;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Upload a new posture photo
  Future<PosturePhoto?> uploadPhoto({
    required File imageFile,
    required String viewAngle,
    required String name,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      PosturePhoto photo;

      if (ApiConfig.useMockMode) {
        // Mock mode - simulate upload
        photo = PosturePhoto(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user1',
          imageUrl: imageFile.path,
          capturedAt: DateTime.now(),
          viewAngle: viewAngle,
          name: name,
          notes: notes,
        );
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Real API call
        photo = await _postureService.uploadPosturePhoto(
          imageFile: imageFile,
          viewAngle: viewAngle,
          name: name,
          notes: notes,
        );
      }

      _photos.insert(0, photo); // Add to beginning of list
      _isLoading = false;
      notifyListeners();
      return photo;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Fetch user's posture photos
  Future<void> fetchUserPhotos(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (ApiConfig.useMockMode) {
        // Mock mode
        _photos = _postureService.getMockPosturePhotos();
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Real API call
        _photos = await _postureService.getUserPosturePhotos(userId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Compare two photos
  Future<PostureComparison?> comparePhotos({
    required String beforePhotoId,
    required String afterPhotoId,
    String? notes,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      PostureComparison comparison;

      if (ApiConfig.useMockMode) {
        // Mock mode
        final beforePhoto = _photos.firstWhere((p) => p.id == beforePhotoId);
        final afterPhoto = _photos.firstWhere((p) => p.id == afterPhotoId);

        comparison = PostureComparison(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: 'user1',
          beforePhoto: beforePhoto,
          afterPhoto: afterPhoto,
          comparisonDate: DateTime.now(),
          improvementScore: 0.72,
          analysisResult: {
            'shoulderAlignment': 'improved',
            'spineAlignment': 'stable',
            'hipLevel': 'improved',
          },
          notes: notes,
        );
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Real API call
        comparison = await _postureService.comparePosturePhotos(
          beforePhotoId: beforePhotoId,
          afterPhotoId: afterPhotoId,
          notes: notes,
        );
      }

      _comparisons.insert(0, comparison);
      _isLoading = false;
      notifyListeners();
      return comparison;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Fetch user's comparisons
  Future<void> fetchUserComparisons(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (ApiConfig.useMockMode) {
        // Mock mode
        _comparisons = _postureService.getMockComparisons();
        await Future.delayed(const Duration(seconds: 1));
      } else {
        // Real API call
        _comparisons = await _postureService.getUserComparisons(userId);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deletePhoto(String photoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!ApiConfig.useMockMode) {
        await _postureService.deletePosturePhoto(photoId);
      }
      _photos.removeWhere((photo) => photo.id == photoId);
      _comparisons.removeWhere((comparison) =>
          comparison.beforePhoto.id == photoId ||
          comparison.afterPhoto.id == photoId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteComparison(String comparisonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (!ApiConfig.useMockMode) {
        await _postureService.deletePostureComparison(comparisonId);
      }
      _comparisons.removeWhere((comparison) => comparison.id == comparisonId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Get photos grouped by view angle
  Map<String, List<PosturePhoto>> getPhotosByViewAngle() {
    final Map<String, List<PosturePhoto>> grouped = {
      'FRONT': [],
      'BACK': [],
      'LEFT': [],
      'RIGHT': [],
    };

    for (var photo in _photos) {
      if (grouped.containsKey(photo.viewAngle)) {
        grouped[photo.viewAngle]!.add(photo);
      }
    }

    return grouped;
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset provider
  void reset() {
    _photos = [];
    _comparisons = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
