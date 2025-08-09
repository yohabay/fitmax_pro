class User {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final String? bio; // Added bio field
  final int level;
  final int xp;
  final int streak;
  final List<String> badges;
  final DateTime joinDate;
  final String fitnessGoal;
  final String fitnessLevel;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final List<String> preferredActivities;
  final int workoutDays;
  final int workoutDuration;
  final List<String> achievements; // Added achievements field

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    this.bio, // Added bio to constructor
    required this.level,
    required this.xp,
    required this.streak,
    required this.badges,
    required this.joinDate,
    required this.fitnessGoal,
    required this.fitnessLevel,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.preferredActivities,
    required this.workoutDays,
    required this.workoutDuration,
    required this.achievements, // Added achievements to constructor
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    String? bio, // Added bio to copyWith
    int? level,
    int? xp,
    int? streak,
    List<String>? badges,
    DateTime? joinDate,
    String? fitnessGoal,
    String? fitnessLevel,
    int? age,
    double? height,
    double? weight,
    String? gender,
    List<String>? preferredActivities,
    int? workoutDays,
    int? workoutDuration,
    List<String>? achievements, // Added achievements to copyWith
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio, // Added bio to copyWith
      level: level ?? this.level,
      xp: xp ?? this.xp,
      streak: streak ?? this.streak,
      badges: badges ?? this.badges,
      joinDate: joinDate ?? this.joinDate,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      preferredActivities: preferredActivities ?? this.preferredActivities,
      workoutDays: workoutDays ?? this.workoutDays,
      workoutDuration: workoutDuration ?? this.workoutDuration,
      achievements: achievements ?? this.achievements, // Added achievements to copyWith
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      bio: json['bio'], // Added bio to fromJson
      level: json['level'],
      xp: json['xp'],
      streak: json['streak'],
      badges: List<String>.from(json['badges']),
      joinDate: DateTime.parse(json['joinDate']),
      fitnessGoal: json['fitnessGoal'],
      fitnessLevel: json['fitnessLevel'],
      age: json['age'],
      height: json['height'].toDouble(),
      weight: json['weight'].toDouble(),
      gender: json['gender'],
      preferredActivities: List<String>.from(json['preferredActivities']),
      workoutDays: json['workoutDays'],
      workoutDuration: json['workoutDuration'],
      achievements: List<String>.from(json['achievements'] ?? []), // Added achievements to fromJson
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'bio': bio, // Added bio to toJson
      'level': level,
      'xp': xp,
      'streak': streak,
      'badges': badges,
      'joinDate': joinDate.toIso8601String(),
      'fitnessGoal': fitnessGoal,
      'fitnessLevel': fitnessLevel,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'preferredActivities': preferredActivities,
      'workoutDays': workoutDays,
      'workoutDuration': workoutDuration,
      'achievements': achievements, // Added achievements to toJson
    };
  }
}
