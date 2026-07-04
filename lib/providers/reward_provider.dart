import 'package:flutter/material.dart';
import '../core/services/reward_service.dart';
import '../core/models/reward/reward.dart';

class RewardProvider extends ChangeNotifier {
  final RewardService _rewardService;

  List<Reward> _catalog = [];
  List<UserReward> _userRewards = [];
  bool _isLoading = false;
  String? _error;
  int _totalPoints = 0;

  RewardProvider(this._rewardService);

  List<Reward> get catalog => List.unmodifiable(_catalog);
  List<UserReward> get userRewards => List.unmodifiable(_userRewards);
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalPoints => _totalPoints;

  int get totalRewardsEarned => _userRewards.length;

  Future<void> loadCatalog() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _catalog = await _rewardService.getCatalog();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load rewards catalog: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserRewards(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userRewards = await _rewardService.getUserRewards(userId);
      _totalPoints = await _rewardService.getUserBalance(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load user rewards: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  bool isRewardEarned(String rewardId) {
    return _userRewards.any((ur) => ur.reward.rewardId == rewardId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
