import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/nutrition.dart';

class NutritionProvider with ChangeNotifier {
  // Default targets (these could be customized per user)
  static const int _defaultCalorieTarget = 2200;
  static const double _defaultProteinTarget = 120;
  static const double _defaultCarbsTarget = 250;
  static const double _defaultFatTarget = 80;
  static const int _defaultWaterTarget = 8;

  DailyCalories _dailyCalories = DailyCalories(
    consumed: 0,
    target: _defaultCalorieTarget,
    burned: 0,
  );

  Map<String, MacroData> _macros = {
    'protein': MacroData(current: 0, target: _defaultProteinTarget),
    'carbs': MacroData(current: 0, target: _defaultCarbsTarget),
    'fat': MacroData(current: 0, target: _defaultFatTarget),
  };

  WaterIntake _waterIntake = WaterIntake(current: 0, target: _defaultWaterTarget);

  DateTime? _fastingStartTime;
  int _fastingGoalHours = 16; // Default 16:8 fasting
  FastingTimer _fastingTimer = FastingTimer(
    timeRemaining: '16:00:00',
    progress: 0.0,
  );
  Timer? _fastingTimerUpdater;
  List<FastingSession> _fastingHistory = [];

  List<Meal> _todaysMeals = [];
  List<NutritionInsight> _insights = [];
  bool _isLoading = false;

  DailyCalories get dailyCalories => _dailyCalories;
  Map<String, MacroData> get macros => _macros;
  WaterIntake get waterIntake => _waterIntake;
  FastingTimer get fastingTimer => _fastingTimer;
  List<Meal> get todaysMeals => _todaysMeals;
  List<NutritionInsight> get insights => _insights;
  List<FastingSession> get fastingHistory => _fastingHistory;
  bool get isLoading => _isLoading;
  bool get isFasting => _fastingStartTime != null;
  int get fastingGoalHours => _fastingGoalHours;

  Future<void> loadNutritionData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final response = await Supabase.instance.client
            .from('meals')
            .select()
            .eq('user_id', user.id)
            .eq('date', DateTime.now().toIso8601String().split('T')[0]);

        _todaysMeals = response.map((json) => Meal.fromJson(json)).toList();
      }

      // Load water intake and fasting data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final waterKey = 'water_intake_$today';
      final savedWater = prefs.getInt(waterKey) ?? 0;
      _waterIntake = WaterIntake(current: savedWater, target: _waterIntake.target);

      // Load fasting data
      final fastingStartKey = 'fasting_start_time';
      final fastingGoalKey = 'fasting_goal_hours';
      final savedStartTimeString = prefs.getString(fastingStartKey);
      final savedGoalHours = prefs.getInt(fastingGoalKey) ?? 16;

      if (savedStartTimeString != null) {
        _fastingStartTime = DateTime.parse(savedStartTimeString);
        _fastingGoalHours = savedGoalHours;
        _updateFastingTimer();
        // Restart the timer with 1-second updates for smooth countdown
        _fastingTimerUpdater?.cancel();
        _fastingTimerUpdater = Timer.periodic(const Duration(seconds: 1), (_) {
          _updateFastingTimer();
          notifyListeners();
        });
      } else {
        _fastingGoalHours = savedGoalHours;
      }

      // Calculate nutrition values from actual meals
      _calculateNutritionFromMeals();

      // Generate dynamic insights based on actual data
      _generateInsights();

    } catch (e) {
      print('Load nutrition data error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addWaterGlass() async {
    if (_waterIntake.current < _waterIntake.target) {
      _waterIntake = WaterIntake(
        current: _waterIntake.current + 1,
        target: _waterIntake.target,
      );

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().split('T')[0];
      final waterKey = 'water_intake_$today';
      await prefs.setInt(waterKey, _waterIntake.current);

      notifyListeners();
    }
  }

  Future<void> startFast() async {
    _fastingStartTime = DateTime.now();
    _updateFastingTimer();

    // Save to shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fasting_start_time', _fastingStartTime!.toIso8601String());
    await prefs.setInt('fasting_goal_hours', _fastingGoalHours);

    // Start timer to update every second for smooth countdown
    _fastingTimerUpdater?.cancel();
    _fastingTimerUpdater = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateFastingTimer();
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> endFast() async {
    if (_fastingStartTime != null) {
      final endTime = DateTime.now();
      final completed = endTime.difference(_fastingStartTime!).inHours >= _fastingGoalHours;

      // Add to history
      _fastingHistory.insert(0, FastingSession(
        startTime: _fastingStartTime!,
        endTime: endTime,
        goalHours: _fastingGoalHours,
        completed: completed,
      ));

      // Keep only last 10 fasting sessions
      if (_fastingHistory.length > 10) {
        _fastingHistory = _fastingHistory.sublist(0, 10);
      }
    }

    _fastingStartTime = null;
    _fastingTimerUpdater?.cancel();
    _fastingTimerUpdater = null;
    _fastingTimer = FastingTimer(
      timeRemaining: '${_fastingGoalHours.toString().padLeft(2, '0')}:00:00',
      progress: 0.0,
    );

    // Clear from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fasting_start_time');

    notifyListeners();
  }

  Future<void> setFastingGoal(int hours) async {
    _fastingGoalHours = hours;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fasting_goal_hours', hours);

    if (_fastingStartTime == null) {
      _fastingTimer = FastingTimer(
        timeRemaining: '${hours.toString().padLeft(2, '0')}:00',
        progress: 0.0,
      );
      notifyListeners();
    }
  }

  void _updateFastingTimer() {
    if (_fastingStartTime == null) return;

    final elapsed = DateTime.now().difference(_fastingStartTime!);
    final remaining = Duration(hours: _fastingGoalHours) - elapsed;

    if (remaining.isNegative) {
      _fastingTimer = FastingTimer(
        timeRemaining: '00:00',
        progress: 1.0,
      );
    } else {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes.remainder(60);
      final seconds = remaining.inSeconds.remainder(60);
      final timeString = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      final progress = elapsed.inSeconds / (_fastingGoalHours * 3600);

      _fastingTimer = FastingTimer(
        timeRemaining: timeString,
        progress: progress.clamp(0.0, 1.0),
      );
    }
  }

  void setFastingReminder() {
    // In a real app, this would schedule notifications
    // For now, just start the fast
    startFast();
  }

  Future<void> addMeal(Meal meal) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('meals').insert({
        'user_id': user.id,
        'meal_type': meal.mealType,
        'food_name': meal.foodName,
        'calories': meal.calories,
        'time': meal.time,
        'image_url': meal.imageUrl,
        'macros': {
          'protein': meal.macros.protein,
          'carbs': meal.macros.carbs,
          'fat': meal.macros.fat,
        },
      });

      _todaysMeals.add(meal);

      // Recalculate all nutrition values from actual meal data
      _calculateNutritionFromMeals();

      // Regenerate insights based on new data
      _generateInsights();

      notifyListeners();
    } catch (e) {
      print('Add meal error: $e');
    }
  }

  void dispose() {
    _fastingTimerUpdater?.cancel();
  }

  void _calculateNutritionFromMeals() {
    // Calculate total calories and macros from today's meals
    int totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final meal in _todaysMeals) {
      totalCalories += meal.calories;
      totalProtein += meal.macros.protein;
      totalCarbs += meal.macros.carbs;
      totalFat += meal.macros.fat;
    }

    // Calculate burned calories from today's workouts
    // Note: In a real app, this would come from ProgressProvider
    // For now, we'll keep it as 0 and it can be updated when workouts are completed
    int burnedCalories = 0;

    // Update daily calories
    _dailyCalories = DailyCalories(
      consumed: totalCalories,
      target: _defaultCalorieTarget,
      burned: burnedCalories,
    );

    // Update macros
    _macros = {
      'protein': MacroData(current: totalProtein, target: _defaultProteinTarget),
      'carbs': MacroData(current: totalCarbs, target: _defaultCarbsTarget),
      'fat': MacroData(current: totalFat, target: _defaultFatTarget),
    };
  }

  void _generateInsights() {
    _insights = [];

    // Protein insight
    final proteinProgress = _macros['protein']!.current / _macros['protein']!.target;
    if (proteinProgress >= 0.7) {
      _insights.add(NutritionInsight(
        title: 'Great protein intake!',
        description: 'You\'re ${(proteinProgress * 100).round()}% towards your daily goal',
        type: 'success',
        xpReward: 10,
      ));
    } else if (proteinProgress < 0.3) {
      _insights.add(NutritionInsight(
        title: 'Low protein intake',
        description: 'Consider adding more protein-rich foods',
        type: 'warning',
        xpReward: 5,
      ));
    }

    // Calorie insight
    final calorieProgress = _dailyCalories.consumed / _dailyCalories.target;
    if (calorieProgress > 1.1) {
      _insights.add(NutritionInsight(
        title: 'High calorie intake',
        description: 'You\'ve exceeded your daily calorie goal',
        type: 'warning',
        xpReward: 5,
      ));
    } else if (calorieProgress >= 0.8) {
      _insights.add(NutritionInsight(
        title: 'On track with calories',
        description: 'Keep up the good work!',
        type: 'success',
        xpReward: 5,
      ));
    }

    // Water insight
    final waterProgress = _waterIntake.current / _waterIntake.target;
    if (waterProgress >= 0.8) {
      _insights.add(NutritionInsight(
        title: 'Hydration champion!',
        description: 'Great job staying hydrated today',
        type: 'success',
        xpReward: 5,
      ));
    } else if (waterProgress < 0.5) {
      _insights.add(NutritionInsight(
        title: 'Stay hydrated',
        description: 'Drink more water for better health',
        type: 'info',
        xpReward: 3,
      ));
    }

    // Meal variety insight
    if (_todaysMeals.length >= 3) {
      _insights.add(NutritionInsight(
        title: 'Balanced meals today',
        description: 'Good variety in your meal choices',
        type: 'success',
        xpReward: 5,
      ));
    }

    // Fasting insights
    if (_fastingHistory.isNotEmpty) {
      final completedFasts = _fastingHistory.where((f) => f.completed).length;
      if (completedFasts >= 3) {
        _insights.add(NutritionInsight(
          title: 'Fasting champion!',
          description: 'Completed $completedFasts fasting sessions',
          type: 'success',
          xpReward: 10,
        ));
      }
    }

    if (_fastingStartTime != null) {
      final elapsed = DateTime.now().difference(_fastingStartTime!);
      if (elapsed.inHours >= 12) {
        _insights.add(NutritionInsight(
          title: 'Strong fasting progress',
          description: 'Over 12 hours into your fast!',
          type: 'success',
          xpReward: 5,
        ));
      }
    }

    // Default insights if none generated
    if (_insights.isEmpty) {
      _insights.add(NutritionInsight(
        title: 'Track your nutrition',
        description: 'Start logging meals to get personalized insights',
        type: 'info',
        xpReward: 3,
      ));
    }
  }
}
