import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

  Future<void> _loadInitialData() async {
    // Load posts from database
    final postsResponse = await Supabase.instance.client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    _posts = postsResponse.map((json) => Post(
      id: json['id'],
      userId: json['user_id'],
      userName: 'User', // Would need to join with profiles table
      userAvatar: 'assets/images/placeholder-user.jpg',
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      likes: json['likes'] ?? 0,
      comments: 0, // Would need to count comments
      imageUrl: json['image_url'],
    )).toList();

    // Load friends from database
    final friendsResponse = await Supabase.instance.client
        .from('friends')
        .select()
        .eq('user_id', 'demo_user')
        .eq('status', 'accepted');

    _friends = friendsResponse.map((json) => User(
      id: json['friend_id'],
      name: json['friend_name'],
      avatar: json['friend_avatar'] ?? 'assets/images/placeholder-user.jpg',
      level: json['friend_level'] ?? 1,
      streak: json['friend_streak'] ?? 0,
    )).toList();

    // Load challenges from database
    final challengesResponse = await Supabase.instance.client
        .from('challenges')
        .select();

    _challenges = challengesResponse.map((json) => Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      participants: json['participants'] ?? 0,
      daysLeft: json['end_date'] != null
          ? DateTime.parse(json['end_date']).difference(DateTime.now()).inDays
          : 30,
      progress: 0.0, // Would need user-specific progress
    )).toList();
  }

  Future<void> refreshFeed() async {
    _isLoading = true;
    notifyListeners();

    await _loadInitialData();
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

  Future<void> createPost(String content, {String? imageUrl}) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final response = await Supabase.instance.client.from('posts').insert({
      'user_id': user.id,
      'content': content,
      'image_url': imageUrl,
    }).select().single();

    final newPost = Post(
      id: response['id'],
      userId: user.id,
      userName: 'You',
      userAvatar: 'assets/images/placeholder-user.jpg',
      content: content,
      timestamp: DateTime.parse(response['created_at']),
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