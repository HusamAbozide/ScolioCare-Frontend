import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/services/auth_service.dart';
import '../core/services/profile_service.dart';
import '../core/models/auth/register_request.dart';
import '../core/models/user/user.dart';
import '../core/models/user/user_profile_response.dart';
import '../core/api/api_exception.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService(ApiClient());
  final ProfileService _profileService = ProfileService(ApiClient());

  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get error => _errorMessage; // Alias for error
  User? get currentUser => _currentUser;
  String? get userId => _currentUser?.userId;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!success) {
        _errorMessage = 'Failed to change password';
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

  Future<bool> sendOtp({
    required String email,
    required String purpose,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.sendOtp(
        email: email,
        purpose: purpose,
      );

      if (!success) {
        _errorMessage = 'Failed to send OTP';
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

  Future<bool> verifyOtp({
    required String email,
    required String otp,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authService.verifyOtp(
        email: email,
        otp: otp,
      );

      if (response == null) {
        _errorMessage = 'Invalid OTP';
        return false;
      }

      // Check if response includes tokens (user should be logged in after OTP verification)
      if (response.containsKey('accessToken') &&
          response.containsKey('userId')) {
        // User is now logged in with tokens
        final userId = response['userId'] as String;
        _currentUser = await _loadCurrentUser(
              fallbackUser: User(
                userId: userId,
                email: email,
                isActive: true,
                emailVerified: true,
                phoneVerified: false,
                createdAt: DateTime.now(),
                lastLogin: DateTime.now(),
              ),
            ) ??
            User(
              userId: userId,
              email: email,
              isActive: true,
              emailVerified: true,
              phoneVerified: false,
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
            );
        _isLoggedIn = true;
      }

      return true;
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

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(email, password);
      _currentUser = await _loadCurrentUser(
            fallbackUser: authResponse.user,
          ) ??
          authResponse.user;
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

  Future<bool> signUp(
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

      // Check if email verification is required (no tokens returned)
      if (authResponse.accessToken.isEmpty) {
        // Registration successful but email verification needed
        // Don't set logged in state, caller should navigate to OTP screen
        _isLoggedIn = false;
        _errorMessage = null;
        return true; // Indicate success but not logged in yet
      }

      // If tokens were provided (shouldn't happen normally)
      _currentUser = await _loadCurrentUser(
            fallbackUser: authResponse.user.copyWith(
              firstName: firstName,
              lastName: lastName,
            ),
          ) ??
          authResponse.user.copyWith(
            firstName: firstName,
            lastName: lastName,
          );
      _isLoggedIn = true;
      _errorMessage = null;
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _isLoggedIn = false;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoggedIn = false;
      return false;
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
      _currentUser = await _loadCurrentUser(
            fallbackUser: authResponse.user,
          ) ??
          authResponse.user;
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
      _currentUser = await _loadCurrentUser(
            fallbackUser: authResponse.user,
          ) ??
          authResponse.user;
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

      if (_isLoggedIn && _currentUser == null) {
        final userId = await ApiClient().getUserId();
        if (userId != null) {
          _currentUser = await _loadCurrentUser(
                fallbackUser: User(
                  userId: userId,
                  email: 'user@example.com',
                  isActive: true,
                  emailVerified: true,
                  phoneVerified: false,
                  createdAt: DateTime.now(),
                  lastLogin: DateTime.now(),
                ),
              ) ??
              User(
                userId: userId,
                email: 'user@example.com',
                isActive: true,
                emailVerified: true,
                phoneVerified: false,
                createdAt: DateTime.now(),
                lastLogin: DateTime.now(),
              );
        }
      }
    } catch (e) {
      _isLoggedIn = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<User?> _loadCurrentUser({User? fallbackUser}) async {
    try {
      final profile = await _profileService.getProfile();
      return _buildUserFromProfile(profile, fallbackUser: fallbackUser);
    } catch (_) {
      return fallbackUser;
    }
  }

  User _buildUserFromProfile(
    UserProfileResponse profile, {
    User? fallbackUser,
  }) {
    return User(
      userId: profile.userId ?? fallbackUser?.userId ?? '',
      email: profile.email ?? fallbackUser?.email ?? 'user@example.com',
      firstName: profile.firstName,
      lastName: profile.lastName,
      phone: fallbackUser?.phone,
      isActive: fallbackUser?.isActive ?? true,
      emailVerified: fallbackUser?.emailVerified ?? true,
      phoneVerified: fallbackUser?.phoneVerified ?? false,
      createdAt: fallbackUser?.createdAt ?? DateTime.now(),
      lastLogin: fallbackUser?.lastLogin ?? DateTime.now(),
    );
  }
}
