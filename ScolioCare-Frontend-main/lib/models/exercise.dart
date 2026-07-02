class Exercise {
  final String name;
  final String duration;
  final String reps;
  final String difficulty;
  bool completed;

  Exercise({
    required this.name,
    required this.duration,
    required this.reps,
    required this.difficulty,
    this.completed = false,
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
