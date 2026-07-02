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
    return ExerciseResponse(
      exerciseId: json['exerciseId'] as String,
      exerciseName: json['exerciseName'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      difficultyLevel: json['difficultyLevel'] as String,
      videoUrl: json['videoUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int,
      instructions: json['instructions'] as String,
      precautions: json['precautions'] as String?,
      musclesInvolved: json['musclesInvolved'] as String,
      targetAreas: json['targetAreas'] != null
          ? List<String>.from(json['targetAreas'] as List)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
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
    return UserExercisePlan(
      planId: json['planId'] as String,
      userId: json['userId'] as String,
      analysisId: json['analysisId'] as String?,
      planName: json['planName'] as String,
      description: json['description'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      durationWeeks: json['durationWeeks'] as int,
      customizationParams: json['customizationParams'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      exercises: json['exercises'] != null
          ? (json['exercises'] as List)
              .map((e) => PlanExercise.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PlanExercise {
  final String planExerciseId;
  final String planId;
  final String exerciseId;
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
      planExerciseId: json['planExerciseId'] as String,
      planId: json['planId'] as String,
      exerciseId: json['exerciseId'] as String,
      sets: json['sets'] as int,
      repetitions: json['repetitions'] as int,
      holdDurationSeconds: json['holdDurationSeconds'] as int?,
      restSeconds: json['restSeconds'] as int,
      specialInstructions: json['specialInstructions'] as String?,
      orderIndex: json['orderIndex'] as int,
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
    return ExerciseLog(
      logId: json['logId'] as String,
      userId: json['userId'] as String,
      planId: json['planId'] as String,
      exerciseId: json['exerciseId'] as String,
      completedDate: DateTime.parse(json['completedDate'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      setsCompleted: json['setsCompleted'] as int,
      repsCompleted: json['repsCompleted'] as int,
      durationSeconds: json['durationSeconds'] as int,
      difficultyRating: json['difficultyRating'] as double?,
      painDuringSession: json['painDuringSession'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'exerciseId': exerciseId,
        'completedDate': completedDate.toIso8601String(),
        'setsCompleted': setsCompleted,
        'repsCompleted': repsCompleted,
        'durationSeconds': durationSeconds,
        'difficultyRating': difficultyRating,
        'painDuringSession': painDuringSession,
        'notes': notes,
      };
}
