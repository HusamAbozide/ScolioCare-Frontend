class UserProfileResponse {
  final String profileId;
  final String userId;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final double? heightCm;
  final double? weightKg;
  final String? medicalHistory;
  final String? weaknessAreas;
  final String? activityLevel;
  final Map<String, dynamic>? initialAssessment;
  final DateTime? assessmentCompletedAt;

  UserProfileResponse({
    required this.profileId,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.heightCm,
    this.weightKg,
    this.medicalHistory,
    this.weaknessAreas,
    this.activityLevel,
    this.initialAssessment,
    this.assessmentCompletedAt,
  });

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      profileId: json['profileId'] as String,
      userId: json['userId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      gender: json['gender'] as String,
      heightCm: json['heightCm'] as double?,
      weightKg: json['weightKg'] as double?,
      medicalHistory: json['medicalHistory'] as String?,
      weaknessAreas: json['weaknessAreas'] as String?,
      activityLevel: json['activityLevel'] as String?,
      initialAssessment: json['initialAssessment'] as Map<String, dynamic>?,
      assessmentCompletedAt: json['assessmentCompletedAt'] != null
          ? DateTime.parse(json['assessmentCompletedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'profileId': profileId,
        'userId': userId,
        'firstName': firstName,
        'lastName': lastName,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'medicalHistory': medicalHistory,
        'weaknessAreas': weaknessAreas,
        'activityLevel': activityLevel,
        'initialAssessment': initialAssessment,
        'assessmentCompletedAt': assessmentCompletedAt?.toIso8601String(),
      };
}
