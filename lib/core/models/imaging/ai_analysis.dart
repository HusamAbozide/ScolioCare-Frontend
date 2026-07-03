class AIAnalysis {
  final String analysisId;
  final String imageId;
  final String userId;
  final String? modelVersionId;
  final String status;
  final double? confidenceScore;
  final double? processingTimeSeconds;
  final String? summaryText;
  final DateTime? analyzedAt;
  final DateTime? createdAt;
  final String? errorMessage;
  final SeverityClassification? severity;
  final CurveDetection? curve;

  AIAnalysis({
    required this.analysisId,
    required this.imageId,
    required this.userId,
    this.modelVersionId,
    required this.status,
    this.confidenceScore,
    this.processingTimeSeconds,
    this.summaryText,
    this.analyzedAt,
    this.createdAt,
    this.errorMessage,
    this.severity,
    this.curve,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      analysisId: json['analysisId'] as String,
      imageId: json['imageId'] as String,
      userId: json['userId'] as String,
      modelVersionId:
          (json['modelVersionId'] ?? json['modelVersion']) as String?,
      status: json['status'] as String,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ??
          ((json['severity'] as Map<String, dynamic>?)?['confidenceScore']
                  as num?)
              ?.toDouble(),
      processingTimeSeconds:
          (json['processingTimeSeconds'] as num?)?.toDouble(),
      summaryText: json['summaryText'] as String?,
      analyzedAt: (json['completedAt'] ?? json['analyzedAt']) != null
          ? DateTime.parse(
              (json['completedAt'] ?? json['analyzedAt']) as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      severity: json['severity'] != null
          ? SeverityClassification.fromJson(
              json['severity'] as Map<String, dynamic>)
          : null,
      curve: json['curve'] != null
          ? CurveDetection.fromJson(json['curve'] as Map<String, dynamic>)
          : null,
    );
  }
}

class SeverityClassification {
  final String severityId;
  final String? analysisId;
  final String severityLevel;
  final double? confidenceScore;
  final String? classificationNotes;
  final DateTime? classifiedAt;

  SeverityClassification({
    required this.severityId,
    this.analysisId,
    required this.severityLevel,
    this.confidenceScore,
    this.classificationNotes,
    this.classifiedAt,
  });

  factory SeverityClassification.fromJson(Map<String, dynamic> json) {
    return SeverityClassification(
      severityId:
          (json['severityId'] ?? json['classificationId'] ?? '') as String,
      analysisId: json['analysisId'] as String?,
      severityLevel: json['severityLevel'] as String,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      classificationNotes: json['classificationNotes'] as String?,
      classifiedAt: json['classifiedAt'] != null
          ? DateTime.parse(json['classifiedAt'] as String)
          : null,
    );
  }
}

class CurveDetection {
  final String curveId;
  final String? analysisId;
  final String curveType;
  final double? cobbAngleDegrees;
  final String? rawOutput;
  final DateTime? classifiedAt;

  CurveDetection({
    required this.curveId,
    this.analysisId,
    required this.curveType,
    this.cobbAngleDegrees,
    this.rawOutput,
    this.classifiedAt,
  });

  factory CurveDetection.fromJson(Map<String, dynamic> json) {
    return CurveDetection(
      curveId: (json['curveId'] ?? json['detectionId'] ?? '') as String,
      analysisId: json['analysisId'] as String?,
      curveType: json['curveType'] as String,
      cobbAngleDegrees: (json['cobbAngleDegrees'] as num?)?.toDouble(),
      rawOutput: json['rawOutput'] as String?,
      classifiedAt: json['classifiedAt'] != null
          ? DateTime.parse(json['classifiedAt'] as String)
          : null,
    );
  }
}
