class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? activityLevel;
  final String? medicalHistory;
  final String? weaknessAreas;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.activityLevel,
    this.medicalHistory,
    this.weaknessAreas,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
    if (dateOfBirth != null) map['dateOfBirth'] = dateOfBirth;
    if (gender != null) map['gender'] = gender;
    if (activityLevel != null) map['activityLevel'] = activityLevel;
    if (medicalHistory != null) map['medicalHistory'] = medicalHistory;
    if (weaknessAreas != null) map['weaknessAreas'] = weaknessAreas;
    return map;
  }
}

class UpdateVitalsRequest {
  final double heightCm;
  final double weightKg;

  UpdateVitalsRequest({
    required this.heightCm,
    required this.weightKg,
  });

  Map<String, dynamic> toJson() => {
        'height': heightCm,
        'weight': weightKg,
      };
}

class AssessmentSubmitRequest {
  final Map<String, dynamic> answers;

  AssessmentSubmitRequest({required this.answers});

  Map<String, dynamic> toJson() => {
        'answers': answers.map((key, value) => MapEntry(key, value.toString())),
      };
}
