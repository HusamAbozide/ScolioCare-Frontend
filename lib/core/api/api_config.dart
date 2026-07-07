import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class ApiConfig {
  static const bool useMockMode = false;

  static const String _apiBaseUrlOverride =
      String.fromEnvironment('API_BASE_URL');

  static String get baseUrl =>
      _apiBaseUrlOverride.isNotEmpty ? _apiBaseUrlOverride : _defaultBaseUrl();

  static String resolveFileUrl(String pathOrUrl) {
    if (pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://')) {
      return pathOrUrl;
    }

    final normalized = pathOrUrl.startsWith('/')
        ? pathOrUrl
        : '/${pathOrUrl.replaceAll('\\', '/')}';
    return '$baseUrl$normalized';
  }

  static String _defaultBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8081';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://192.168.110.247:8081';
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://localhost:8081'; 
    }

    return 'http://192.168.110.247:8081';
  }

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(minutes: 5);

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
  static const String changePassword = '/auth/change-password';
  static const String resetPassword = '/auth/reset-password';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';


  static const String profile = '/profile';
  static const String profileUpdate = '/profile/update';
  static const String profileVitals = '/profile/vitals';
  static const String profileWeakness = '/profile/weakness';
  static const String assessmentQuestions = '/assessment/questions';
  static const String assessmentSubmit = '/assessment/submit';
  static const String settingsUpdate = '/settings/update';


  static const String userDelete = '/user/delete';

 
  static const String consentAccept = '/consent/accept';
  static const String consentWithdraw = '/consent/withdraw';
  static const String consentMy = '/consent/my';
  static const String medicalDisclaimer = '/medical-disclaimer';
  static const String legalDisclaimer = '/legal/disclaimer';
  static const String legalTerms = '/legal/terms';

  static const String rewardsCatalog = '/rewards/catalog';
  static const String userRewards = '/rewards'; // + /{userId}
  static String userRewardBalance(String userId) => '/rewards/$userId/balance';

  static const String exercises =
      '/exercises'; // GET all, supports ?category=X&difficulty=Y
  static String exerciseById(String id) => '/exercises/$id'; // GET by ID

  // Exercise Plans
  static const String planGenerate = '/plan/generate'; // POST
  static String planByUserId(String userId) =>
      '/plan/$userId'; // GET active plan
  static String planHistory(String userId) =>
      '/plan/$userId/history'; // GET plan history
  static String planSchedule(String planId) =>
      '/plan/$planId/schedule'; // GET schedule
  static String planDetails(String planId) =>
      '/plan/$planId/details'; // GET details
  static String planScheduleGenerate(String planId) =>
      '/plan/$planId/schedule/generate'; // GET
  static String planPause(String planId) => '/plan/$planId/pause'; // PUT
  static String planResume(String planId) => '/plan/$planId/resume'; // PUT
  static String planComplete(String planId) => '/plan/$planId/complete'; // PUT

  // Exercise Logs
  static const String exerciseLogSubmit = '/log/submit'; // POST
  static const String exerciseLogToday = '/log/today'; // DELETE
  static String exerciseLogByUserId(String userId) => '/log/$userId'; // GET

 
  // Progress Tracking
  static String progressByUserId(String userId) => '/progress/$userId'; // GET
  static String progressSummary(String userId) =>
      '/progress/$userId/summary'; // GET

  // Pain Tracking
  static const String painRecord = '/pain/record'; // POST
  static String painHistory(String userId) => '/pain/$userId'; // GET

  // Scoliometer
  static const String scoliometerRecord = '/scoliometer/record'; // POST
  static String scoliometerHistory(String userId) =>
      '/scoliometer/$userId'; // GET

  // Posture Photos
  static const String postureUpload = '/posture/upload'; // POST
  static const String postureCompare = '/posture/compare'; // POST
  static String postureByUserId(String userId) => '/posture/$userId'; // GET
  static String postureComparisons(String userId) =>
      '/posture/$userId/comparisons'; // GET
  static String postureDeletePhoto(String photoId) =>
      '/posture/photos/$photoId'; // DELETE
  static String postureDeleteComparison(String comparisonId) =>
      '/posture/comparisons/$comparisonId'; // DELETE

  
  static const String imagingCapture = '/api/v1/imaging/capture'; // POST
  static const String imagingUpload = '/api/v1/imaging/upload'; // POST
  static const String imagingValidate = '/api/v1/imaging/validate'; // POST
  static String imagingById(String imageId) =>
      '/api/v1/imaging/$imageId'; // GET
  static const String imagingMyImages = '/api/v1/imaging/my-images'; // GET
  static String imagingDelete(String imageId) =>
      '/api/v1/imaging/$imageId'; // DELETE
  static String imagingServe(String imageId) =>
      '/api/v1/imaging/files/images/$imageId'; // GET

  static const String analysisRun = '/api/v1/analysis/run'; // POST
  static String analysisById(String analysisId) =>
      '/api/v1/analysis/$analysisId'; // GET
  static const String analysisMyAnalyses =
      '/api/v1/analysis/my-analyses'; // GET
  static String analysisStatus(String analysisId) =>
      '/api/v1/analysis/$analysisId/status'; // GET

  static const String reportGenerate = '/api/v1/report/generate'; // POST
  static String reportById(String reportId) =>
      '/api/v1/report/$reportId'; // GET
  static String reportByAnalysisId(String analysisId) =>
      '/api/v1/report/by-analysis/$analysisId'; // GET
  static const String reportMyReports = '/api/v1/report/my-reports'; // GET
  static const String reportMyReportsPaginated =
      '/api/v1/report/my-reports/paginated'; // GET
  static String reportDownload(String reportId) =>
      '/api/v1/report/$reportId/download'; // GET
  static String reportStatus(String reportId) =>
      '/api/v1/report/$reportId/status'; // GET

  static const String chatSessionStart = '/chat/session/start'; // POST
  static String chatSessionMessage(String sessionId) =>
      '/chat/session/$sessionId/message'; // POST
  static String chatSessionMessages(String sessionId) =>
      '/chat/session/$sessionId/messages'; // GET
  static String chatSessionEnd(String sessionId) =>
      '/chat/session/$sessionId/end'; // POST

  static String notificationsByUserId(String userId) =>
      '/notification/$userId'; // GET
  static const String notificationUnreadCount =
      '/notification/unread-count'; // GET (needs ?userId=X)
  static const String notificationRead =
      '/notification/read'; // POST (needs ?userId=X)
  static const String notificationCancel =
      '/notification/cancel'; // POST (needs ?userId=X)
  static const String notificationDeviceToken =
      '/notification/device-token'; // POST (needs ?userId=X)
  static const String notificationTestPush = '/notification/test-push'; // POST
  static const String notificationSettingsUpdate =
      '/notification/settings/update'; // PUT
}
