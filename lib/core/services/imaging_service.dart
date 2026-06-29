import 'dart:io';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
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
    });

    final endpoint = fromCamera ? '/image/capture' : '/image/upload';

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
      '/image/validate',
      data: {'imageId': imageId},
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    throw Exception(response.message ?? 'Image validation failed');
  }

  Future<AIAnalysis> triggerAnalysis(String imageId) async {
    final response = await _apiClient.post<AIAnalysis>(
      '/analysis/run',
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
      '/analysis/$analysisId',
      fromJsonT: (json) => AIAnalysis.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to get analysis');
  }

  Future<List<AIAnalysis>> getAnalysisHistory() async {
    final response = await _apiClient.get(
      '/analysis/history',
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => AIAnalysis.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
