class Reward {
  final String rewardId;
  final String name;
  final String? description;
  final String type; // BADGE, MILESTONE, ACHIEVEMENT
  final int points;
  final String? badgeIconUrl;
  final int? streakThreshold;

  Reward({
    required this.rewardId,
    required this.name,
    this.description,
    required this.type,
    required this.points,
    this.badgeIconUrl,
    this.streakThreshold,
  });

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      rewardId: json['rewardId']?.toString() ?? '',
      name: json['name'] as String? ?? 'Reward',
      description: json['description'] as String?,
      type: json['type']?.toString() ?? 'ACHIEVEMENT',
      points: (json['points'] as num?)?.toInt() ?? 0,
      badgeIconUrl: json['badgeIconUrl'] as String?,
      streakThreshold: (json['streakThreshold'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rewardId': rewardId,
      'name': name,
      'description': description,
      'type': type,
      'points': points,
      'badgeIconUrl': badgeIconUrl,
      'streakThreshold': streakThreshold,
    };
  }
}

class UserReward {
  final String id;
  final String userId;
  final Reward reward;
  final DateTime earnedAt;
  final int? streakCount;

  UserReward({
    required this.id,
    required this.userId,
    required this.reward,
    required this.earnedAt,
    this.streakCount,
  });

  factory UserReward.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userId = json['userId'] ??
        (user is Map<String, dynamic> ? user['userId'] : null);
    final rewardJson = json['reward'] is Map<String, dynamic>
        ? json['reward'] as Map<String, dynamic>
        : <String, dynamic>{
            'rewardId': json['rewardId'],
            'name': json['name'],
            'description': json['description'],
            'type': json['type'],
            'points': json['points'],
            'badgeIconUrl': json['badgeIconUrl'],
            'streakThreshold': json['streakThreshold'],
          };
    return UserReward(
      id: json['id']?.toString() ?? '',
      userId: userId?.toString() ?? '',
      reward: Reward.fromJson(rewardJson),
      earnedAt: json['earnedAt'] != null
          ? DateTime.tryParse(json['earnedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      streakCount: (json['streakCount'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'reward': reward.toJson(),
      'earnedAt': earnedAt.toIso8601String(),
      'streakCount': streakCount,
    };
  }
}
