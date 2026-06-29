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
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      return _createMockAuthResponse(email);
    }

    final response = await _apiClient.post<AuthResponse>(
      ApiConfig.login,
      data: LoginRequest(identifier: email, password: password).toJson(),
      fromJsonT: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      await _apiClient.storeTokens(
        authData.accessToken,
        authData.refreshToken,
        authData.user.userId,
      );
      return authData;
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

    final response = await _apiClient.post<AuthResponse>(
      ApiConfig.register,
      data: request.toJson(),
      fromJsonT: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      await _apiClient.storeTokens(
        authData.accessToken,
        authData.refreshToken,
        authData.user.userId,
      );
      return authData;
    }

    throw Exception(response.message ?? 'Registration failed');
  }

  Future<AuthResponse> googleSignIn(String googleIdToken) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return _createMockAuthResponse('user@gmail.com');
    }

    final response = await _apiClient.post<AuthResponse>(
      ApiConfig.googleAuth,
      data: {'googleIdToken': googleIdToken},
      fromJsonT: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      await _apiClient.storeTokens(
        authData.accessToken,
        authData.refreshToken,
        authData.user.userId,
      );
      return authData;
    }

    throw Exception(response.message ?? 'Google sign-in failed');
  }

  Future<AuthResponse> appleSignIn(String appleIdentityToken) async {
    // Mock mode for development without backend
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return _createMockAuthResponse('user@icloud.com');
    }

    final response = await _apiClient.post<AuthResponse>(
      ApiConfig.appleAuth,
      data: {'appleIdentityToken': appleIdentityToken},
      fromJsonT: (json) => AuthResponse.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      final authData = response.data!;
      await _apiClient.storeTokens(
        authData.accessToken,
        authData.refreshToken,
        authData.user.userId,
      );
      return authData;
    }

    throw Exception(response.message ?? 'Apple sign-in failed');
  }

  Future<void> logout() async {
    if (ApiConfig.useMockMode) {
      await _apiClient.clearTokens();
      return;
    }

    await _apiClient.post(
      ApiConfig.logout,
      data: {},
    );
    await _apiClient.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    final token = await _apiClient.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // Mock data generator for development
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
