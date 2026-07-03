import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/legal/legal_text.dart';

class LegalService {
  final ApiClient _apiClient;

  LegalService(this._apiClient);

  /// Get legal disclaimer
  Future<LegalText> getDisclaimer() async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return LegalText(
        content: _getMockDisclaimer(),
        version: '1.0',
        effectiveDate: DateTime(2025, 1, 1),
      );
    }

    final response = await _apiClient.get<LegalText>(
      ApiConfig.legalDisclaimer,
      fromJsonT: (json) => LegalText.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load disclaimer');
  }

  /// Get terms of service
  Future<LegalText> getTerms() async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return LegalText(
        content: _getMockTerms(),
        version: '1.0',
        effectiveDate: DateTime(2025, 1, 1),
      );
    }

    final response = await _apiClient.get<LegalText>(
      ApiConfig.legalTerms,
      fromJsonT: (json) => LegalText.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load terms');
  }

  /// Get medical disclaimer
  Future<MedicalDisclaimer> getMedicalDisclaimer() async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return MedicalDisclaimer(
        disclaimerId: 'mock-disclaimer-1',
        content: _getMockMedicalDisclaimer(),
        version: '1.0',
        effectiveDate: DateTime(2025, 1, 1),
        isActive: true,
      );
    }

    final response = await _apiClient.get<MedicalDisclaimer>(
      ApiConfig.medicalDisclaimer,
      fromJsonT: (json) =>
          MedicalDisclaimer.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to load medical disclaimer');
  }

  /// Accept consent
  Future<Map<String, bool>> getMyConsents() async {
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return {};
    }

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.consentMy,
      fromJsonT: (json) => json as Map<String, dynamic>,
    );

    if (response.success && response.data != null) {
      return response.data!.map(
        (key, value) => MapEntry(key, value == true),
      );
    }

    throw Exception(response.message ?? 'Failed to load consents');
  }

  /// Accept consent
  Future<void> acceptConsent(String type) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    final response = await _apiClient.post(
      '${ApiConfig.consentAccept}?type=$type',
      data: {},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to accept consent');
    }
  }

  /// Withdraw consent
  Future<void> withdrawConsent(String type) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    final response = await _apiClient.post(
      '${ApiConfig.consentWithdraw}?type=$type',
      data: {},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to withdraw consent');
    }
  }

  // Mock content
  String _getMockDisclaimer() {
    return '''
LEGAL DISCLAIMER

Last Updated: January 2025

This application is provided for informational and educational purposes only. The information provided through this application is not intended to be a substitute for professional medical advice, diagnosis, or treatment.

1. NOT MEDICAL ADVICE
The content, features, and functionality of this application do not constitute medical advice and should not be relied upon for medical diagnosis or treatment.

2. CONSULT YOUR DOCTOR
Always seek the advice of your physician or other qualified health provider with any questions you may have regarding a medical condition or treatment.

3. NO DOCTOR-PATIENT RELATIONSHIP
Use of this application does not create a doctor-patient relationship between you and ScolioCare or any healthcare provider.

4. EMERGENCY SITUATIONS
If you think you may have a medical emergency, call your doctor or emergency services immediately.

5. ACCURACY OF INFORMATION
While we strive to provide accurate information, we make no representations or warranties about the accuracy, reliability, completeness, or timeliness of the content.

6. AI LIMITATIONS
The AI-powered analysis is a tool to assist in assessment but is not a substitute for professional medical evaluation.

By using this application, you acknowledge that you have read, understood, and agree to this disclaimer.
''';
  }

  String _getMockTerms() {
    return '''
TERMS OF SERVICE

Last Updated: January 2025

1. ACCEPTANCE OF TERMS
By accessing and using the ScolioCare application, you accept and agree to be bound by these Terms of Service.

2. DESCRIPTION OF SERVICE
ScolioCare provides a mobile application for scoliosis care management, including:
- Spine image analysis using AI technology
- Exercise program management
- Progress tracking
- Educational resources

3. USER ACCOUNT
3.1 You must create an account to use certain features
3.2 You are responsible for maintaining the confidentiality of your account
3.3 You must provide accurate and complete information

4. USER RESPONSIBILITIES
4.1 You agree to use the service only for lawful purposes
4.2 You will not misuse or interfere with the service
4.3 You are responsible for all activity under your account

5. PRIVACY
Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information.

6. INTELLECTUAL PROPERTY
All content, features, and functionality are owned by ScolioCare and protected by copyright and other intellectual property laws.

7. LIMITATION OF LIABILITY
ScolioCare shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of the service.

8. MODIFICATIONS
We reserve the right to modify these terms at any time. Continued use of the service constitutes acceptance of modified terms.

9. TERMINATION
We may terminate or suspend your account at any time for violation of these terms.

10. GOVERNING LAW
These terms shall be governed by and construed in accordance with applicable laws.

11. CONTACT
For questions about these terms, contact us at support@scoliocare.app

By using ScolioCare, you acknowledge that you have read, understood, and agree to be bound by these Terms of Service.
''';
  }

  String _getMockMedicalDisclaimer() {
    return '''
MEDICAL DISCLAIMER

IMPORTANT: PLEASE READ CAREFULLY

ScolioCare is NOT a medical device and is NOT intended to diagnose, treat, cure, or prevent any disease or medical condition.

1. EDUCATIONAL PURPOSE ONLY
This application is designed for educational and informational purposes to help users manage their scoliosis care under the guidance of healthcare professionals.

2. NOT A SUBSTITUTE FOR PROFESSIONAL CARE
• This app does NOT replace visits to your doctor or physical therapist
• Do NOT use this app to make medical decisions without consulting a healthcare provider
• Do NOT delay seeking medical advice because of information from this app

3. AI ANALYSIS LIMITATIONS
The AI-powered spine analysis feature:
• Is a screening tool only, not a diagnostic tool
• May produce false positives or false negatives
• Requires professional medical interpretation
• Should be confirmed by a licensed healthcare provider

4. EXERCISE PROGRAMS
The exercise programs provided:
• Are general recommendations only
• Should be reviewed by your physical therapist before starting
• May not be suitable for your specific condition
• Should be stopped immediately if you experience pain or discomfort

5. EMERGENCIES
If you experience:
• Severe back pain
• Numbness or tingling in extremities
• Loss of bowel or bladder control
• Progressive weakness

STOP using the app and SEEK IMMEDIATE MEDICAL ATTENTION.

6. USER RESPONSIBILITY
By using this application, you:
• Acknowledge that you understand these limitations
• Agree to consult with healthcare professionals before making health decisions
• Accept full responsibility for how you use the information provided

7. NO GUARANTEES
We make NO guarantees about:
• The accuracy of AI analysis
• Treatment outcomes
• Improvement in your condition

8. AGE RESTRICTIONS
If you are under 18, you must have parental consent to use this app.

BY ACCEPTING THIS DISCLAIMER, YOU ACKNOWLEDGE THAT:
✓ You have read and understood all limitations
✓ You will consult healthcare professionals before making medical decisions
✓ You understand this is NOT a medical device
✓ You accept full responsibility for your use of this application

If you DO NOT agree with this medical disclaimer, you should NOT use this application.

For questions or concerns, contact: medical@scoliocare.app

Version: 1.0
Effective Date: January 1, 2025
''';
  }
}
