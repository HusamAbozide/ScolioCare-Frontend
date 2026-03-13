import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseProvider extends ChangeNotifier {
  final Map<String, ExerciseCategory> _categories = {
    'strengthening': ExerciseCategory(
      key: 'strengthening',
      label: 'Strength',
      exercises: [
        Exercise(
            name: 'Bird Dog',
            duration: '3 min',
            reps: '10 each side',
            difficulty: 'Easy'),
        Exercise(
            name: 'Side Plank',
            duration: '2 min',
            reps: '30 sec each side',
            difficulty: 'Medium'),
        Exercise(
            name: 'Superman Hold',
            duration: '3 min',
            reps: '10 reps',
            difficulty: 'Easy',
            completed: true),
      ],
    ),
    'stretching': ExerciseCategory(
      key: 'stretching',
      label: 'Stretch',
      exercises: [
        Exercise(
            name: 'Cat-Cow Stretch',
            duration: '5 min',
            reps: '15 reps',
            difficulty: 'Easy',
            completed: true),
        Exercise(
            name: "Child's Pose",
            duration: '3 min',
            reps: 'Hold 60 sec',
            difficulty: 'Easy',
            completed: true),
        Exercise(
            name: 'Spinal Twist',
            duration: '4 min',
            reps: '30 sec each side',
            difficulty: 'Easy'),
      ],
    ),
    'posture': ExerciseCategory(
      key: 'posture',
      label: 'Posture',
      exercises: [
        Exercise(
            name: 'Wall Angels',
            duration: '5 min',
            reps: '15 reps',
            difficulty: 'Medium'),
        Exercise(
            name: 'Chin Tucks',
            duration: '3 min',
            reps: '20 reps',
            difficulty: 'Easy'),
        Exercise(
            name: 'Thoracic Extension',
            duration: '4 min',
            reps: '12 reps',
            difficulty: 'Medium'),
      ],
    ),
    'breathing': ExerciseCategory(
      key: 'breathing',
      label: 'Breathe',
      exercises: [
        Exercise(
            name: 'Diaphragmatic Breathing',
            duration: '5 min',
            reps: '10 breaths',
            difficulty: 'Easy'),
        Exercise(
            name: '4-7-8 Technique',
            duration: '4 min',
            reps: '5 cycles',
            difficulty: 'Easy'),
      ],
    ),
  };

  Map<String, ExerciseCategory> get categories => _categories;
  List<String> get categoryKeys => _categories.keys.toList();

  int get totalExercises {
    int count = 0;
    for (final cat in _categories.values) {
      count += cat.exercises.length;
    }
    return count;
  }

  int get completedExercises {
    int count = 0;
    for (final cat in _categories.values) {
      count += cat.exercises.where((e) => e.completed).length;
    }
    return count;
  }

  double get progressPercent =>
      totalExercises > 0 ? completedExercises / totalExercises : 0;

  void toggleExercise(String categoryKey, int index) {
    final cat = _categories[categoryKey];
    if (cat != null && index < cat.exercises.length) {
      cat.exercises[index].completed = !cat.exercises[index].completed;
      notifyListeners();
    }
  }

  bool isExerciseRecommended(String exerciseName, List<String> weaknessAreas) {
    const exerciseAreaMapping = {
      'Side Plank': ['arms', 'shoulders', 'core'],
      'Wall Angels': ['arms', 'shoulders'],
      'Bird Dog': ['arms'],
      'Superman Hold': ['core', 'lower-back'],
      'Chin Tucks': ['neck'],
    };
    final areas = exerciseAreaMapping[exerciseName] ?? [];
    return !areas.any((area) => weaknessAreas.contains(area));
  }

  static const List<String> weekDays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];
}
