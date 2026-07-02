class UserProfile {
  final String name;
  final String email;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? avatar;
  final String? diagnosisTime;
  final String? scoliosisType;
  final String? currentTreatment;
  final List<String> weaknessAreas;
  final int flexibilityLevel;
  final int activityLevel;
  final int painLevel;

  const UserProfile({
    required this.name,
    required this.email,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.avatar,
    this.diagnosisTime,
    this.scoliosisType,
    this.currentTreatment,
    this.weaknessAreas = const [],
    this.flexibilityLevel = 5,
    this.activityLevel = 5,
    this.painLevel = 3,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? avatar,
    String? diagnosisTime,
    String? scoliosisType,
    String? currentTreatment,
    List<String>? weaknessAreas,
    int? flexibilityLevel,
    int? activityLevel,
    int? painLevel,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      avatar: avatar ?? this.avatar,
      diagnosisTime: diagnosisTime ?? this.diagnosisTime,
      scoliosisType: scoliosisType ?? this.scoliosisType,
      currentTreatment: currentTreatment ?? this.currentTreatment,
      weaknessAreas: weaknessAreas ?? this.weaknessAreas,
      flexibilityLevel: flexibilityLevel ?? this.flexibilityLevel,
      activityLevel: activityLevel ?? this.activityLevel,
      painLevel: painLevel ?? this.painLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'avatar': avatar,
        'diagnosisTime': diagnosisTime,
        'scoliosisType': scoliosisType,
        'currentTreatment': currentTreatment,
        'weaknessAreas': weaknessAreas,
        'flexibilityLevel': flexibilityLevel,
        'activityLevel': activityLevel,
        'painLevel': painLevel,
      };
}
