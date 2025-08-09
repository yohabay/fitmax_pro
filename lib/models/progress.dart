class WorkoutSession {
  final String id;
  final DateTime date;
  final String workoutName;
  final int duration; // in minutes
  final int caloriesBurned;
  final List<ExerciseLog> exercises;
  final String? notes;
  WorkoutSession({
    required this.id,
    required this.date,
    required this.workoutName,
    required this.duration,
    required this.caloriesBurned,
    required this.exercises,
    this.notes,
  });
}

class ExerciseLog {
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int? duration; // for time-based exercises
  final double? distance; // for cardio exercises

  ExerciseLog({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    this.duration,
    this.distance,
  });
}

class BodyMeasurement {
  final DateTime date;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? biceps;
  final double? thighs;
  final double? neck;
  final double? forearms;
  final double? calves;

  BodyMeasurement({
    required this.date,
    this.chest,
    this.waist,
    this.hips,
    this.biceps,
    this.thighs,
    this.neck,
    this.forearms,
    this.calves,
  });

  Map<String, double?> toMap() {
    return {
      'Chest': chest,
      'Waist': waist,
      'Hips': hips,
      'Biceps': biceps,
      'Thighs': thighs,
      'Neck': neck,
      'Forearms': forearms,
      'Calves': calves,
    };
  }
}

class WeightEntry {
  final DateTime date;
  final double weight;
  final double? bodyFat;
  final double? muscleMass;

  WeightEntry({
    required this.date,
    required this.weight,
    this.bodyFat,
    this.muscleMass,
  });
}

class ProgressPhoto {
  final String id;
  final DateTime date;
  final String imageUrl;
  final String category; // front, side, back
  final String? notes;

  ProgressPhoto({
    required this.id,
    required this.date,
    required this.imageUrl,
    required this.category,
    this.notes,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final DateTime unlockedDate;
  final String category;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.unlockedDate,
    required this.category,
    required this.points,
  });
}
