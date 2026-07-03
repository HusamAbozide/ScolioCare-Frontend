class ExerciseResponse {
  final String exerciseId;
  final String exerciseName;
  final String description;
  final String category;
  final String difficultyLevel;
  final String videoUrl;
  final String? thumbnailUrl;
  final int durationSeconds;
  final String instructions;
  final String? precautions;
  final String musclesInvolved;
  final List<String>? targetAreas;
  final DateTime createdAt;

  ExerciseResponse({
    required this.exerciseId,
    required this.exerciseName,
    required this.description,
    required this.category,
    required this.difficultyLevel,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.durationSeconds,
    required this.instructions,
    this.precautions,
    required this.musclesInvolved,
    this.targetAreas,
    required this.createdAt,
  });

  factory ExerciseResponse.fromJson(Map<String, dynamic> json) {
    final name = json['exerciseName'] ?? json['name'];
    final difficulty = json['difficultyLevel'] ?? json['difficulty'];
    final instructions = json['instructions'] ?? json['instructionText'];
    final muscles = json['musclesInvolved'] ?? json['targetMuscles'];
    return ExerciseResponse(
      exerciseId: json['exerciseId'] as String,
      exerciseName: name as String? ?? 'Exercise',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'STRETCHING',
      difficultyLevel: difficulty as String? ?? 'EASY',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      instructions: instructions as String? ?? '',
      precautions: json['precautions'] as String?,
      musclesInvolved: muscles as String? ?? '',
      targetAreas: json['targetAreas'] != null
          ? List<String>.from(json['targetAreas'] as List)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}

class UserExercisePlan {
  final String planId;
  final String userId;
  final String? analysisId;
  final String planName;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final int durationWeeks;
  final Map<String, dynamic> customizationParams;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PlanExercise>? exercises;

  UserExercisePlan({
    required this.planId,
    required this.userId,
    this.analysisId,
    required this.planName,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.durationWeeks,
    required this.customizationParams,
    required this.createdAt,
    required this.updatedAt,
    this.exercises,
  });

  factory UserExercisePlan.fromJson(Map<String, dynamic> json) {
    final exercisesJson = json['exercises'] as List?;
    return UserExercisePlan(
      planId: json['planId'] as String,
      userId: json['userId'] as String,
      analysisId: json['analysisId'] as String?,
      planName: json['planName'] as String? ?? 'Exercise Program',
      description: json['description'] as String? ??
          json['notes'] as String? ??
          'Personalized exercise plan',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      durationWeeks: json['durationWeeks'] as int? ??
          DateTime.parse(json['endDate'] as String)
                  .difference(DateTime.parse(json['startDate'] as String))
                  .inDays ~/
              7,
      customizationParams:
          json['customizationParams'] as Map<String, dynamic>? ?? {},
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      exercises: exercisesJson
          ?.map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PlanExercise {
  final String planExerciseId;
  final String planId;
  final String exerciseId;
  final String? exerciseName;
  final String? category;
  final String? difficulty;
  final int sets;
  final int repetitions;
  final int? holdDurationSeconds;
  final int restSeconds;
  final String? specialInstructions;
  final int orderIndex;
  final ExerciseResponse? exercise;

  PlanExercise({
    required this.planExerciseId,
    required this.planId,
    required this.exerciseId,
    this.exerciseName,
    this.category,
    this.difficulty,
    required this.sets,
    required this.repetitions,
    this.holdDurationSeconds,
    required this.restSeconds,
    this.specialInstructions,
    required this.orderIndex,
    this.exercise,
  });

  factory PlanExercise.fromJson(Map<String, dynamic> json) {
    return PlanExercise(
      planExerciseId: json['planExerciseId'] as String? ??
          json['exerciseId'] as String? ??
          '',
      planId: json['planId'] as String? ?? '',
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String?,
      category: json['category'] as String?,
      difficulty: json['difficulty'] as String?,
      sets: json['sets'] as int,
      repetitions: json['repetitions'] as int? ?? json['reps'] as int? ?? 0,
      holdDurationSeconds: json['holdDurationSeconds'] as int? ??
          json['durationSeconds'] as int?,
      restSeconds: json['restSeconds'] as int? ?? 0,
      specialInstructions: json['specialInstructions'] as String?,
      orderIndex: json['orderIndex'] as int? ?? json['sortOrder'] as int? ?? 0,
      exercise: json['exercise'] != null
          ? ExerciseResponse.fromJson(json['exercise'] as Map<String, dynamic>)
          : null,
    );
  }
}

class ExerciseLog {
  final String logId;
  final String userId;
  final String planId;
  final String exerciseId;
  final DateTime completedDate;
  final DateTime completedAt;
  final int setsCompleted;
  final int repsCompleted;
  final int durationSeconds;
  final double? difficultyRating;
  final int? painDuringSession;
  final String? notes;

  ExerciseLog({
    required this.logId,
    required this.userId,
    required this.planId,
    required this.exerciseId,
    required this.completedDate,
    required this.completedAt,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.durationSeconds,
    this.difficultyRating,
    this.painDuringSession,
    this.notes,
  });

  factory ExerciseLog.fromJson(Map<String, dynamic> json) {
    final loggedAt = json['loggedAt'] ??
        json['completedAt'] ??
        json['completedDate'] ??
        DateTime.now().toIso8601String();
    return ExerciseLog(
      logId: json['logId'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      exerciseId: json['exerciseId'] as String,
      completedDate: DateTime.parse(loggedAt as String),
      completedAt: DateTime.parse(loggedAt),
      setsCompleted: json['setsCompleted'] as int? ?? 0,
      repsCompleted: json['repsCompleted'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      difficultyRating: json['difficultyRating'] as double?,
      painDuringSession:
          json['painDuringSession'] as int? ?? json['painLevel'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'exerciseId': exerciseId,
        'setsCompleted': setsCompleted,
        'repsCompleted': repsCompleted,
        'durationSeconds': durationSeconds,
        'painLevel': painDuringSession,
        'notes': notes,
      };
}
