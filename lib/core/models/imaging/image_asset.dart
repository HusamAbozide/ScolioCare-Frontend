class ImageAsset {
  final String imageId;
  final String userId;
  final String imageUrl;
  final String imageHash;
  final String captureMethod;
  final Map<String, dynamic>? qualityMetrics;
  final bool isValid;
  final DateTime submittedAt;
  final bool isDeleted;

  ImageAsset({
    required this.imageId,
    required this.userId,
    required this.imageUrl,
    required this.imageHash,
    required this.captureMethod,
    this.qualityMetrics,
    required this.isValid,
    required this.submittedAt,
    required this.isDeleted,
  });

  factory ImageAsset.fromJson(Map<String, dynamic> json) {
    return ImageAsset(
      imageId: json['imageId'] as String,
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      imageHash: json['imageHash'] as String,
      captureMethod: json['captureMethod'] as String,
      qualityMetrics: json['qualityMetrics'] as Map<String, dynamic>?,
      isValid: json['isValid'] as bool,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'imageId': imageId,
        'userId': userId,
        'imageUrl': imageUrl,
        'imageHash': imageHash,
        'captureMethod': captureMethod,
        'qualityMetrics': qualityMetrics,
        'isValid': isValid,
        'submittedAt': submittedAt.toIso8601String(),
        'isDeleted': isDeleted,
      };
}
