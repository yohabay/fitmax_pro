import 'package:flutter/material.dart';
import '../models/social.dart';

class SocialProvider with ChangeNotifier {
  List<Post> _posts = [];
  List<User> _friends = [];
  List<Challenge> _challenges = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  List<User> get friends => _friends;
  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

  SocialProvider() {
    _loadInitialData();
  }

  void _loadInitialData() {
    _posts = [
      Post(
        id: '1',
        userId: 'user1',
        userName: 'Sarah Johnson',
        userAvatar: 'assets/images/fitness-woman-2.png',
        content: 'Just completed my morning run! 5K in 25 minutes 🏃‍♀️',
        timestamp: DateTime.now().subtract(Duration(hours: 2)),
        likes: 15,
        comments: 3,
        imageUrl: 'assets/images/morning-run-sunrise.png',
      ),
      Post(
        id: '2',
        userId: 'user2',
        userName: 'Mike Chen',
        userAvatar: 'assets/images/fitness-man-2.png',
        content: 'New PR on deadlifts today! 180kg x 3 reps 💪',
        timestamp: DateTime.now().subtract(Duration(hours: 4)),
        likes: 23,
        comments: 7,
      ),
    ];

    _friends = [
      User(
        id: 'friend1',
        name: 'Emma Wilson',
        avatar: 'assets/images/fitness-woman.png',
        level: 12,
        streak: 15,
      ),
      User(
        id: 'friend2',
        name: 'Alex Rodriguez',
        avatar: 'assets/images/fitness-man.png',
        level: 8,
        streak: 7,
      ),
    ];

    _challenges = [
      Challenge(
        id: 'challenge1',
        title: '30-Day Push-up Challenge',
        description: 'Complete 1000 push-ups in 30 days',
        participants: 156,
        daysLeft: 12,
        progress: 0.65,
      ),
      Challenge(
        id: 'challenge2',
        title: 'Summer Shred',
        description: 'Lose 10 pounds in 8 weeks',
        participants: 89,
        daysLeft: 25,
        progress: 0.3,
      ),
    ];
  }

  Future<void> refreshFeed() async {
    _isLoading = true;
    notifyListeners();

    // Simulate API call
    await Future.delayed(Duration(seconds: 2));

    _loadInitialData();
    _isLoading = false;
    notifyListeners();
  }

  void likePost(String postId) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex].likes++;
      notifyListeners();
    }
  }

  void addComment(String postId, String comment) {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex].comments++;
      notifyListeners();
    }
  }

  void joinChallenge(String challengeId) {
    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex != -1) {
      _challenges[challengeIndex].participants++;
      notifyListeners();
    }
  }

  void createPost(String content, {String? imageUrl}) {
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user',
      userName: 'You',
      userAvatar: 'assets/images/placeholder-user.jpg',
      content: content,
      timestamp: DateTime.now(),
      likes: 0,
      comments: 0,
      imageUrl: imageUrl,
    );

    _posts.insert(0, newPost);
    notifyListeners();
  }
}

class Post {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  int likes;
  int comments;
  final String? imageUrl;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.imageUrl,
  });
}

class User {
  final String id;
  final String name;
  final String avatar;
  final int level;
  final int streak;

  User({
    required this.id,
    required this.name,
    required this.avatar,
    required this.level,
    required this.streak,
  });
}

class Challenge {
  final String id;
  final String title;
  final String description;
  int participants;
  final int daysLeft;
  final double progress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.participants,
    required this.daysLeft,
    required this.progress,
  });
}