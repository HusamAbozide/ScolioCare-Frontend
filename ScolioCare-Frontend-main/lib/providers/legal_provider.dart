import 'package:flutter/material.dart';
import '../core/services/legal_service.dart';
import '../core/models/legal/legal_text.dart';

class LegalProvider extends ChangeNotifier {
  final LegalService _legalService;

  LegalText? _disclaimer;
  LegalText? _terms;
  MedicalDisclaimer? _medicalDisclaimer;
  bool _isLoading = false;
  String? _error;

  // Consent tracking
  final Map<String, bool> _consents = {};

  LegalProvider(this._legalService);

  LegalText? get disclaimer => _disclaimer;
  LegalText? get terms => _terms;
  MedicalDisclaimer? get medicalDisclaimer => _medicalDisclaimer;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isConsentGiven(String type) => _consents[type] ?? false;

  Future<void> loadDisclaimer() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _disclaimer = await _legalService.getDisclaimer();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load disclaimer: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTerms() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _terms = await _legalService.getTerms();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load terms: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedicalDisclaimer() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _medicalDisclaimer = await _legalService.getMedicalDisclaimer();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load medical disclaimer: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> acceptConsent(String type) async {
    try {
      await _legalService.acceptConsent(type);
      _consents[type] = true;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to accept consent: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdrawConsent(String type) async {
    try {
      await _legalService.withdrawConsent(type);
      _consents[type] = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to withdraw consent: $e';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
