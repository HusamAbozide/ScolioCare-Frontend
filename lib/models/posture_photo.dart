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
    final id = json['id'] ?? json['posturePhotoId'] ?? json['photoId'];
    final imageUrl = json['imageUrl'] ?? json['photoUrl'] ?? json['filePath'];
    final capturedAt = json['capturedAt'] ?? json['takenAt'];
    final rawNotes = json['notes']?.toString();
    final parsedView = _extractViewAngle(rawNotes);
    return PosturePhoto(
      id: id?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      imageUrl: imageUrl?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      capturedAt: capturedAt != null
          ? DateTime.tryParse(capturedAt.toString()) ?? DateTime.now()
          : DateTime.now(),
      viewAngle:
          json['viewAngle']?.toString() ?? json['view']?.toString() ?? parsedView,
      notes: _stripViewAnglePrefix(rawNotes),
      metadata: json['metadata'],
    );
  }

  static String _extractViewAngle(String? notes) {
    final prefix = notes?.split('|').first.toUpperCase();
    const validAngles = {'FRONT', 'BACK', 'LEFT', 'RIGHT'};
    return validAngles.contains(prefix) ? prefix! : 'FRONT';
  }

  static String? _stripViewAnglePrefix(String? notes) {
    if (notes == null || !notes.contains('|')) return notes;
    final parts = notes.split('|');
    if (parts.length < 2) return notes;
    final prefix = parts.first.toUpperCase();
    const validAngles = {'FRONT', 'BACK', 'LEFT', 'RIGHT'};
    if (!validAngles.contains(prefix)) return notes;
    final stripped = parts.sublist(1).join('|').trim();
    return stripped.isEmpty ? null : stripped;
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
    final before = json['beforePhoto'] ?? json['photoBefore'] ?? {};
    final after = json['afterPhoto'] ?? json['photoAfter'] ?? {};
    final comparisonDate = json['comparisonDate'] ??
        json['comparedAt'] ??
        json['createdAt'];
    return PostureComparison(
      id: json['id']?.toString() ?? json['comparisonId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      beforePhoto: PosturePhoto.fromJson(before as Map<String, dynamic>),
      afterPhoto: PosturePhoto.fromJson(after as Map<String, dynamic>),
      comparisonDate: comparisonDate != null
          ? DateTime.tryParse(comparisonDate.toString()) ?? DateTime.now()
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
