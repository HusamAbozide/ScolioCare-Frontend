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
  List<Exercise> get allPlanExercises => _categories.values
      .expand((category) => category.exercises)
      .toList(growable: false);
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
                id: exercise.exerciseId,
                name: exercise.exerciseName,
                duration: '${exercise.durationSeconds ~/ 60} min',
                reps: 'See instructions',
                difficulty: exercise.difficultyLevel,
                description: exercise.description,
                instructions: exercise.instructions,
                targetMuscles: exercise.musclesInvolved,
                precautions: exercise.precautions,
                durationSeconds: exercise.durationSeconds,
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
      _loadCategoriesFromPlan(_currentPlan);
      _applyLoggedCompletions();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load plan';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generatePlanForAnalysis([String? analysisId]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentPlan =
          await _exerciseService.generatePlan(analysisId: analysisId);
      _loadCategoriesFromPlan(_currentPlan);
      _exerciseLogs = [];
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'Failed to generate exercise plan';
      return false;
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
      _exerciseLogs.insert(
        0,
        submitted.planId.isEmpty
            ? ExerciseLog(
                logId: submitted.logId,
                userId: submitted.userId,
                planId: planId,
                exerciseId: submitted.exerciseId,
                completedDate: submitted.completedDate,
                completedAt: submitted.completedAt,
                setsCompleted: submitted.setsCompleted,
                repsCompleted: submitted.repsCompleted,
                durationSeconds: submitted.durationSeconds,
                difficultyRating: submitted.difficultyRating,
                painDuringSession: submitted.painDuringSession,
                notes: submitted.notes,
              )
            : submitted,
      );
      _markExerciseCompleted(exerciseId, true);

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

  Future<void> loadExerciseLogs(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _exerciseLogs = await _exerciseService.getExerciseLogs(userId);
      _calculateStreak();
      _applyLoggedCompletions();
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

  Future<bool> completeExercise(Exercise exercise, {int? painLevel}) async {
    final planId = _currentPlan?.planId;
    if (planId == null || planId.isEmpty || exercise.id.isEmpty) {
      _errorMessage = 'No active exercise plan found';
      notifyListeners();
      return false;
    }

    if (exercise.completed) {
      return true;
    }

    await submitExerciseLog(
      planId: planId,
      exerciseId: exercise.id,
      setsCompleted: exercise.sets > 0 ? exercise.sets : 1,
      repsCompleted: exercise.repetitions,
      durationSeconds: exercise.durationSeconds ?? 0,
      painDuringSession: painLevel,
      notes: 'Completed from exercise program',
    );

    return _errorMessage == null;
  }

  Future<bool> toggleTodayExercise(Exercise exercise, {int? painLevel}) async {
    final planId = _currentPlan?.planId;
    if (planId == null || planId.isEmpty || exercise.id.isEmpty) {
      _errorMessage = 'No active exercise plan found';
      notifyListeners();
      return false;
    }

    if (exercise.completed) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      try {
        await _exerciseService.deleteTodayExerciseLog(
          planId: planId,
          exerciseId: exercise.id,
        );
        _exerciseLogs.removeWhere(
          (log) => log.planId == planId &&
              log.exerciseId == exercise.id &&
              _isToday(log.completedAt),
        );
        _markExerciseCompleted(exercise.id, false);
        _calculateStreak();
        return true;
      } on ApiException catch (e) {
        _errorMessage = e.message;
        return false;
      } catch (e) {
        _errorMessage = 'Failed to undo exercise';
        return false;
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }

    return completeExercise(exercise, painLevel: painLevel);
  }

  List<ExerciseDay> get fourWeekTimeline {
    final plan = _currentPlan;
    final exercises = allPlanExercises;
    if (plan == null || exercises.isEmpty) return [];

    final scheduledWeekdays = {DateTime.monday, DateTime.wednesday, DateTime.friday};
    final days = <ExerciseDay>[];
    for (int offset = 0; offset < 28; offset++) {
      final date = DateTime(
        plan.startDate.year,
        plan.startDate.month,
        plan.startDate.day + offset,
      );
      if (!scheduledWeekdays.contains(date.weekday)) continue;
      days.add(
        ExerciseDay(
          week: (offset ~/ 7) + 1,
          date: date,
          exercises: exercises,
        ),
      );
    }
    return days;
  }

  ExerciseDay? get todaySchedule {
    final now = DateTime.now();
    for (final day in fourWeekTimeline) {
      if (day.date.year == now.year &&
          day.date.month == now.month &&
          day.date.day == now.day) {
        return day;
      }
    }
    return null;
  }

  void _loadCategoriesFromPlan(UserExercisePlan? plan) {
    _categories.clear();
    final exercises = plan?.exercises ?? [];
    for (final planExercise in exercises) {
      final categoryKey = _categoryKey(planExercise.category);
      _categories.putIfAbsent(
        categoryKey,
        () => ExerciseCategory(
          key: categoryKey,
          label: planExercise.category ?? categoryKey,
          exercises: [],
        ),
      );
      _categories[categoryKey]!.exercises.add(
            Exercise(
              id: planExercise.exerciseId,
              name: planExercise.exerciseName ??
                  planExercise.exercise?.exerciseName ??
                  'Exercise',
              duration: _formatDuration(planExercise.holdDurationSeconds),
              reps: planExercise.repetitions > 0
                  ? '${planExercise.sets} x ${planExercise.repetitions}'
                  : '${planExercise.sets} sets',
              difficulty: planExercise.difficulty ??
                  planExercise.exercise?.difficultyLevel ??
                  'Easy',
              description: planExercise.exercise?.description ?? '',
              instructions: planExercise.specialInstructions ??
                  planExercise.exercise?.instructions ??
                  '',
              targetMuscles: planExercise.exercise?.musclesInvolved ?? '',
              precautions: planExercise.exercise?.precautions,
              sets: planExercise.sets,
              repetitions: planExercise.repetitions,
              durationSeconds: planExercise.holdDurationSeconds,
              restSeconds: planExercise.restSeconds,
              completed: false,
            ),
          );
    }
  }

  void _applyLoggedCompletions() {
    if (_categories.isEmpty) return;
    final planId = _currentPlan?.planId;
    if (planId == null || planId.isEmpty) {
      _resetCompletions();
      return;
    }

    final completedIds = _exerciseLogs
        .where((log) => log.planId == planId && _isToday(log.completedAt))
        .map((log) => log.exerciseId)
        .toSet();
    for (final category in _categories.values) {
      for (final exercise in category.exercises) {
        exercise.completed = completedIds.contains(exercise.id);
      }
    }
  }

  void _resetCompletions() {
    for (final category in _categories.values) {
      for (final exercise in category.exercises) {
        exercise.completed = false;
      }
    }
  }

  void _markExerciseCompleted(String exerciseId, bool completed) {
    for (final category in _categories.values) {
      for (final exercise in category.exercises) {
        if (exercise.id == exerciseId) {
          exercise.completed = completed;
        }
      }
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _categoryKey(String? category) {
    switch (category?.toUpperCase()) {
      case 'STRENGTHENING':
        return 'strengthening';
      case 'POSTURE_CORRECTION':
        return 'posture';
      case 'STRETCHING':
        return 'stretching';
      default:
        return 'stretching';
    }
  }

  String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return 'As prescribed';
    if (seconds < 60) return '$seconds sec';
    return '${seconds ~/ 60} min';
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
