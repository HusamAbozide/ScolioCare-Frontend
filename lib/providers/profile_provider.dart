import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = const UserProfile(name: '', email: '');
  int _currentStep = 1;
  static const int totalSteps = 6;

  UserProfile get profile => _profile;
  int get currentStep => _currentStep;
  double get progress => _currentStep / totalSteps;

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
    notifyListeners();
  }

  void setActivityLevel(int level) {
    _profile = _profile.copyWith(activityLevel: level);
    notifyListeners();
  }

  void setPainLevel(int level) {
    _profile = _profile.copyWith(painLevel: level);
    notifyListeners();
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'userQuestionnaireData', jsonEncode(_profile.toJson()));
  }

  void reset() {
    _currentStep = 1;
    _profile = const UserProfile(name: '', email: '');
    notifyListeners();
  }
}
