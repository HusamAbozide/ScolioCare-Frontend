import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/reward/reward.dart';

class RewardService {
  final ApiClient _apiClient;

  RewardService(this._apiClient);

  /// Get rewards catalog
  Future<List<Reward>> getCatalog() async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockCatalog();
    }

    final response = await _apiClient.get(
      ApiConfig.rewardsCatalog,
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => Reward.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  /// Get user rewards
  Future<List<UserReward>> getUserRewards(String userId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockUserRewards();
    }

    final response = await _apiClient.get(
      '${ApiConfig.userRewards}/$userId',
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => UserReward.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  // Mock data generators
  List<Reward> _generateMockCatalog() {
    return [
      Reward(
        rewardId: 'reward-1',
        name: '7-Day Streak',
        description: 'Complete exercises for 7 consecutive days',
        type: 'MILESTONE',
        points: 50,
        badgeIconUrl: null,
        streakThreshold: 7,
      ),
      Reward(
        rewardId: 'reward-2',
        name: '30-Day Streak',
        description: 'Complete exercises for 30 consecutive days',
        type: 'MILESTONE',
        points: 200,
        badgeIconUrl: null,
        streakThreshold: 30,
      ),
      Reward(
        rewardId: 'reward-3',
        name: 'First Scan',
        description: 'Upload your first spine image',
        type: 'ACHIEVEMENT',
        points: 10,
        badgeIconUrl: null,
        streakThreshold: null,
      ),
      Reward(
        rewardId: 'reward-4',
        name: 'Progress Tracker',
        description: 'Track your progress for the first time',
        type: 'ACHIEVEMENT',
        points: 10,
        badgeIconUrl: null,
        streakThreshold: null,
      ),
      Reward(
        rewardId: 'reward-5',
        name: '100 Exercises',
        description: 'Complete 100 exercises in total',
        type: 'MILESTONE',
        points: 150,
        badgeIconUrl: null,
        streakThreshold: null,
      ),
      Reward(
        rewardId: 'reward-6',
        name: 'Early Bird',
        description: 'Complete 10 exercises before 9 AM',
        type: 'BADGE',
        points: 30,
        badgeIconUrl: null,
        streakThreshold: null,
      ),
    ];
  }

  List<UserReward> _generateMockUserRewards() {
    final now = DateTime.now();
    return [
      UserReward(
        id: 'user-reward-1',
        userId: 'mock-user-123',
        reward: Reward(
          rewardId: 'reward-1',
          name: '7-Day Streak',
          description: 'Complete exercises for 7 consecutive days',
          type: 'MILESTONE',
          points: 50,
          badgeIconUrl: null,
          streakThreshold: 7,
        ),
        earnedAt: now.subtract(const Duration(days: 5)),
        streakCount: 7,
      ),
      UserReward(
        id: 'user-reward-2',
        userId: 'mock-user-123',
        reward: Reward(
          rewardId: 'reward-3',
          name: 'First Scan',
          description: 'Upload your first spine image',
          type: 'ACHIEVEMENT',
          points: 10,
          badgeIconUrl: null,
          streakThreshold: null,
        ),
        earnedAt: now.subtract(const Duration(days: 20)),
        streakCount: null,
      ),
    ];
  }
}
