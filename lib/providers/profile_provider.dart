import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../core/api/api_client.dart';
import '../core/services/profile_service.dart';
import '../core/services/tracking_service.dart';
import '../core/models/user/user_profile_response.dart';
import '../core/models/profile/update_profile_request.dart';
import '../core/api/api_exception.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService(ApiClient());
  final TrackingService _trackingService = TrackingService(ApiClient());

  UserProfile _profile = const UserProfile(name: '', email: '');
  int _currentStep = 1;
  static const int totalSteps = 6;
  bool _isLoading = false;
  String? _errorMessage;
  int? _lastSavedPainLevel;

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
    _syncWeaknessAssessment();
    notifyListeners();
  }

  void setPersonalDetails({
    String? firstName,
    String? lastName,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? diagnosisTime,
    String? scoliosisType,
    String? currentTreatment,
  }) {
    _profile = _profile.copyWith(
      firstName: firstName ?? _profile.firstName,
      lastName: lastName ?? _profile.lastName,
      name: _joinName(
        firstName ?? _profile.firstName,
        lastName ?? _profile.lastName,
      ),
      age: age ?? _profile.age,
      gender: gender ?? _profile.gender,
      heightCm: heightCm ?? _profile.heightCm,
      weightKg: weightKg ?? _profile.weightKg,
      diagnosisTime: diagnosisTime ?? _profile.diagnosisTime,
      scoliosisType: scoliosisType ?? _profile.scoliosisType,
      currentTreatment: currentTreatment ?? _profile.currentTreatment,
    );
    if (diagnosisTime != null) {
      _assessmentAnswers['Q1'] = diagnosisTime;
    }
    if (currentTreatment != null) {
      _assessmentAnswers['Q6'] = _mapPhysiotherapyHistory(currentTreatment);
    }
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
    _syncWeaknessAssessment();
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
    _assessmentAnswers['Q7'] = _mapExerciseFrequency(level);
    notifyListeners();
  }

  void setPainLevel(int level) {
    _profile = _profile.copyWith(painLevel: level);
    _assessmentAnswers['Q3'] = level.toString();
    notifyListeners();
  }

  Future<void> saveProfile({bool recordPainChange = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _profileService.updateProfile(
        UpdateProfileRequest(
          firstName: _profile.firstName,
          lastName: _profile.lastName,
          dateOfBirth: _dateOfBirthFromAge(_profile.age),
          gender: _normalizeGender(_profile.gender),
          activityLevel: _mapActivityLevel(_profile.activityLevel),
        ),
      );

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

      print('Updating weakness areas: ${_profile.weaknessAreas}');
      await _profileService.updateWeakness({
        'weaknessAreas': _profile.weaknessAreas,
      });
      print('Weakness areas updated successfully');

      final assessmentAnswers = _buildAssessmentAnswers();
      print('Submitting assessment: $assessmentAnswers');
      await _profileService.submitAssessment(assessmentAnswers);
      _assessmentAnswers = assessmentAnswers;
      print('Assessment submitted successfully');

      if (recordPainChange && _lastSavedPainLevel != _profile.painLevel) {
        try {
          await _trackingService.recordPain(
            progressId: '',
            painLevel: _profile.painLevel.clamp(1, 10).toInt(),
            location: _profile.weaknessAreas.isNotEmpty
                ? _profile.weaknessAreas.join(', ')
                : 'Back',
            description: 'Updated from profile settings',
          );
        } catch (e) {
          print('Pain tracking sync failed: $e');
        }
        _lastSavedPainLevel = _profile.painLevel;
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
      _assessmentAnswers =
          Map<String, dynamic>.from(profileResponse.initialAssessment ?? {});
      _profile = _convertToUserProfile(profileResponse);
      _lastSavedPainLevel = _profile.painLevel;
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
    _lastSavedPainLevel = null;
    notifyListeners();
  }

  // Helper methods to map UI values to backend enums
  String _mapActivityLevel(int level) {
    if (level <= 2) return 'SEDENTARY';
    if (level <= 5) return 'LIGHT';
    if (level <= 8) return 'MODERATE';
    return 'ACTIVE';
  }

  String _mapFlexibilityLevel(int level) {
    if (level <= 3) return 'VERY_STIFF';
    if (level <= 5) return 'SOMEWHAT_STIFF';
    if (level <= 7) return 'AVERAGE';
    return 'FLEXIBLE';
  }

  Map<String, dynamic> _buildAssessmentAnswers() {
    final answers = Map<String, dynamic>.from(_assessmentAnswers);
    if (_profile.age != null) {
      answers['age'] = _profile.age.toString();
    }
    answers['Q1'] = _profile.diagnosisTime ?? answers['Q1'] ?? 'Not provided';
    answers['Q2'] = _mapActivityLevel(_profile.activityLevel);
    answers['Q3'] = _profile.painLevel.toString();
    answers['Q4'] = _formatWeaknessAreas(_profile.weaknessAreas);
    answers['Q5'] = _mapFlexibilityLevel(_profile.flexibilityLevel);
    answers['Q6'] = _mapPhysiotherapyHistory(_profile.currentTreatment);
    answers['Q7'] = _mapExerciseFrequency(_profile.activityLevel);
    return answers;
  }

  void _syncWeaknessAssessment() {
    _assessmentAnswers['Q4'] = _formatWeaknessAreas(_profile.weaknessAreas);
  }

  String _formatWeaknessAreas(List<String> areas) {
    return areas
        .map((area) => area.replaceAll('-', '_').toUpperCase())
        .join(',');
  }

  String _mapPhysiotherapyHistory(String? treatment) {
    final normalized = treatment?.toLowerCase() ?? '';
    if (normalized.contains('physical') ||
        normalized.contains('physio') ||
        normalized.contains('surgery')) {
      return 'YES';
    }
    return 'NO';
  }

  String _mapExerciseFrequency(int activityLevel) {
    return activityLevel >= 7 ? 'YES_REGULARLY' : 'NO';
  }

  UserProfile _convertToUserProfile(UserProfileResponse response) {
    final assessment = response.initialAssessment ?? _assessmentAnswers;
    return UserProfile(
      name: _joinName(response.firstName, response.lastName),
      email: _profile.email,
      firstName: response.firstName,
      lastName: response.lastName,
      age: _ageFromDateOfBirth(response.dateOfBirth) ??
          int.tryParse(assessment['age']?.toString() ?? '') ??
          _profile.age,
      gender: response.gender,
      heightCm: response.heightCm ?? _profile.heightCm,
      weightKg: response.weightKg ?? _profile.weightKg,
      weaknessAreas: _parseWeaknessAreas(response.weaknessAreas, assessment),
      flexibilityLevel: _mapFlexibilityLevelFromBackend(
            assessment['Q5']?.toString(),
          ) ??
          _profile.flexibilityLevel,
      activityLevel: _mapActivityLevelFromBackend(response.activityLevel) ??
          _mapActivityLevelFromBackend(assessment['Q2']?.toString()) ??
          _profile.activityLevel,
      painLevel: int.tryParse(assessment['Q3']?.toString() ?? '') ??
          _profile.painLevel,
      avatar: _profile.avatar,
      diagnosisTime: assessment['Q1']?.toString() ?? _profile.diagnosisTime,
      scoliosisType: _profile.scoliosisType,
      currentTreatment:
          _treatmentFromAssessment(assessment['Q6']?.toString()) ??
              _profile.currentTreatment,
    );
  }

  List<String> _parseWeaknessAreas(
    String? responseAreas,
    Map<String, dynamic> assessment,
  ) {
    final source = (responseAreas != null && responseAreas.isNotEmpty)
        ? responseAreas
        : assessment['Q4']?.toString();
    if (source == null || source.isEmpty) return [];
    return source
        .split(',')
        .map((area) => area.trim().toLowerCase().replaceAll('_', '-'))
        .where((area) => area.isNotEmpty)
        .toList();
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

  String? _normalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return null;
    return gender.toUpperCase();
  }

  String _joinName(String? firstName, String? lastName) {
    return [firstName, lastName]
        .where((part) => part != null && part.trim().isNotEmpty)
        .map((part) => part!.trim())
        .join(' ');
  }

  String? _dateOfBirthFromAge(int? age) {
    if (age == null || age <= 0 || age > 120) return null;
    final today = DateTime.now();
    return DateTime(today.year - age, today.month, today.day)
        .toIso8601String()
        .split('T')
        .first;
  }

  int? _ageFromDateOfBirth(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return null;
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    final hadBirthday = today.month > dateOfBirth.month ||
        (today.month == dateOfBirth.month && today.day >= dateOfBirth.day);
    if (!hadBirthday) age--;
    return age < 0 ? null : age;
  }

  int? _mapFlexibilityLevelFromBackend(String? level) {
    switch (level?.toUpperCase()) {
      case 'VERY_STIFF':
        return 2;
      case 'SOMEWHAT_STIFF':
        return 4;
      case 'AVERAGE':
        return 6;
      case 'FLEXIBLE':
        return 9;
      default:
        return null;
    }
  }

  String? _treatmentFromAssessment(String? value) {
    switch (value?.toUpperCase()) {
      case 'YES':
        return 'Physical therapy';
      case 'NO':
        return 'No treatment';
      default:
        return null;
    }
  }
}
