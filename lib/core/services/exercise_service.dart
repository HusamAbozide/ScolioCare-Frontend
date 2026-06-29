import '../api/api_client.dart';
import '../models/exercise/exercise_response.dart';

class ExerciseService {
  final ApiClient _apiClient;

  ExerciseService(this._apiClient);

  Future<List<ExerciseResponse>> getExercises({
    String? category,
    String? difficulty,
  }) async {
    final response = await _apiClient.get(
      '/exercises',
      queryParameters: {
        if (category != null) 'category': category,
        if (difficulty != null) 'difficulty': difficulty,
      },
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map(
              (item) => ExerciseResponse.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<UserExercisePlan?> getCurrentPlan(String userId) async {
    final response = await _apiClient.get<UserExercisePlan>(
      '/plan/$userId',
      fromJsonT: (json) =>
          UserExercisePlan.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data;
    }

    return null;
  }

  Future<UserExercisePlan> getPlanDetails(String planId) async {
    final response = await _apiClient.get<UserExercisePlan>(
      '/plan/$planId/details',
      fromJsonT: (json) =>
          UserExercisePlan.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load plan');
  }

  Future<ExerciseLog> submitExerciseLog(ExerciseLog log) async {
    final response = await _apiClient.post<ExerciseLog>(
      '/log/submit',
      data: log.toJson(),
      fromJsonT: (json) => ExerciseLog.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to submit log');
  }

  Future<List<ExerciseLog>> getExerciseLogs({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      '/exerciseLog',
      queryParameters: {
        'page': page,
        'size': size,
      },
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => ExerciseLog.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
