import 'package:flutter/foundation.dart';

/// Model for posture photo data
class PosturePhoto {
  final String id;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime capturedAt;
  final String viewAngle; // FRONT, BACK, LEFT, RIGHT
  final String? notes;
  final Map<String, dynamic>? metadata;

  PosturePhoto({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.capturedAt,
    required this.viewAngle,
    this.notes,
    this.metadata,
  });

  factory PosturePhoto.fromJson(Map<String, dynamic> json) {
    return PosturePhoto(
      id: json['id'] ?? json['posturePhotoId'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? json['filePath'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      capturedAt: json['capturedAt'] != null
          ? DateTime.parse(json['capturedAt'])
          : DateTime.now(),
      viewAngle: json['viewAngle'] ?? 'FRONT',
      notes: json['notes'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'capturedAt': capturedAt.toIso8601String(),
      'viewAngle': viewAngle,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

/// Model for posture photo comparison
class PostureComparison {
  final String id;
  final String userId;
  final PosturePhoto beforePhoto;
  final PosturePhoto afterPhoto;
  final DateTime comparisonDate;
  final Map<String, dynamic>? analysisResult;
  final double? improvementScore;
  final String? notes;

  PostureComparison({
    required this.id,
    required this.userId,
    required this.beforePhoto,
    required this.afterPhoto,
    required this.comparisonDate,
    this.analysisResult,
    this.improvementScore,
    this.notes,
  });

  factory PostureComparison.fromJson(Map<String, dynamic> json) {
    return PostureComparison(
      id: json['id'] ?? json['comparisonId'] ?? '',
      userId: json['userId'] ?? '',
      beforePhoto: PosturePhoto.fromJson(json['beforePhoto'] ?? {}),
      afterPhoto: PosturePhoto.fromJson(json['afterPhoto'] ?? {}),
      comparisonDate: json['comparisonDate'] != null
          ? DateTime.parse(json['comparisonDate'])
          : DateTime.now(),
      analysisResult: json['analysisResult'],
      improvementScore: json['improvementScore']?.toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'beforePhoto': beforePhoto.toJson(),
      'afterPhoto': afterPhoto.toJson(),
      'comparisonDate': comparisonDate.toIso8601String(),
      'analysisResult': analysisResult,
      'improvementScore': improvementScore,
      'notes': notes,
    };
  }
}
