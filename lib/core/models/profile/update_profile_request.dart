class UpdateProfileRequest {
  final String? firstName;
  final String? lastName;
  final String? medicalHistory;
  final String? weaknessAreas;

  UpdateProfileRequest({
    this.firstName,
    this.lastName,
    this.medicalHistory,
    this.weaknessAreas,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['firstName'] = firstName;
    if (lastName != null) map['lastName'] = lastName;
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
        'heightCm': heightCm,
        'weightKg': weightKg,
      };
}

class AssessmentSubmitRequest {
  final Map<String, dynamic> answers;

  AssessmentSubmitRequest({required this.answers});

  Map<String, dynamic> toJson() => {
        'answers': answers.entries
            .map((e) => {'questionId': e.key, 'answer': e.value})
            .toList(),
      };
}
