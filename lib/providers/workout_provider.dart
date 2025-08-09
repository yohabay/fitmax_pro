import 'package:flutter/foundation.dart';
import '../models/workout.dart';

class WorkoutProvider with ChangeNotifier {
  List<Workout> _workouts = [];
  List<Workout> _favoriteWorkouts = [];
  bool _isLoading = false;
  String? _error;

  List<Workout> get workouts => _workouts;
  List<Workout> get favoriteWorkouts => _favoriteWorkouts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadWorkouts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _workouts = [
        Workout(
          id: '1',
          title: 'Full Body Strength',
          description: 'Complete full body workout targeting all major muscle groups',
          duration: '45 min',
          difficulty: 'Intermediate',
          calories: 320,
          category: 'strength',
          imageUrl: 'assets/images/gym-strength-training.png',
          rating: 4.8,
          completions: 1234,
          trainer: 'Mike Johnson',
          exercises: [
            Exercise(name: 'Squats', sets: 3, reps: 12, weight: '135 lbs'),
            Exercise(name: 'Deadlifts', sets: 3, reps: 8, weight: '185 lbs'),
            Exercise(name: 'Bench Press', sets: 3, reps: 10, weight: '155 lbs'),
            Exercise(name: 'Pull-ups', sets: 3, reps: 8),
          ],
        ),
        Workout(
          id: '2',
          title: 'HIIT Cardio Blast',
          description: 'High-intensity interval training for maximum calorie burn',
          duration: '30 min',
          difficulty: 'Advanced',
          calories: 280,
          category: 'cardio',
          imageUrl: 'assets/images/cardio-hiit-workout.png',
          rating: 4.9,
          completions: 2156,
          trainer: 'Sarah Chen',
          exercises: [
            Exercise(name: 'Burpees', sets: 4, reps: 15),
            Exercise(name: 'Mountain Climbers', sets: 4, reps: 20),
            Exercise(name: 'Jump Squats', sets: 4, reps: 15),
            Exercise(name: 'High Knees', sets: 4, reps: 30),
          ],
        ),
        Workout(
          id: '3',
          title: 'Morning Yoga Flow',
          description: 'Gentle yoga sequence to start your day with mindfulness',
          duration: '25 min',
          difficulty: 'Beginner',
          calories: 150,
          category: 'flexibility',
          imageUrl: 'assets/images/yoga-morning-flow.png',
          rating: 4.7,
          completions: 892,
          trainer: 'Emma Wilson',
          isPremium: true,
        ),
        Workout(
          id: '4',
          title: 'Bodyweight Circuit',
          description: 'No equipment needed - use your body weight for resistance',
          duration: '35 min',
          difficulty: 'Intermediate',
          calories: 240,
          category: 'bodyweight',
          imageUrl: 'assets/images/bodyweight-circuit.png',
          rating: 4.6,
          completions: 567,
          trainer: 'Alex Rodriguez',
        ),
      ];
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String workoutId) async {
    final workout = _workouts.firstWhere((w) => w.id == workoutId);
    
    if (_favoriteWorkouts.contains(workout)) {
      _favoriteWorkouts.remove(workout);
    } else {
      _favoriteWorkouts.add(workout);
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
