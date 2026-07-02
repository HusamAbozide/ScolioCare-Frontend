class LegalText {
  final String content;
  final String version;
  final DateTime effectiveDate;

  LegalText({
    required this.content,
    required this.version,
    required this.effectiveDate,
  });

  factory LegalText.fromJson(Map<String, dynamic> json) {
    return LegalText(
      content: json['content'] as String,
      version: json['version'] as String,
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'version': version,
      'effectiveDate': effectiveDate.toIso8601String(),
    };
  }
}

class MedicalDisclaimer {
  final String disclaimerId;
  final String content;
  final String version;
  final DateTime effectiveDate;
  final bool isActive;

  MedicalDisclaimer({
    required this.disclaimerId,
    required this.content,
    required this.version,
    required this.effectiveDate,
    required this.isActive,
  });

  factory MedicalDisclaimer.fromJson(Map<String, dynamic> json) {
    return MedicalDisclaimer(
      disclaimerId: json['disclaimerId'] as String,
      content: json['content'] as String,
      version: json['version'] as String,
      effectiveDate: DateTime.parse(json['effectiveDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disclaimerId': disclaimerId,
      'content': content,
      'version': version,
      'effectiveDate': effectiveDate.toIso8601String(),
      'isActive': isActive,
    };
  }
}
