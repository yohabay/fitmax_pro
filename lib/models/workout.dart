class Workout {
  final String id;
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final int calories;
  final String category;
  final String imageUrl;
  final String? videoUrl;
  final double rating;
  final int completions;
  final String trainer;
  final bool isPremium;
  final bool isFeatured;
  final List<Exercise> exercises;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.category,
    required this.imageUrl,
    this.videoUrl,
    required this.rating,
    required this.completions,
    required this.trainer,
    this.isPremium = false,
    this.isFeatured = false,
    this.exercises = const [],
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      duration: json['duration'],
      difficulty: json['difficulty'],
      calories: json['calories'],
      category: json['category'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      videoUrl: json['video_url'] ?? json['videoUrl'],
      rating: json['rating'].toDouble(),
      completions: json['completions'],
      trainer: json['trainer'],
      isPremium: json['is_premium'] ?? json['isPremium'] ?? false,
      isFeatured: json['is_featured'] ?? json['isFeatured'] ?? false,
      exercises: (json['exercises'] as List<dynamic>?)
          ?.map((e) => Exercise.fromJson(e))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration': duration,
      'difficulty': difficulty,
      'calories': calories,
      'category': category,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'rating': rating,
      'completions': completions,
      'trainer': trainer,
      'is_premium': isPremium,
      'is_featured': isFeatured,
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }
}

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final String? weight;
  final String? duration;
  final String? instructions;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.weight,
    this.duration,
    this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      name: json['name'],
      sets: json['sets'],
      reps: json['reps'],
      weight: json['weight'],
      duration: json['duration'],
      instructions: json['instructions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration': duration,
      'instructions': instructions,
    };
  }
}
