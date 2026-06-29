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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
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
        await _profileService.updateVitals(
          UpdateVitalsRequest(
            heightCm: _profile.heightCm!,
            weightKg: _profile.weightKg!,
          ),
        );
      }

      // Update profile fields
      await _profileService.updateProfile(
        UpdateProfileRequest(
          weaknessAreas: _profile.weaknessAreas.join(','),
        ),
      );

      // Submit assessment answers if collected
      if (_assessmentAnswers.isNotEmpty) {
        await _profileService.submitAssessment(_assessmentAnswers);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to save profile';
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
      email: '', // Will be fetched from User object
      heightCm: response.heightCm,
      weightKg: response.weightKg,
      weaknessAreas: response.weaknessAreas?.split(',') ?? [],
      flexibilityLevel: 5,
      activityLevel: 5,
      painLevel: 3,
    );
  }
}
