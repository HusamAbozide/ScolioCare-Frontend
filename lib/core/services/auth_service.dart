import 'dart:convert';
import 'dart:developer' as developer;

import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/auth/login_request.dart';
import '../models/auth/register_request.dart';
import '../models/auth/auth_response.dart';
import '../models/user/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> login(String email, String password) async {
    if (ApiConfig.useMockMode) {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      return _createMockAuthResponse(email);
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.login,
      data: LoginRequest(email: email, password: password).toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return await _handleTokenResponse(response.data!, fallbackEmail: email);
    }

    throw Exception(response.message ?? 'Login failed');
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      return _createMockAuthResponse(request.email);
    }

    // Ensure email is lowercase for consistency
    final cleanRequest = RegisterRequest(
      email: request.email.trim().toLowerCase(),
      password: request.password,
      firstName: request.firstName,
      lastName: request.lastName,
    );

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.register,
      data: cleanRequest.toJson(),
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      if (response.data!.containsKey('message') &&
          response.data!.containsKey('email')) {
        final user = User(
          userId: 'pending-verification',
          email: cleanRequest.email,
          isActive: false,
          emailVerified: false,
          phoneVerified: false,
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        return AuthResponse(
          accessToken: '',
          refreshToken: '',
          user: user,
        );
      }

      return await _handleTokenResponse(
        response.data!,
        fallbackEmail: cleanRequest.email,
      );
    }

    throw Exception(response.message ?? 'Registration failed');
  }

  Future<AuthResponse> googleSignIn(String googleIdToken) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return _createMockAuthResponse('user@gmail.com');
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.googleAuth,
      data: {'googleIdToken': googleIdToken},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return await _handleTokenResponse(response.data!);
    }

    throw Exception(response.message ?? 'Google sign-in failed');
  }

  Future<AuthResponse> appleSignIn(String appleIdentityToken) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return _createMockAuthResponse('user@icloud.com');
    }

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.appleAuth,
      data: {'appleIdentityToken': appleIdentityToken},
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return await _handleTokenResponse(response.data!);
    }

    throw Exception(response.message ?? 'Apple sign-in failed');
  }

  Future<AuthResponse> _handleTokenResponse(
    Map<String, dynamic> responseData, {
    String? fallbackEmail,
  }) async {
    final accessToken = responseData['accessToken'] as String;
    final refreshToken = responseData['refreshToken'] as String;
    final claims = _decodeJwtClaims(accessToken);
    final userId = claims['userId'] as String?;
    final email =
        (claims['sub'] as String?) ?? fallbackEmail ?? 'user@example.com';

    if (userId == null || userId.isEmpty) {
      throw Exception('Authentication response did not include a user ID');
    }

    await _apiClient.storeTokens(accessToken, refreshToken, userId);

    final user = User(
      userId: userId,
      email: email,
      isActive: true,
      emailVerified: true,
      phoneVerified: false,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    return AuthResponse(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }

  Map<String, dynamic> _decodeJwtClaims(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token format');
    }

    final normalized = base64Url.normalize(parts[1]);
    final payload = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(payload) as Map<String, dynamic>;
  }

  Future<void> logout() async {
    if (ApiConfig.useMockMode) {
      await _apiClient.clearTokens();
      return;
    }

    try {
      await _apiClient.post(
        ApiConfig.logout,
        data: {},
      );
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConfig.changePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    return response.success;
  }

  Future<bool> resetPassword({
    required String newPassword,
  }) async {
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      await _apiClient.clearTokens();
      return true;
    }

    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConfig.resetPassword,
      data: {
        'newPassword': newPassword,
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success) {
      await _apiClient.clearTokens();
    }

    return response.success;
  }

  Future<bool> sendOtp({
    required String email,
    required String purpose,
  }) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return true;
    }

    // Ensure email is lowercase for consistency
    final cleanEmail = email.trim().toLowerCase();

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.sendOtp,
      data: {
        'email': cleanEmail,
        'purpose': purpose,
      },
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    return response.success;
  }

  Future<Map<String, dynamic>?> verifyOtp({
    required String email,
    required String otp,
  }) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return {'verified': true};
    }

    // Trim whitespace and ensure consistent format
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = otp.trim();

    developer.log(
        'Verifying OTP - Email: "$cleanEmail", OTP: "$cleanOtp" (length: ${cleanOtp.length})');

    final requestBody = {
      'email': cleanEmail,
      'otp': cleanOtp.toString(), // Force string type
    };

    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.verifyOtp,
      data: requestBody,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      if (response.data!.containsKey('accessToken')) {
        final accessToken = response.data!['accessToken'] as String;
        final refreshToken = response.data!['refreshToken'] as String;
        final claims = _decodeJwtClaims(accessToken);
        final userId = claims['userId'] as String?;

        if (userId == null || userId.isEmpty) {
          throw Exception(
              'OTP verification response did not include a user ID');
        }

        // Store tokens
        await _apiClient.storeTokens(
          accessToken,
          refreshToken,
          userId,
        );

        return {
          ...response.data!,
          'userId': userId,
        };
      }
      return response.data;
    }

    return null;
  }

  // Mock data generator 
  AuthResponse _createMockAuthResponse(String email) {
    final mockUser = User(
      userId: 'mock-user-123',
      email: email,
      isActive: true,
      emailVerified: true,
      phoneVerified: false,
      createdAt: DateTime.now(),
      lastLogin: DateTime.now(),
    );

    final mockResponse = AuthResponse(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'mock-refresh-token-${DateTime.now().millisecondsSinceEpoch}',
      user: mockUser,
    );

    // Store mock tokens
    _apiClient.storeTokens(
      mockResponse.accessToken,
      mockResponse.refreshToken,
      mockUser.userId,
    );

    return mockResponse;
  }
}
