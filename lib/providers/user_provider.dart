import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as user_model;

class UserProvider with ChangeNotifier {
  user_model.User? _user;
  bool _isLoading = false;
  String? _error;
  late Future<void> _initialized;

  user_model.User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  Future<void> get initialized => _initialized;

  UserProvider() {
    _initialized = _init();
  }

  Future<void> _init() async {
    // Check for existing session on app start (don't auto sign out if profile missing)
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      print('🔄 Found existing session on app start');
      await _loadUserProfile(session.user.id, autoSignOut: false);
    }

    // Listen for auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      print('🔄 Auth state change: ${event.event}');
      if (event.event == AuthChangeEvent.signedIn) {
        print('✅ User signed in, loading profile...');
        _loadUserProfile(event.session!.user.id, autoSignOut: true);
      } else if (event.event == AuthChangeEvent.signedOut) {
        print('🚪 User signed out');
        _user = null;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserProfile(String userId, {bool autoSignOut = true}) async {
    print('🔍 Loading user profile for ID: $userId (autoSignOut: $autoSignOut)');
    const int maxRetries = 3;
    const Duration retryDelay = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      print('🔄 Profile loading attempt ${attempt + 1}/$maxRetries');
      try {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', userId)
            .single();

        print('✅ Raw profile data from database:');
        profile.forEach((key, value) {
          print('   $key: $value (${value.runtimeType})');
        });

        print('✅ Profile loaded successfully: ${profile['name']} (${profile['email']})');
        _user = user_model.User.fromJson(profile);
        _error = null; // Clear any previous errors
        _isLoading = false;
        notifyListeners();
        return;
      } catch (e) {
        print('❌ Profile loading attempt ${attempt + 1} failed: $e');

        // Check if this is a "profile not found" error (PGRST116)
        if (e.toString().contains('PGRST116') || e.toString().contains('0 rows')) {
          print('⚠️ Profile not found, attempting to create it...');
          try {
            await _createMissingProfile(userId);
            // After creating, try loading again
            continue;
          } catch (createError) {
            print('❌ Failed to create missing profile: $createError');
            // Fall through to retry logic
          }
        }

        if (attempt == maxRetries - 1) {
          // Last attempt failed
          print('💥 All profile loading attempts failed');
          _user = null;
          _error = 'User profile not found. Please contact support.';
          _isLoading = false;

          // Only auto sign out during active authentication, not during app initialization
          if (autoSignOut) {
            print('🚪 Signing out user due to profile loading failure');
            await Supabase.instance.client.auth.signOut();
          } else {
            print('⚠️ Profile not found during initialization, user will need to login again');
          }

          notifyListeners();
          return;
        }
        // Wait before retrying
        print('⏳ Waiting ${retryDelay.inMilliseconds}ms before retry...');
        await Future.delayed(retryDelay);
      }
    }
  }

  Future<void> _createProfile(String userId) async {
    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser != null) {
      await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'name': authUser.userMetadata?['name'] ?? 'User',
        'email': authUser.email,
        'level': 1,
        'xp': 0,
        'streak': 0,
        'badges': [],
        'join_date': DateTime.now().toIso8601String(),
        'fitness_goal': '',
        'fitness_level': '',
        'age': 25,
        'height': 170.0,
        'weight': 70.0,
        'gender': '',
        'preferred_activities': [],
        'workout_days': 3,
        'workout_duration': 30,
        'achievements': [],
      });
      await _loadUserProfile(userId, autoSignOut: true);
    }
  }

  Future<void> _createMissingProfile(String userId) async {
    print('🗃️ Creating missing profile for user ID: $userId');

    final authUser = Supabase.instance.client.auth.currentUser;
    if (authUser == null) {
      throw Exception('No authenticated user found');
    }

    final name = authUser.userMetadata?['name'] ?? 'User';
    final email = authUser.email ?? '';

    print('   Name: $name');
    print('   Email: $email');

    try {
      final result = await Supabase.instance.client.from('profiles').insert({
        'id': userId,
        'name': name,
        'email': email,
        'level': 1,
        'xp': 0,
        'streak': 0,
        'badges': [],
        'join_date': DateTime.now().toIso8601String(),
        'fitness_goal': '',
        'fitness_level': '',
        'age': 25,
        'height': 170.0,
        'weight': 70.0,
        'gender': '',
        'preferred_activities': [],
        'workout_days': 3,
        'workout_duration': 30,
        'achievements': [],
      });
      print('✅ Missing profile created successfully');
    } catch (e) {
      print('❌ Failed to create missing profile: $e');
      rethrow;
    }
  }


  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Profile will be loaded (or created if missing) by auth state listener
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      // If login fails, sign out and show error
      await Supabase.instance.client.auth.signOut();
      _error = 'Invalid email or password. Please check your credentials.';
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String name, String email, String password) async {
    print('🔄 Starting registration for: $email');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📧 Calling Supabase signUp...');
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name}, // Pass name in user metadata
      );

      print('✅ Supabase signUp response: ${response.user != null ? 'User created' : 'No user'}');
      print('👤 User ID: ${response.user?.id}');
      print('📧 User Email: ${response.user?.email}');

      if (response.user != null) {
        // Profile will be created automatically by database trigger
        // Auth state listener will load it when signed in
        print('✅ Registration successful, profile will be created by trigger');
        _isLoading = false;
        notifyListeners();
      } else {
        print('❌ No user returned from signUp');
        throw Exception('Registration failed: No user created');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }


  Future<void> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.google);
      // Profile will be handled by auth state listener or triggers
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loginWithApple() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.signInWithOAuth(OAuthProvider.apple);
      // Profile will be handled by auth state listener or triggers
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
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

      await Supabase.instance.client.from('profiles').update({
        'fitness_goal': data['goal'],
        'fitness_level': data['fitnessLevel'],
        'age': data['age'],
        'height': data['height'],
        'weight': data['weight'],
        'gender': data['gender'],
        'preferred_activities': data['activities'],
        'workout_days': data['workoutDays'],
        'workout_duration': data['workoutDuration'],
      }).eq('id', _user!.id);

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
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (bio != null) updates['bio'] = bio;
      if (height != null) updates['height'] = height;
      if (weight != null) updates['weight'] = weight;
      if (fitnessGoal != null) updates['fitness_goal'] = fitnessGoal;
      if (fitnessLevel != null) updates['fitness_level'] = fitnessLevel;
      if (preferredActivities != null) updates['preferred_activities'] = preferredActivities;
      if (workoutDays != null) updates['workout_days'] = workoutDays;
      if (workoutDuration != null) updates['workout_duration'] = workoutDuration;
      if (achievements != null) updates['achievements'] = achievements;

      await Supabase.instance.client.from('profiles').update(updates).eq('id', _user!.id);

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

  Future<void> addXP(int points) async {
    if (_user != null) {
      final newXP = _user!.xp + points;
      final newLevel = (newXP / 500).floor() + 1;

      await Supabase.instance.client.from('profiles').update({
        'xp': newXP,
        'level': newLevel,
      }).eq('id', _user!.id);

      _user = _user!.copyWith(
        xp: newXP,
        level: newLevel,
      );
      notifyListeners();
    }
  }

  Future<void> updateStreak(int streak) async {
    if (_user != null) {
      await Supabase.instance.client.from('profiles').update({
        'streak': streak,
      }).eq('id', _user!.id);

      _user = _user!.copyWith(streak: streak);
      notifyListeners();
    }
  }

  Future<void> addBadge(String badge) async {
    if (_user != null && !_user!.badges.contains(badge)) {
      final newBadges = List<String>.from(_user!.badges)..add(badge);

      await Supabase.instance.client.from('profiles').update({
        'badges': newBadges,
      }).eq('id', _user!.id);

      _user = _user!.copyWith(badges: newBadges);
      notifyListeners();
    }
  }

  Future<void> initUser() async {
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _loadUserProfile(session.user.id, autoSignOut: true);
    }
  }

  void logout() {
    Supabase.instance.client.auth.signOut();
    _user = null;
    _error = null;
    notifyListeners();
  }
}
