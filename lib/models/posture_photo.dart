/// Model for posture photo data
class PosturePhoto {
  final String id;
  final String userId;
  final String imageUrl;
  final String? thumbnailUrl;
  final DateTime capturedAt;
  final String viewAngle; // FRONT, BACK, LEFT, RIGHT
  final String? name;
  final String? notes;
  final Map<String, dynamic>? metadata;

  PosturePhoto({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.thumbnailUrl,
    required this.capturedAt,
    required this.viewAngle,
    this.name,
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
      name: json['name']?.toString() ?? _extractName(rawNotes),
      notes: _extractNotes(rawNotes),
      metadata: json['metadata'],
    );
  }

  static String _extractViewAngle(String? notes) {
    final prefix = notes?.split('|').first.toUpperCase();
    const validAngles = {'FRONT', 'BACK', 'LEFT', 'RIGHT'};
    return validAngles.contains(prefix) ? prefix! : 'FRONT';
  }

  static String? _extractName(String? notes) {
    final parsed = _parseNotes(notes);
    return parsed.name;
  }

  static String? _extractNotes(String? notes) {
    final parsed = _parseNotes(notes);
    return parsed.notes;
  }

  static _ParsedPostureNotes _parseNotes(String? notes) {
    if (notes == null) return const _ParsedPostureNotes(null, null);
    if (!notes.contains('|')) return _ParsedPostureNotes(null, notes);
    final parts = notes.split('|');
    if (parts.length < 2) return _ParsedPostureNotes(null, notes);
    final prefix = parts.first.toUpperCase();
    const validAngles = {'FRONT', 'BACK', 'LEFT', 'RIGHT'};
    if (!validAngles.contains(prefix)) return _ParsedPostureNotes(null, notes);
    if (parts.length == 2) {
      final legacyNotes = parts[1].trim();
      return _ParsedPostureNotes(null, legacyNotes.isEmpty ? null : legacyNotes);
    }

    final name = parts[1].trim();
    final stripped = parts.sublist(2).join('|').trim();
    return _ParsedPostureNotes(
      name.isEmpty ? null : name,
      stripped.isEmpty ? null : stripped,
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
      'name': name,
      'notes': notes,
      'metadata': metadata,
    };
  }
}

class _ParsedPostureNotes {
  final String? name;
  final String? notes;

  const _ParsedPostureNotes(this.name, this.notes);
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
