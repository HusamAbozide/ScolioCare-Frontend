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
    // Mock mode for development
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return UserProfileResponse(
        profileId: 'mock-profile-123',
        userId: 'mock-user-123',
        firstName: 'John',
        lastName: 'Doe',
        gender: 'MALE',
        dateOfBirth: DateTime(1990, 1, 1),
        heightCm: request.heightCm,
        weightKg: request.weightKg,
        activityLevel: 'MODERATE',
      );
    }

    final response = await _apiClient.put<UserProfileResponse>(
      ApiConfig.profileVitals,
      data: request.toJson(),
      fromJsonT: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to update vitals');
  }

  Future<UserProfileResponse> updateWeakness(
      Map<String, dynamic> weaknessData) async {
    // Mock mode for development
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return UserProfileResponse(
        profileId: 'mock-profile-123',
        userId: 'mock-user-123',
        firstName: 'John',
        lastName: 'Doe',
        gender: 'MALE',
        dateOfBirth: DateTime(1990, 1, 1),
        weaknessAreas: (weaknessData['weaknessAreas'] as List).join(','),
      );
    }

    final response = await _apiClient.put<UserProfileResponse>(
      ApiConfig.profileWeakness,
      data: weaknessData,
      fromJsonT: (json) =>
          UserProfileResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
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
