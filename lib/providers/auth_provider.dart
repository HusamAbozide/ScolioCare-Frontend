import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/services/auth_service.dart';
import '../core/models/auth/register_request.dart';
import '../core/models/user/user.dart';
import '../core/api/api_exception.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient());

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(email, password);
      _currentUser = authResponse.user;
      _isLoggedIn = true;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoggedIn = false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String firstName, String lastName, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      final authResponse = await _authService.register(request);
      _currentUser = authResponse.user;
      _isLoggedIn = true;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoggedIn = false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> googleSignIn(String googleIdToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.googleSignIn(googleIdToken);
      _currentUser = authResponse.user;
      _isLoggedIn = true;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoggedIn = false;
    } catch (e) {
      _errorMessage = 'Google sign-in failed';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> appleSignIn(String appleIdentityToken) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.appleSignIn(appleIdentityToken);
      _currentUser = authResponse.user;
      _isLoggedIn = true;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoggedIn = false;
    } catch (e) {
      _errorMessage = 'Apple sign-in failed';
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Log error but still clear local state
    }

    _isLoggedIn = false;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadSession() async {
    _isLoading = true;
    notifyListeners();

    try {
      final loggedIn = await _authService.isLoggedIn();
      _isLoggedIn = loggedIn;
    } catch (e) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
