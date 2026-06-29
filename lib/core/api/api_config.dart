class ApiConfig {
  // DEVELOPMENT MODE - Set to true to use mock data without backend
  static const bool useMockMode = true;

  // Base URL - update this with your actual backend URL
  static const String baseUrl = 'https://api.scoliocare.app/v1';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';

  // Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String appleAuth = '/auth/apple';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String settings = '/settings/update';
}
