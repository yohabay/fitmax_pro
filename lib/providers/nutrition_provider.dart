import 'package:flutter/foundation.dart';
import '../models/nutrition.dart';

class NutritionProvider with ChangeNotifier {
  DailyCalories _dailyCalories = DailyCalories(
    consumed: 1450,
    target: 2200,
    burned: 320,
  );

  Map<String, MacroData> _macros = {
    'protein': MacroData(current: 85, target: 120),
    'carbs': MacroData(current: 180, target: 250),
    'fat': MacroData(current: 45, target: 80),
  };

  WaterIntake _waterIntake = WaterIntake(current: 6, target: 8);

  FastingTimer _fastingTimer = FastingTimer(
    timeRemaining: '14:32',
    progress: 0.65,
  );

  List<Meal> _todaysMeals = [];
  List<NutritionInsight> _insights = [];
  bool _isLoading = false;

  DailyCalories get dailyCalories => _dailyCalories;
  Map<String, MacroData> get macros => _macros;
  WaterIntake get waterIntake => _waterIntake;
  FastingTimer get fastingTimer => _fastingTimer;
  List<Meal> get todaysMeals => _todaysMeals;
  List<NutritionInsight> get insights => _insights;
  bool get isLoading => _isLoading;

  Future<void> loadNutritionData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _todaysMeals = [
        Meal(
          id: '1',
          mealType: 'Breakfast',
          foodName: 'Oatmeal with berries & honey',
          calories: 320,
          time: '8:00 AM',
          imageUrl: 'assets/images/yoga-morning-flow.png',
          macros: MacroData(protein: 12, carbs: 58, fat: 6),
        ),
        Meal(
          id: '2',
          mealType: 'Lunch',
          foodName: 'Grilled chicken salad',
          calories: 450,
          time: '12:30 PM',
          imageUrl: 'assets/images/deadlift-gym.png',
          macros: MacroData(protein: 35, carbs: 15, fat: 28),
        ),
        Meal(
          id: '3',
          mealType: 'Snack',
          foodName: 'Greek yogurt with nuts',
          calories: 180,
          time: '3:00 PM',
          imageUrl: 'assets/images/cardio-hiit-workout.png',
          macros: MacroData(protein: 15, carbs: 12, fat: 8),
        ),
      ];

      _insights = [
        NutritionInsight(
          title: 'Great protein intake!',
          description: 'You\'re 71% towards your daily goal',
          type: 'success',
          xpReward: 10,
        ),
        NutritionInsight(
          title: 'Balanced meals today',
          description: 'Good mix of macronutrients',
          type: 'success',
          xpReward: 5,
        ),
      ];
    } catch (e) {
      print('Load nutrition data error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addWaterGlass() {
    if (_waterIntake.current < _waterIntake.target) {
      _waterIntake = WaterIntake(
        current: _waterIntake.current + 1,
        target: _waterIntake.target,
      );
      notifyListeners();
    }
  }

  void endFast() {
    _fastingTimer = FastingTimer(
      timeRemaining: '0:00',
      progress: 1.0,
    );
    notifyListeners();
  }

  void setFastingReminder() {
    // Implement fasting reminder logic
    print('Fasting reminder set');
  }

  void addMeal(Meal meal) {
    _todaysMeals.add(meal);
    // Update daily calories
    _dailyCalories = DailyCalories(
      consumed: _dailyCalories.consumed + meal.calories,
      target: _dailyCalories.target,
      burned: _dailyCalories.burned,
    );
    
    // Update macros
    _macros['protein'] = MacroData(
      current: _macros['protein']!.current + meal.macros.protein,
      target: _macros['protein']!.target,
    );
    _macros['carbs'] = MacroData(
      current: _macros['carbs']!.current + meal.macros.carbs,
      target: _macros['carbs']!.target,
    );
    _macros['fat'] = MacroData(
      current: _macros['fat']!.current + meal.macros.fat,
      target: _macros['fat']!.target,
    );
    
    notifyListeners();
  }
}
