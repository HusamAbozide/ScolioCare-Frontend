import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLogin = true;
  UserProfile? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLogin => _isLogin;
  UserProfile? get currentUser => _currentUser;

  void toggleLoginMode() {
    _isLogin = !_isLogin;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    // TODO: Replace with real API call
    _isLoggedIn = true;
    _currentUser = UserProfile(name: 'Sarah Johnson', email: email);
    notifyListeners();
  }

  Future<void> signUp(String name, String email, String password) async {
    // TODO: Replace with real API call
    _isLoggedIn = true;
    _currentUser = UserProfile(name: name, email: email);
    notifyListeners();
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _isLoggedIn = false;
    _currentUser = null;
    notifyListeners();
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _isLoggedIn = true;
      // Simplified – in production, deserialize fully
      _currentUser = UserProfile(
        name: prefs.getString('userName') ?? 'User',
        email: prefs.getString('userEmail') ?? '',
      );
      notifyListeners();
    }
  }
}
