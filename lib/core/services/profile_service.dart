import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/user/user_profile_response.dart';
import '../models/profile/update_profile_request.dart';

class ProfileService {
  final ApiClient _apiClient;

  ProfileService(this._apiClient);

  Future<UserProfileResponse> getProfile() async {
    final response = await _apiClient.get<UserProfileResponse>(
      ApiConfig.profile,
      fromJsonT: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load profile');
  }

  Future<UserProfileResponse> updateProfile(
      UpdateProfileRequest request) async {
    final response = await _apiClient.put<UserProfileResponse>(
      ApiConfig.profileUpdate,
      data: request.toJson(),
      fromJsonT: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to update profile');
  }

  Future<void> updateVitals(UpdateVitalsRequest request) async {
    // Mock mode for development
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await _apiClient.put<void>(
      ApiConfig.profileVitals,
      data: request.toJson(),
    );

    if (response.success) {
      return;
    }

    throw Exception(response.message ?? 'Failed to update vitals');
  }

  Future<void> updateWeakness(Map<String, dynamic> weaknessData) async {
    // Mock mode for development
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await _apiClient.put<void>(
      ApiConfig.profileWeakness,
      data: weaknessData,
    );

    if (response.success) {
      return;
    }

    throw Exception(response.message ?? 'Failed to update weakness');
  }

  Future<void> submitAssessment(Map<String, dynamic> answers) async {
    // Mock mode for development
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    final response = await _apiClient.post(
      ApiConfig.assessmentSubmit,
      data: AssessmentSubmitRequest(answers: answers).toJson(),
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to submit assessment');
    }
  }

  Future<Map<String, dynamic>> getAssessmentQuestions() async {
    final response = await _apiClient.get(
      ApiConfig.assessmentQuestions,
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    throw Exception(response.message ?? 'Failed to load questions');
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final response = await _apiClient.put(
      ApiConfig.settingsUpdate,
      data: settings,
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to update settings');
    }
  }

  Future<bool> deleteAccount({required String password}) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final response = await _apiClient.delete(
      ApiConfig.userDelete,
      data: {
        'password': password,
      },
    );

    return response.success;
  }
}
