import 'package:flutter/foundation.dart';
import '../models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _user = User(
        id: '1',
        name: 'John Doe',
        email: email,
        avatar: 'https://example.com/avatar.jpg',
        level: 5,
        xp: 2450,
        streak: 7,
        badges: ['Early Bird', 'Consistency King', 'Strength Master'],
        joinDate: DateTime.now().subtract(const Duration(days: 90)),
        fitnessGoal: 'Build Muscle',
        fitnessLevel: 'Intermediate',
        age: 28,
        height: 175,
        weight: 75,
        gender: 'Male',
        preferredActivities: ['Strength Training', 'Cardio'],
        workoutDays: 4,
        workoutDuration: 45,
        achievements: [],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _user = User(
        id: '1',
        name: name,
        email: email,
        level: 1,
        xp: 0,
        streak: 0,
        badges: [],
        joinDate: DateTime.now(),
        fitnessGoal: '',
        fitnessLevel: '',
        age: 25,
        height: 170,
        weight: 70,
        gender: '',
        preferredActivities: [],
        workoutDays: 3,
        workoutDuration: 30,
        achievements: [],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate Google login
      await Future.delayed(const Duration(seconds: 1));
      
      _user = User(
        id: '1',
        name: 'Google User',
        email: 'user@gmail.com',
        avatar: 'https://example.com/google-avatar.jpg',
        level: 3,
        xp: 1200,
        streak: 3,
        badges: ['Social Butterfly'],
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        fitnessGoal: 'Stay Fit',
        fitnessLevel: 'Beginner',
        age: 25,
        height: 170,
        weight: 65,
        gender: 'Female',
        preferredActivities: ['Yoga', 'Cardio'],
        workoutDays: 3,
        workoutDuration: 30,
        achievements: [],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate Apple login
      await Future.delayed(const Duration(seconds: 1));
      
      _user = User(
        id: '1',
        name: 'Apple User',
        email: 'user@icloud.com',
        level: 2,
        xp: 800,
        streak: 5,
        badges: ['Privacy Pro'],
        joinDate: DateTime.now().subtract(const Duration(days: 15)),
        fitnessGoal: 'Lose Weight',
        fitnessLevel: 'Beginner',
        age: 30,
        height: 168,
        weight: 80,
        gender: 'Male',
        preferredActivities: ['Running', 'Swimming'],
        workoutDays: 4,
        workoutDuration: 40,
        achievements: [],
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeOnboarding(Map<String, dynamic> data) async {
    if (_user != null) {
      _user = _user!.copyWith(
        fitnessGoal: data['goal'],
        fitnessLevel: data['fitnessLevel'],
        age: data['age'],
        height: data['height'],
        weight: data['weight'],
        gender: data['gender'],
        preferredActivities: List<String>.from(data['activities']),
        workoutDays: data['workoutDays'],
        workoutDuration: data['workoutDuration'],
      );
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    double? height,
    double? weight,
    String? fitnessGoal,
    String? fitnessLevel,
    List<String>? preferredActivities,
    int? workoutDays,
    int? workoutDuration,
    List<String>? achievements,
  }) async {
    if (_user != null) {
      _user = _user!.copyWith(
        name: name ?? _user!.name,
        bio: bio ?? _user!.bio,
        height: height ?? _user!.height,
        weight: weight ?? _user!.weight,
        fitnessGoal: fitnessGoal ?? _user!.fitnessGoal,
        fitnessLevel: fitnessLevel ?? _user!.fitnessLevel,
        preferredActivities: preferredActivities ?? _user!.preferredActivities,
        workoutDays: workoutDays ?? _user!.workoutDays,
        workoutDuration: workoutDuration ?? _user!.workoutDuration,
        achievements: achievements ?? _user!.achievements,
      );
      notifyListeners();
    }
  }

  void addXP(int points) {
    if (_user != null) {
      final newXP = _user!.xp + points;
      final newLevel = (newXP / 500).floor() + 1;
      
      _user = _user!.copyWith(
        xp: newXP,
        level: newLevel,
      );
      notifyListeners();
    }
  }

  void updateStreak(int streak) {
    if (_user != null) {
      _user = _user!.copyWith(streak: streak);
      notifyListeners();
    }
  }

  void addBadge(String badge) {
    if (_user != null && !_user!.badges.contains(badge)) {
      final newBadges = List<String>.from(_user!.badges)..add(badge);
      _user = _user!.copyWith(badges: newBadges);
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
