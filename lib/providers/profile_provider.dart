import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../core/api/api_client.dart';
import '../core/services/profile_service.dart';
import '../core/models/user/user_profile_response.dart';
import '../core/models/profile/update_profile_request.dart';
import '../core/api/api_exception.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService(ApiClient());

  UserProfile _profile = const UserProfile(name: '', email: '');
  int _currentStep = 1;
  static const int totalSteps = 6;
  bool _isLoading = false;
  String? _errorMessage;

  // Temporary storage for assessment answers
  Map<String, dynamic> _assessmentAnswers = {};

  UserProfile get profile => _profile;
  int get currentStep => _currentStep;
  double get progress => _currentStep / totalSteps;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for error

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> deleteAccount({required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _profileService.deleteAccount(password: password);

      if (!success) {
        _errorMessage = 'Failed to delete account';
      }

      return success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateProfile(UserProfile updated) {
    _profile = updated;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < totalSteps) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    }
  }

  void setWeaknessAreas(List<String> areas) {
    _profile = _profile.copyWith(weaknessAreas: areas);
    notifyListeners();
  }

  void setPersonalDetails({
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? diagnosisTime,
    String? scoliosisType,
    String? currentTreatment,
  }) {
    _profile = _profile.copyWith(
      age: age ?? _profile.age,
      gender: gender ?? _profile.gender,
      heightCm: heightCm ?? _profile.heightCm,
      weightKg: weightKg ?? _profile.weightKg,
      diagnosisTime: diagnosisTime ?? _profile.diagnosisTime,
      scoliosisType: scoliosisType ?? _profile.scoliosisType,
      currentTreatment: currentTreatment ?? _profile.currentTreatment,
    );
    notifyListeners();
  }

  void toggleWeaknessArea(String area) {
    final areas = List<String>.from(_profile.weaknessAreas);
    if (areas.contains(area)) {
      areas.remove(area);
    } else {
      areas.add(area);
    }
    _profile = _profile.copyWith(weaknessAreas: areas);
    notifyListeners();
  }

  void setFlexibilityLevel(int level) {
    _profile = _profile.copyWith(flexibilityLevel: level);
    _assessmentAnswers['Q5'] = _mapFlexibilityLevel(level);
    notifyListeners();
  }

  void setActivityLevel(int level) {
    _profile = _profile.copyWith(activityLevel: level);
    _assessmentAnswers['Q2'] = _mapActivityLevel(level);
    notifyListeners();
  }

  void setPainLevel(int level) {
    _profile = _profile.copyWith(painLevel: level);
    _assessmentAnswers['Q3'] = level;
    notifyListeners();
  }

  Future<void> saveProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update vitals if provided
      if (_profile.heightCm != null && _profile.weightKg != null) {
        print(
            'Updating vitals: height=${_profile.heightCm}, weight=${_profile.weightKg}');
        await _profileService.updateVitals(
          UpdateVitalsRequest(
            heightCm: _profile.heightCm!,
            weightKg: _profile.weightKg!,
          ),
        );
        print('Vitals updated successfully');
      }

      if (_profile.weaknessAreas.isNotEmpty) {
        print('Updating weakness areas: ${_profile.weaknessAreas}');
        await _profileService.updateWeakness({
          'weaknessAreas': _profile.weaknessAreas,
        });
        print('Weakness areas updated successfully');
      }

      // Submit assessment answers if collected
      if (_assessmentAnswers.isNotEmpty) {
        print('Submitting assessment: $_assessmentAnswers');
        await _profileService.submitAssessment(_assessmentAnswers);
        print('Assessment submitted successfully');
      }

      // Clear error on success
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      print('Profile save error (ApiException): ${e.message}');
      print('Status code: ${e.statusCode}');
      print('Error code: ${e.errorCode}');
    } catch (e) {
      _errorMessage = 'Failed to save profile: $e';
      print('Profile save error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profileResponse = await _profileService.getProfile();
      _profile = _convertToUserProfile(profileResponse);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load profile';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _currentStep = 1;
    _profile = const UserProfile(name: '', email: '');
    _assessmentAnswers = {};
    notifyListeners();
  }

  // Helper methods to map UI values to backend enums
  String _mapActivityLevel(int level) {
    if (level <= 3) return 'LOW';
    if (level <= 7) return 'MODERATE';
    return 'HIGH';
  }

  String _mapFlexibilityLevel(int level) {
    if (level <= 3) return 'VERY_STIFF';
    if (level <= 5) return 'SOMEWHAT_STIFF';
    if (level <= 7) return 'AVERAGE';
    return 'FLEXIBLE';
  }

  UserProfile _convertToUserProfile(UserProfileResponse response) {
    return UserProfile(
      name: '${response.firstName} ${response.lastName}',
      email: _profile.email,
      age: _profile.age,
      gender: response.gender,
      heightCm: response.heightCm ?? _profile.heightCm,
      weightKg: response.weightKg ?? _profile.weightKg,
      weaknessAreas: response.weaknessAreas?.split(',') ?? [],
      flexibilityLevel: _profile.flexibilityLevel,
      activityLevel: _mapActivityLevelFromBackend(response.activityLevel) ??
          _profile.activityLevel,
      painLevel: _profile.painLevel,
      avatar: _profile.avatar,
      diagnosisTime: _profile.diagnosisTime,
      scoliosisType: _profile.scoliosisType,
      currentTreatment: _profile.currentTreatment,
    );
  }

  int? _mapActivityLevelFromBackend(String? level) {
    switch (level?.toUpperCase()) {
      case 'SEDENTARY':
        return 1;
      case 'LIGHT':
        return 4;
      case 'MODERATE':
        return 7;
      case 'ACTIVE':
        return 10;
      default:
        return null;
    }
  }
}
