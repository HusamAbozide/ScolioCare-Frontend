import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/exercise/exercise_response.dart';

class ExerciseService {
  final ApiClient _apiClient;

  ExerciseService(this._apiClient);

  Future<List<ExerciseResponse>> getExercises({
    String? category,
    String? difficulty,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.exercises,
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

  Future<ExerciseResponse> getExerciseById(String exerciseId) async {
    final response = await _apiClient.get<ExerciseResponse>(
      ApiConfig.exerciseById(exerciseId),
      fromJsonT: (json) =>
          ExerciseResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load exercise');
  }

  Future<UserExercisePlan?> getCurrentPlan(String userId) async {
    final response = await _apiClient.get<UserExercisePlan>(
      ApiConfig.planByUserId(userId),
      fromJsonT: (json) =>
          UserExercisePlan.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data;
    }

    return null;
  }

  Future<List<UserExercisePlan>> getPlanHistory(String userId) async {
    final response = await _apiClient.get(
      ApiConfig.planHistory(userId),
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map(
              (item) => UserExercisePlan.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<UserExercisePlan> getPlanDetails(String planId) async {
    final response = await _apiClient.get<UserExercisePlan>(
      ApiConfig.planDetails(planId),
      fromJsonT: (json) =>
          UserExercisePlan.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load plan');
  }

  Future<Map<String, dynamic>> getPlanSchedule(String planId) async {
    final response = await _apiClient.get(
      ApiConfig.planSchedule(planId),
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    throw Exception(response.message ?? 'Failed to load schedule');
  }

  Future<Map<String, dynamic>> generatePlanSchedule(String planId) async {
    final response = await _apiClient.get(
      ApiConfig.planScheduleGenerate(planId),
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    throw Exception(response.message ?? 'Failed to generate schedule');
  }

  Future<UserExercisePlan> generatePlan({
    required String analysisId,
    Map<String, dynamic>? assessmentAnswers,
  }) async {
    final response = await _apiClient.post<UserExercisePlan>(
      ApiConfig.planGenerate,
      data: {
        'analysisId': analysisId,
        if (assessmentAnswers != null) 'assessmentAnswers': assessmentAnswers,
      },
      fromJsonT: (json) =>
          UserExercisePlan.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to generate plan');
  }

  Future<void> pausePlan(String planId) async {
    final response = await _apiClient.put(
      ApiConfig.planPause(planId),
      data: {},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to pause plan');
    }
  }

  Future<void> resumePlan(String planId) async {
    final response = await _apiClient.put(
      ApiConfig.planResume(planId),
      data: {},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to resume plan');
    }
  }

  Future<void> completePlan(String planId) async {
    final response = await _apiClient.put(
      ApiConfig.planComplete(planId),
      data: {},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to complete plan');
    }
  }

  Future<ExerciseLog> submitExerciseLog(ExerciseLog log) async {
    final response = await _apiClient.post<ExerciseLog>(
      ApiConfig.exerciseLogSubmit,
      data: log.toJson(),
      fromJsonT: (json) => ExerciseLog.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to submit log');
  }

  Future<List<ExerciseLog>> getExerciseLogs(
    String userId, {
    int page = 0,
    int size = 20,
  }) async {
    final response = await _apiClient.get(
      ApiConfig.exerciseLogByUserId(userId),
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
