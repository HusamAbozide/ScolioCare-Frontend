import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/services/profile_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService(ApiClient());

  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _language = 'English';

  bool get notificationsEnabled => _notificationsEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  String get language => _language;
  ThemeMode get themeMode =>
      _darkModeEnabled ? ThemeMode.dark : ThemeMode.light;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
    _language = prefs.getString('language') ?? 'English';
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
    await _syncBackendSettings();
  }

  Future<void> setDarkMode(bool value) async {
    _darkModeEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkModeEnabled', value);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    notifyListeners();
    await _syncBackendSettings();
  }

  Future<void> _syncBackendSettings() async {
    try {
      await _profileService.updateSettings({
        'notificationsEnabled': _notificationsEnabled,
        'pushEnabled': _notificationsEnabled,
        'emailEnabled': _notificationsEnabled,
        'language': _language,
      });
    } catch (_) {
      // Local preferences should still work if the server is temporarily unavailable.
    }
  }
}
