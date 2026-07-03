class ProgressTracking {
  final String progressId;
  final String userId;
  final String? planId;
  final DateTime trackingDate;
  final double overallProgressPercentage;
  final String? progressNotes;
  final String source;
  final DateTime createdAt;

  ProgressTracking({
    required this.progressId,
    required this.userId,
    this.planId,
    required this.trackingDate,
    required this.overallProgressPercentage,
    this.progressNotes,
    required this.source,
    required this.createdAt,
  });

  factory ProgressTracking.fromJson(Map<String, dynamic> json) {
    return ProgressTracking(
      progressId: json['progressId'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String?,
      trackingDate: DateTime.parse(json['trackingDate'] as String),
      overallProgressPercentage:
          (json['overallProgressPercentage'] as num).toDouble(),
      progressNotes: json['progressNotes'] as String?,
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'progressId': progressId,
        'userId': userId,
        'planId': planId,
        'trackingDate': trackingDate.toIso8601String(),
        'overallProgressPercentage': overallProgressPercentage,
        'progressNotes': progressNotes,
        'source': source,
        'createdAt': createdAt.toIso8601String(),
      };
}

class PainLevelTracking {
  final String painTrackingId;
  final String progressId;
  final int painLevel;
  final String? painLocation;
  final String? painDescription;
  final DateTime recordedAt;

  PainLevelTracking({
    required this.painTrackingId,
    required this.progressId,
    required this.painLevel,
    this.painLocation,
    this.painDescription,
    required this.recordedAt,
  });

  factory PainLevelTracking.fromJson(Map<String, dynamic> json) {
    return PainLevelTracking(
      painTrackingId: json['painTrackingId'] as String,
      progressId: json['progressId'] as String,
      painLevel: json['painLevel'] as int,
      painLocation: json['painLocation'] as String?,
      painDescription: json['painDescription'] as String?,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'progressId': progressId,
        'painLevel': painLevel,
        'painLocation': painLocation,
        'painDescription': painDescription,
      };
}

class ScoliometerReading {
  final String readingId;
  final String progressId;
  final double readingValue;
  final String unit;
  final String? bodyPositionNotes;
  final DateTime capturedAt;

  ScoliometerReading({
    required this.readingId,
    required this.progressId,
    required this.readingValue,
    required this.unit,
    this.bodyPositionNotes,
    required this.capturedAt,
  });

  factory ScoliometerReading.fromJson(Map<String, dynamic> json) {
    return ScoliometerReading(
      readingId: json['readingId'] as String,
      progressId: json['progressId'] as String,
      readingValue: (json['readingValue'] as num).toDouble(),
      unit: json['unit'] as String,
      bodyPositionNotes: json['bodyPositionNotes'] as String?,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'progressId': progressId,
        'readingValue': readingValue,
        'unit': unit,
        'bodyPositionNotes': bodyPositionNotes,
      };
}

class PosturePhoto {
  final String photoId;
  final String userId;
  final String photoUrl;
  final String view;
  final DateTime takenAt;
  final String monthTag;
  final String? notes;

  PosturePhoto({
    required this.photoId,
    required this.userId,
    required this.photoUrl,
    required this.view,
    required this.takenAt,
    required this.monthTag,
    this.notes,
  });

  factory PosturePhoto.fromJson(Map<String, dynamic> json) {
    return PosturePhoto(
      photoId: json['photoId'] as String,
      userId: json['userId'] as String,
      photoUrl: json['photoUrl'] as String,
      view: json['view'] as String,
      takenAt: DateTime.parse(json['takenAt'] as String),
      monthTag: json['monthTag'] as String,
      notes: json['notes'] as String?,
    );
  }
}

class ImageComparison {
  final String comparisonId;
  final String progressId;
  final String oldPhotoId;
  final String newPhotoId;
  final String? comparisonNotes;
  final DateTime comparedAt;

  ImageComparison({
    required this.comparisonId,
    required this.progressId,
    required this.oldPhotoId,
    required this.newPhotoId,
    this.comparisonNotes,
    required this.comparedAt,
  });

  factory ImageComparison.fromJson(Map<String, dynamic> json) {
    return ImageComparison(
      comparisonId: json['comparisonId'] as String,
      progressId: json['progressId'] as String,
      oldPhotoId: json['oldPhotoId'] as String,
      newPhotoId: json['newPhotoId'] as String,
      comparisonNotes: json['comparisonNotes'] as String?,
      comparedAt: DateTime.parse(json['comparedAt'] as String),
    );
  }
}
