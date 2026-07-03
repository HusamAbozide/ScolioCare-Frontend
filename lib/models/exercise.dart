class Exercise {
  final String id;
  final String name;
  final String duration;
  final String reps;
  final String difficulty;
  final String description;
  final String instructions;
  final String targetMuscles;
  final String? precautions;
  final int sets;
  final int repetitions;
  final int? durationSeconds;
  final int restSeconds;
  bool completed;

  Exercise({
    this.id = '',
    required this.name,
    required this.duration,
    required this.reps,
    required this.difficulty,
    this.description = '',
    this.instructions = '',
    this.targetMuscles = '',
    this.precautions,
    this.sets = 0,
    this.repetitions = 0,
    this.durationSeconds,
    this.restSeconds = 0,
    this.completed = false,
  });
}

class ExerciseDay {
  final int week;
  final DateTime date;
  final List<Exercise> exercises;

  const ExerciseDay({
    required this.week,
    required this.date,
    required this.exercises,
  });
}

class ExerciseCategory {
  final String key;
  final String label;
  final List<Exercise> exercises;

  const ExerciseCategory({
    required this.key,
    required this.label,
    required this.exercises,
  });
}
