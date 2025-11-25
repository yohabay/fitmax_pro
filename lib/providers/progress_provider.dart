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
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    // Load weight entries from database
    final weightResponse = await Supabase.instance.client
        .from('progress_entries')
        .select()
        .eq('user_id', currentUserId)
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
        .eq('user_id', currentUserId)
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

    // Load workout sessions from database
    final workoutResponse = await Supabase.instance.client
        .from('workout_sessions')
        .select()
        .eq('user_id', currentUserId)
        .order('completed_at', ascending: false);

    _workoutSessions = workoutResponse.map((json) {
      List<ExerciseLog> exercises = [];
      if (json['exercises'] != null && json['exercises'] is List) {
        exercises = (json['exercises'] as List).map((e) => ExerciseLog(
          name: e['name'] ?? '',
          sets: e['sets'] ?? 0,
          reps: e['reps'] ?? 0,
          weight: e['weight']?.toDouble() ?? 0,
        )).toList();
      }

      return WorkoutSession(
        id: json['id'],
        date: DateTime.parse(json['completed_at']),
        workoutName: json['workout_name'],
        duration: json['duration'],
        caloriesBurned: json['calories_burned'],
        exercises: exercises,
      );
    }).toList();

    // Load personal records from database
    final recordsResponse = await Supabase.instance.client
        .from('personal_records')
        .select()
        .eq('user_id', currentUserId);

    _personalRecords = {};
    for (var record in recordsResponse) {
      _personalRecords[record['exercise_name']] = record['value'].toDouble();
    }
  }

  Future<void> addWorkoutSession(WorkoutSession session) async {
    _isLoading = true;
    notifyListeners();

    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    // Save to database
    final exercisesJson = session.exercises.map((e) => {
      'name': e.name,
      'sets': e.sets,
      'reps': e.reps,
      'weight': e.weight,
    }).toList();

    await Supabase.instance.client.from('workout_sessions').insert({
      'user_id': currentUserId,
      'workout_name': session.workoutName,
      'duration': session.duration,
      'calories_burned': session.caloriesBurned,
      'exercises': exercisesJson,
    });

    _workoutSessions.insert(0, session);
    _isLoading = false;
    notifyListeners();

    // Update personal records if applicable
    for (final exercise in session.exercises) {
      if (exercise.weight > 0) {
        await updatePersonalRecord(exercise.name, exercise.weight);
      }
    }
  }

  Future<void> addBodyMeasurement(BodyMeasurement measurement) async {
    _isLoading = true;
    notifyListeners();

    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    // Save each measurement as separate entries
    final measurements = [
      {'type': 'chest', 'value': measurement.chest},
      {'type': 'waist', 'value': measurement.waist},
      {'type': 'hips', 'value': measurement.hips},
      {'type': 'biceps', 'value': measurement.biceps},
      {'type': 'thighs', 'value': measurement.thighs},
    ];

    for (var m in measurements) {
      final value = m['value'] as double?;
      if (value != null && value > 0) {
        await Supabase.instance.client.from('progress_entries').insert({
          'user_id': currentUserId,
          'type': m['type'],
          'value': value,
          'unit': 'cm',
        });
      }
    }

    _bodyMeasurements.add(measurement);
    _bodyMeasurements.sort((a, b) => a.date.compareTo(b.date));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWeightEntry(double weight) async {
    _isLoading = true;
    notifyListeners();

    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('progress_entries').insert({
      'user_id': currentUserId,
      'type': 'weight',
      'value': weight,
      'unit': 'kg',
    });

    _weightEntries.add(WeightEntry(date: DateTime.now(), weight: weight));
    _weightEntries.sort((a, b) => a.date.compareTo(b.date));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updatePersonalRecord(String exercise, double value) async {
    if (!_personalRecords.containsKey(exercise) ||
        value > _personalRecords[exercise]!) {

      // For demo purposes, use 'demo_user' as the current user
      const currentUserId = 'demo_user';

      // Check if record exists
      final existingRecord = await Supabase.instance.client
          .from('personal_records')
          .select()
          .eq('user_id', currentUserId)
          .eq('exercise_name', exercise)
          .maybeSingle();

      if (existingRecord != null) {
        // Update existing record
        await Supabase.instance.client
            .from('personal_records')
            .update({
              'value': value,
              'achieved_at': DateTime.now().toIso8601String(),
            })
            .eq('user_id', currentUserId)
            .eq('exercise_name', exercise);
      } else {
        // Insert new record
        await Supabase.instance.client.from('personal_records').insert({
          'user_id': currentUserId,
          'exercise_name': exercise,
          'value': value,
          'unit': _getUnitForExercise(exercise),
        });
      }

      _personalRecords[exercise] = value;
      notifyListeners();
    }
  }

  Future<void> refreshData() async {
    await _loadInitialData();
  }

  String _getUnitForExercise(String exercise) {
    if (exercise.toLowerCase().contains('run') || exercise.toLowerCase().contains('time')) {
      return 'min';
    }
    if (exercise.toLowerCase().contains('pull') || exercise.toLowerCase().contains('push')) {
      return 'reps';
    }
    return 'kg';
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
