import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/imaging/image_asset.dart';
import '../models/imaging/ai_analysis.dart';

class ImagingService {
  final ApiClient _apiClient;

  ImagingService(this._apiClient);

  Future<ImageAsset> uploadImage(File imageFile, String bodyView,
      {bool fromCamera = true}) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
      'bodyView': bodyView,
      if (!fromCamera) 'captureMethod': 'GALLERY',
    });

    final endpoint =
        fromCamera ? ApiConfig.imagingCapture : ApiConfig.imagingUpload;

    final response = await _apiClient.postMultipart<ImageAsset>(
      endpoint,
      formData: formData,
      fromJsonT: (json) => ImageAsset.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to upload image');
  }

  Future<Map<String, dynamic>> validateImage(String imageId) async {
    final response = await _apiClient.post(
      '${ApiConfig.imagingValidate}?imageId=$imageId',
      data: {},
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    throw Exception(response.message ?? 'Image validation failed');
  }

  Future<AIAnalysis> triggerAnalysis(String imageId) async {
    final response = await _apiClient.post<AIAnalysis>(
      ApiConfig.analysisRun,
      data: {'imageId': imageId},
      fromJsonT: (json) => AIAnalysis.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to start analysis');
  }

  Future<AIAnalysis> getAnalysis(String analysisId) async {
    final response = await _apiClient.get<AIAnalysis>(
      ApiConfig.analysisById(analysisId),
      fromJsonT: (json) => AIAnalysis.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to get analysis');
  }

  Future<List<AIAnalysis>> getAnalysisHistory() async {
    final response = await _apiClient.get(
      ApiConfig.analysisMyAnalyses,
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => AIAnalysis.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get image by ID
  Future<ImageAsset> getImage(String imageId) async {
    final response = await _apiClient.get<ImageAsset>(
      ApiConfig.imagingById(imageId),
      fromJsonT: (json) => ImageAsset.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to get image');
  }

  /// Get all user images
  Future<List<ImageAsset>> getMyImages() async {
    final response = await _apiClient.get(
      ApiConfig.imagingMyImages,
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => ImageAsset.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Delete image
  Future<void> deleteImage(String imageId) async {
    final response = await _apiClient.delete(
      ApiConfig.imagingDelete(imageId),
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to delete image');
    }
  }

  /// Get analysis status (for polling)
  Future<String> getAnalysisStatus(String analysisId) async {
    final response = await _apiClient.get(
      ApiConfig.analysisStatus(analysisId),
    );

    if (response.success && response.data != null) {
      return response.data as String;
    }

    throw Exception(response.message ?? 'Failed to get analysis status');
  }
}
