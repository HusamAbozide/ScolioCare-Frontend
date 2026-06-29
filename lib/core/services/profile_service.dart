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

  Future<UserProfileResponse> updateVitals(UpdateVitalsRequest request) async {
    final response = await _apiClient.put<UserProfileResponse>(
      '/profile/vitals',
      data: request.toJson(),
      fromJsonT: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to update vitals');
  }

  Future<void> submitAssessment(Map<String, dynamic> answers) async {
    final response = await _apiClient.post(
      '/assessment/submit',
      data: AssessmentSubmitRequest(answers: answers).toJson(),
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to submit assessment');
    }
  }

  Future<Map<String, dynamic>> getAssessmentQuestions() async {
    final response = await _apiClient.get(
      '/assessment/questions',
    );

    if (response.success && response.data != null) {
      return response.data as Map<String, dynamic>;
    }

    throw Exception(response.message ?? 'Failed to load questions');
  }
}
