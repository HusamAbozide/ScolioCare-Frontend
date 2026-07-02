class UserProfileResponse {
  final String? profileId;
  final String? userId;
  final String firstName;
  final String lastName;
  final String? email;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? medicalHistory;
  final String? weaknessAreas;
  final String? activityLevel;
  final Map<String, dynamic>? initialAssessment;
  final DateTime? assessmentCompletedAt;

  UserProfileResponse({
    this.profileId,
    this.userId,
    required this.firstName,
    required this.lastName,
    this.email,
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
    final height = json['heightCm'] ?? json['height'];
    final weight = json['weightKg'] ?? json['weight'];
    final weaknessAreas = json['weaknessAreas'];

    return UserProfileResponse(
      profileId: json['profileId'] as String?,
      userId: json['userId'] as String?,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      heightCm: height is num ? height.toDouble() : null,
      weightKg: weight is num ? weight.toDouble() : null,
      medicalHistory: json['medicalHistory'] as String?,
      weaknessAreas: weaknessAreas is List
          ? weaknessAreas.join(',')
          : weaknessAreas as String?,
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
        'email': email,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
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
