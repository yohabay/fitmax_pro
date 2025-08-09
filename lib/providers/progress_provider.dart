import 'package:flutter/material.dart';
import '../models/progress.dart';

class ProgressProvider with ChangeNotifier {
  List<WorkoutSession> _workoutSessions = [];
  List<BodyMeasurement> _bodyMeasurements = [];
  List<WeightEntry> _weightEntries = [];
  Map<String, double> _personalRecords = {};
  bool _isLoading = false;

  List<WorkoutSession> get workoutSessions => _workoutSessions;
  List<BodyMeasurement> get bodyMeasurements => _bodyMeasurements;
  List<WeightEntry> get weightEntries => _weightEntries;
  Map<String, double> get personalRecords => _personalRecords;
  bool get isLoading => _isLoading;

  ProgressProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Sample workout sessions
    _workoutSessions = [
      WorkoutSession(
        id: '1',
        date: DateTime.now().subtract(Duration(days: 1)),
        workoutName: 'Upper Body Strength',
        duration: 45,
        caloriesBurned: 320,
        exercises: [
          ExerciseLog(name: 'Bench Press', sets: 3, reps: 10, weight: 80),
          ExerciseLog(name: 'Pull-ups', sets: 3, reps: 8, weight: 0),
        ],
      ),
      WorkoutSession(
        id: '2',
        date: DateTime.now().subtract(Duration(days: 3)),
        workoutName: 'Cardio HIIT',
        duration: 30,
        caloriesBurned: 280,
        exercises: [],
      ),
    ];

    // Sample body measurements
    _bodyMeasurements = [
      BodyMeasurement(
        date: DateTime.now().subtract(Duration(days: 7)),
        chest: 95.0,
        waist: 82.0,
        hips: 98.0,
        biceps: 35.0,
        thighs: 58.0,
      ),
      BodyMeasurement(
        date: DateTime.now(),
        chest: 96.0,
        waist: 81.0,
        hips: 97.5,
        biceps: 35.5,
        thighs: 58.5,
      ),
    ];

    // Sample weight entries
    _weightEntries = [
      WeightEntry(date: DateTime.now().subtract(Duration(days: 30)), weight: 75.0),
      WeightEntry(date: DateTime.now().subtract(Duration(days: 23)), weight: 74.5),
      WeightEntry(date: DateTime.now().subtract(Duration(days: 16)), weight: 74.0),
      WeightEntry(date: DateTime.now().subtract(Duration(days: 9)), weight: 73.8),
      WeightEntry(date: DateTime.now().subtract(Duration(days: 2)), weight: 73.5),
      WeightEntry(date: DateTime.now(), weight: 73.2),
    ];

    // Sample personal records
    _personalRecords = {
      'Bench Press': 85.0,
      'Squat': 120.0,
      'Deadlift': 140.0,
      'Pull-ups': 12.0,
      '5K Run': 22.5, // minutes
    };
  }

  Future<void> addWorkoutSession(WorkoutSession session) async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 1));

    _workoutSessions.insert(0, session);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addBodyMeasurement(BodyMeasurement measurement) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    _bodyMeasurements.add(measurement);
    _bodyMeasurements.sort((a, b) => a.date.compareTo(b.date));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWeightEntry(double weight) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: 1));

    _weightEntries.add(WeightEntry(date: DateTime.now(), weight: weight));
    _weightEntries.sort((a, b) => a.date.compareTo(b.date));
    _isLoading = false;
    notifyListeners();
  }

  void updatePersonalRecord(String exercise, double value) {
    if (!_personalRecords.containsKey(exercise) || 
        value > _personalRecords[exercise]!) {
      _personalRecords[exercise] = value;
      notifyListeners();
    }
  }

  double getWeightChange() {
    if (_weightEntries.length < 2) return 0.0;
    return _weightEntries.last.weight - _weightEntries.first.weight;
  }

  int getTotalWorkouts() {
    return _workoutSessions.length;
  }

  int getTotalCaloriesBurned() {
    return _workoutSessions.fold(0, (sum, session) => sum + session.caloriesBurned);
  }

  double getAverageWorkoutDuration() {
    if (_workoutSessions.isEmpty) return 0.0;
    return _workoutSessions.fold(0, (sum, session) => sum + session.duration) / 
           _workoutSessions.length;
  }
}
