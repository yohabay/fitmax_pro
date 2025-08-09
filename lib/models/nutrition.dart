class DailyCalories {
  final int consumed;
  final int target;
  final int burned;

  DailyCalories({
    required this.consumed,
    required this.target,
    required this.burned,
  });

  int get remaining => target - consumed + burned;
}

class MacroData {
  final double current;
  final double target;
  final double protein;
  final double carbs;
  final double fat;

  MacroData({
    this.current = 0,
    this.target = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });
}

class WaterIntake {
  final int current;
  final int target;

  WaterIntake({
    required this.current,
    required this.target,
  });
}

class FastingTimer {
  final String timeRemaining;
  final double progress;

  FastingTimer({
    required this.timeRemaining,
    required this.progress,
  });
}

class Meal {
  final String id;
  final String mealType;
  final String foodName;
  final int calories;
  final String time;
  final String imageUrl;
  final MacroData macros;

  Meal({
    required this.id,
    required this.mealType,
    required this.foodName,
    required this.calories,
    required this.time,
    required this.imageUrl,
    required this.macros,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      mealType: json['mealType'],
      foodName: json['foodName'],
      calories: json['calories'],
      time: json['time'],
      imageUrl: json['imageUrl'],
      macros: MacroData(
        protein: json['macros']['protein'].toDouble(),
        carbs: json['macros']['carbs'].toDouble(),
        fat: json['macros']['fat'].toDouble(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealType,
      'foodName': foodName,
      'calories': calories,
      'time': time,
      'imageUrl': imageUrl,
      'macros': {
        'protein': macros.protein,
        'carbs': macros.carbs,
        'fat': macros.fat,
      },
    };
  }
}

class NutritionInsight {
  final String title;
  final String description;
  final String type;
  final int xpReward;

  NutritionInsight({
    required this.title,
    required this.description,
    required this.type,
    required this.xpReward,
  });
}
