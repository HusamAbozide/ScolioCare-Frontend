class Report {
  final String reportId;
  final String analysisId;
  final DateTime generatedAt;
  final String severityLevel;
  final String curveType;
  final double confidenceScore;
  final Map<String, dynamic> summaryJson;
  final String disclaimerText;
  final String? reportNotes;
  final String pdfUrl;
  final String status;

  Report({
    required this.reportId,
    required this.analysisId,
    required this.generatedAt,
    required this.severityLevel,
    required this.curveType,
    required this.confidenceScore,
    required this.summaryJson,
    required this.disclaimerText,
    this.reportNotes,
    required this.pdfUrl,
    required this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'] as String,
      analysisId: json['analysisId'] as String,
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      severityLevel: json['severityLevel'] as String,
      curveType: json['curveType'] as String,
      confidenceScore: (json['confidenceScore'] as num).toDouble(),
      summaryJson: json['summaryJson'] as Map<String, dynamic>,
      disclaimerText: json['disclaimerText'] as String,
      reportNotes: json['reportNotes'] as String?,
      pdfUrl: json['pdfUrl'] as String,
      status: json['status'] as String? ?? 'COMPLETED',
    );
  }

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'analysisId': analysisId,
        'generatedAt': generatedAt.toIso8601String(),
        'severityLevel': severityLevel,
        'curveType': curveType,
        'confidenceScore': confidenceScore,
        'summaryJson': summaryJson,
        'disclaimerText': disclaimerText,
        'reportNotes': reportNotes,
        'pdfUrl': pdfUrl,
        'status': status,
      };
}
