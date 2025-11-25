import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _loadInitialData() async {
    // Load weight entries from database
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final weightResponse = await Supabase.instance.client
          .from('progress_entries')
          .select()
          .eq('user_id', user.id)
          .eq('type', 'weight')
          .order('date', ascending: true);

      _weightEntries = weightResponse.map((json) => WeightEntry(
        date: DateTime.parse(json['date']),
        weight: json['value'].toDouble(),
      )).toList();

      // Load body measurements (simplified - in real app, group by date)
      final measurementResponse = await Supabase.instance.client
          .from('progress_entries')
          .select()
          .eq('user_id', user.id)
          .inFilter('type', ['chest', 'waist', 'hips', 'biceps', 'thighs'])
          .order('date', ascending: false);

      // Group by date for body measurements
      Map<String, Map<String, double>> measurementsByDate = {};
      for (var entry in measurementResponse) {
        String date = entry['date'];
        String type = entry['type'];
        double value = entry['value'].toDouble();

        measurementsByDate[date] ??= {};
        measurementsByDate[date]![type] = value;
      }

      _bodyMeasurements = measurementsByDate.entries.map((entry) {
        var data = entry.value;
        return BodyMeasurement(
          date: DateTime.parse(entry.key),
          chest: data['chest'] ?? 0,
          waist: data['waist'] ?? 0,
          hips: data['hips'] ?? 0,
          biceps: data['biceps'] ?? 0,
          thighs: data['thighs'] ?? 0,
        );
      }).toList();
    }

    // Keep workout sessions and personal records as local for now
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

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      await Supabase.instance.client.from('progress_entries').insert({
        'user_id': user.id,
        'type': 'weight',
        'value': weight,
        'unit': 'kg',
      });
    }

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
