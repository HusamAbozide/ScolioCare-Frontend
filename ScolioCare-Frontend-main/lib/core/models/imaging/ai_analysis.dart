class AIAnalysis {
  final String analysisId;
  final String imageId;
  final String userId;
  final String modelVersionId;
  final String status;
  final double? confidenceScore;
  final double? processingTimeSeconds;
  final Map<String, dynamic>? rawOutput;
  final DateTime? analyzedAt;
  final String? errorMessage;
  final SeverityClassification? severity;
  final CurveDetection? curve;

  AIAnalysis({
    required this.analysisId,
    required this.imageId,
    required this.userId,
    required this.modelVersionId,
    required this.status,
    this.confidenceScore,
    this.processingTimeSeconds,
    this.rawOutput,
    this.analyzedAt,
    this.errorMessage,
    this.severity,
    this.curve,
  });

  factory AIAnalysis.fromJson(Map<String, dynamic> json) {
    return AIAnalysis(
      analysisId: json['analysisId'] as String,
      imageId: json['imageId'] as String,
      userId: json['userId'] as String,
      modelVersionId: json['modelVersionId'] as String,
      status: json['status'] as String,
      confidenceScore: json['confidenceScore'] as double?,
      processingTimeSeconds: json['processingTimeSeconds'] as double?,
      rawOutput: json['rawOutput'] as Map<String, dynamic>?,
      analyzedAt: json['analyzedAt'] != null
          ? DateTime.parse(json['analyzedAt'] as String)
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
  final String analysisId;
  final String severityLevel;
  final String? classificationNotes;
  final DateTime classifiedAt;

  SeverityClassification({
    required this.severityId,
    required this.analysisId,
    required this.severityLevel,
    this.classificationNotes,
    required this.classifiedAt,
  });

  factory SeverityClassification.fromJson(Map<String, dynamic> json) {
    return SeverityClassification(
      severityId: json['severityId'] as String,
      analysisId: json['analysisId'] as String,
      severityLevel: json['severityLevel'] as String,
      classificationNotes: json['classificationNotes'] as String?,
      classifiedAt: DateTime.parse(json['classifiedAt'] as String),
    );
  }
}

class CurveDetection {
  final String curveId;
  final String analysisId;
  final String curveType;
  final DateTime classifiedAt;

  CurveDetection({
    required this.curveId,
    required this.analysisId,
    required this.curveType,
    required this.classifiedAt,
  });

  factory CurveDetection.fromJson(Map<String, dynamic> json) {
    return CurveDetection(
      curveId: json['curveId'] as String,
      analysisId: json['analysisId'] as String,
      curveType: json['curveType'] as String,
      classifiedAt: DateTime.parse(json['classifiedAt'] as String),
    );
  }
}
