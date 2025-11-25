import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  List<Workout> _favoriteWorkouts = [];
  bool _isLoading = false;
  String? _error;

  List<Workout> get workouts => _workouts;
  List<Workout> get favoriteWorkouts => _favoriteWorkouts;
  List<Workout> get featuredWorkouts => _workouts.where((w) => w.isFeatured).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.from('workouts').select();
      print('Fetched ${response.length} workouts from database');
      for (var workout in response) {
        print('Workout: ${workout['title']} - Featured: ${workout['is_featured']} - Video: ${workout['video_url']}');
      }

      _workouts = [];
      for (var json in response) {
        try {
          final workout = Workout.fromJson(json);
          _workouts.add(workout);
        } catch (e) {
          print('Error parsing workout ${json['title']}: $e');
          print('Workout data: $json');
        }
      }
      print('Parsed ${_workouts.length} workouts successfully');

      // Load favorites
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final favoritesResponse = await Supabase.instance.client
            .from('user_favorites')
            .select('workout_id')
            .eq('user_id', user.id);
        final favoriteIds = favoritesResponse.map((f) => f['workout_id'] as String).toSet();
        _favoriteWorkouts = _workouts.where((w) => favoriteIds.contains(w.id)).toList();
        print('Loaded ${favoriteIds.length} favorite workouts');
      }
    } catch (e) {
      _error = e.toString();
      print('Error loading workouts: $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String workoutId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final workout = _workouts.firstWhere((w) => w.id == workoutId);

    if (_favoriteWorkouts.contains(workout)) {
      _favoriteWorkouts.remove(workout);
      await Supabase.instance.client.from('user_favorites').delete().eq('user_id', user.id).eq('workout_id', workoutId);
    } else {
      _favoriteWorkouts.add(workout);
      await Supabase.instance.client.from('user_favorites').insert({
        'user_id': user.id,
        'workout_id': workoutId,
      });
    }

    notifyListeners();
  }

  List<Workout> getWorkoutsByCategory(String category) {
    if (category == 'all') return _workouts;
    return _workouts.where((w) => w.category == category).toList();
  }

  List<Workout> searchWorkouts(String query) {
    if (query.isEmpty) return _workouts;
    
    return _workouts.where((workout) {
      return workout.title.toLowerCase().contains(query.toLowerCase()) ||
             workout.trainer.toLowerCase().contains(query.toLowerCase()) ||
             workout.category.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
