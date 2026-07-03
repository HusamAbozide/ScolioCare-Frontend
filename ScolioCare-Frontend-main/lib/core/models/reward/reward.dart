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
      rewardId: json['rewardId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      points: json['points'] as int,
      badgeIconUrl: json['badgeIconUrl'] as String?,
      streakThreshold: json['streakThreshold'] as int?,
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
    return UserReward(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user']?['userId'] as String,
      reward: Reward.fromJson(json['reward'] as Map<String, dynamic>),
      earnedAt: DateTime.parse(json['earnedAt'] as String),
      streakCount: json['streakCount'] as int?,
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
