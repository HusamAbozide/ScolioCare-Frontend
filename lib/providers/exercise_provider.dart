import 'package:flutter/material.dart';
import '../models/exercise.dart';
import '../core/api/api_client.dart';
import '../core/services/exercise_service.dart';
import '../core/models/exercise/exercise_response.dart';
import '../core/api/api_exception.dart';

class ExerciseProvider extends ChangeNotifier {
  final ExerciseService _exerciseService = ExerciseService(ApiClient());

  final Map<String, ExerciseCategory> _categories = {};
  UserExercisePlan? _currentPlan;
  List<ExerciseLog> _exerciseLogs = [];

  bool _isLoading = false;
  String? _errorMessage;
  int _currentStreak = 0;
  int _longestStreak = 0;

  Map<String, ExerciseCategory> get categories => _categories;
  List<String> get categoryKeys => _categories.keys.toList();
  UserExercisePlan? get currentPlan => _currentPlan;
  List<ExerciseLog> get exerciseLogs => _exerciseLogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;

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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadExercises({String? category, String? difficulty}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final exercises = await _exerciseService.getExercises(
        category: category,
        difficulty: difficulty,
      );

      // Group exercises by category
      _categories.clear();
      for (var exercise in exercises) {
        final catKey = exercise.category.toLowerCase();
        if (!_categories.containsKey(catKey)) {
          _categories[catKey] = ExerciseCategory(
            key: catKey,
            label: exercise.category,
            exercises: [],
          );
        }

        _categories[catKey]!.exercises.add(
              Exercise(
                name: exercise.exerciseName,
                duration: '${exercise.durationSeconds ~/ 60} min',
                reps: 'See instructions',
                difficulty: exercise.difficultyLevel,
                completed: false,
              ),
            );
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load exercises';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCurrentPlan(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan = await _exerciseService.getCurrentPlan(userId);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load plan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitExerciseLog({
    required String planId,
    required String exerciseId,
    required int setsCompleted,
    required int repsCompleted,
    required int durationSeconds,
    double? difficultyRating,
    int? painDuringSession,
    String? notes,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final log = ExerciseLog(
        logId: '', // Will be set by backend
        userId: '', // Will be set by backend
        planId: planId,
        exerciseId: exerciseId,
        completedDate: DateTime.now(),
        completedAt: DateTime.now(),
        setsCompleted: setsCompleted,
        repsCompleted: repsCompleted,
        durationSeconds: durationSeconds,
        difficultyRating: difficultyRating,
        painDuringSession: painDuringSession,
        notes: notes,
      );

      final submitted = await _exerciseService.submitExerciseLog(log);
      _exerciseLogs.insert(0, submitted);

      // Update streak (simplified - actual calculation done by backend)
      _calculateStreak();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to submit log';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExerciseLogs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exerciseLogs = await _exerciseService.getExerciseLogs();
      _calculateStreak();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load logs';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _calculateStreak() {
    if (_exerciseLogs.isEmpty) {
      _currentStreak = 0;
      _longestStreak = 0;
      return;
    }

    // Sort logs by date
    _exerciseLogs.sort((a, b) => b.completedDate.compareTo(a.completedDate));

    int streak = 1;
    int longest = 1;
    DateTime lastDate = _exerciseLogs.first.completedDate;

    for (int i = 1; i < _exerciseLogs.length; i++) {
      final diff = lastDate.difference(_exerciseLogs[i].completedDate).inDays;
      if (diff == 1) {
        streak++;
        if (streak > longest) longest = streak;
      } else if (diff > 1) {
        break;
      }
      lastDate = _exerciseLogs[i].completedDate;
    }

    _currentStreak = streak;
    _longestStreak = longest;
  }

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
