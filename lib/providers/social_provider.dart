import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/social.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final bool isRead;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.messageType,
    this.mediaUrl,
    required this.isRead,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      receiverId: json['receiver_id'],
      content: json['content'],
      messageType: json['message_type'] ?? 'text',
      mediaUrl: json['media_url'],
      isRead: json['is_read'] ?? false,
      timestamp: DateTime.parse(json['created_at']),
    );
  }
}

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

    // Load comments count for each post
    final commentsResponse = await Supabase.instance.client
        .from('comments')
        .select('post_id');

    // Count comments per post
    final commentsCount = <String, int>{};
    for (final comment in commentsResponse) {
      final postId = comment['post_id'] as String;
      commentsCount[postId] = (commentsCount[postId] ?? 0) + 1;
    }

    // Load likes count for each post
    final likesResponse = await Supabase.instance.client
        .from('post_likes')
        .select('post_id');

    // Count likes per post
    final likesCount = <String, int>{};
    for (final like in likesResponse) {
      final postId = like['post_id'] as String;
      likesCount[postId] = (likesCount[postId] ?? 0) + 1;
    }

    _posts = postsResponse.map((json) => Post(
      id: json['id'],
      userId: json['user_id'],
      userName: 'User', // Would need to join with profiles table
      userAvatar: 'assets/images/placeholder-user.jpg',
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      likes: likesCount[json['id']] ?? 0, // Calculate from post_likes table
      comments: commentsCount[json['id']] ?? 0,
      imageUrl: json['image_url'],
    )).toList();

    // Load friends from both old friends table and new follows table
    final friendsResponse = await Supabase.instance.client
        .from('friends')
        .select()
        .eq('user_id', 'demo_user')
        .eq('status', 'accepted');

    // Load followed users from follows table
    final followsResponse = await Supabase.instance.client
        .from('follows')
        .select()
        .eq('follower_id', 'demo_user');

    // Combine friends from both tables
    final oldFriends = friendsResponse.map((json) => User(
      id: json['friend_id'],
      name: json['friend_name'],
      avatar: json['friend_avatar'] ?? 'assets/images/placeholder-user.jpg',
      level: json['friend_level'] ?? 1,
      streak: json['friend_streak'] ?? 0,
    )).toList();

    // For followed users, we need to get their details (for demo, use placeholder data)
    final followedUsers = followsResponse.map((json) => User(
      id: json['following_id'],
      name: json['following_id'], // Use ID as name for demo
      avatar: 'assets/images/placeholder-user.jpg',
      level: 1,
      streak: 0,
    )).toList();

    // Combine and remove duplicates
    final allFriends = [...oldFriends, ...followedUsers];
    _friends = allFriends.toSet().toList(); // Remove duplicates by converting to Set then back to List

    // Load challenges from database
    final challengesResponse = await Supabase.instance.client
        .from('challenges')
        .select();

    _challenges = challengesResponse.map((json) => Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
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

    // Refresh posts and comments counts
    final postsResponse = await Supabase.instance.client
        .from('posts')
        .select()
        .order('created_at', ascending: false);

    // Load comments count for each post
    final commentsResponse = await Supabase.instance.client
        .from('comments')
        .select('post_id');

    // Count comments per post
    final commentsCount = <String, int>{};
    for (final comment in commentsResponse) {
      final postId = comment['post_id'] as String;
      commentsCount[postId] = (commentsCount[postId] ?? 0) + 1;
    }

    // Load likes count for each post
    final likesResponse = await Supabase.instance.client
        .from('post_likes')
        .select('post_id');

    // Count likes per post
    final likesCount = <String, int>{};
    for (final like in likesResponse) {
      final postId = like['post_id'] as String;
      likesCount[postId] = (likesCount[postId] ?? 0) + 1;
    }

    _posts = postsResponse.map((json) => Post(
      id: json['id'],
      userId: json['user_id'],
      userName: 'User', // Would need to join with profiles table
      userAvatar: 'assets/images/placeholder-user.jpg',
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      likes: likesCount[json['id']] ?? 0, // Calculate from post_likes table
      comments: commentsCount[json['id']] ?? 0,
      imageUrl: json['image_url'],
    )).toList();

    // Refresh friends list
    await _refreshFriendsList();

    // Refresh challenges data
    final challengesResponse = await Supabase.instance.client
        .from('challenges')
        .select();

    _challenges = challengesResponse.map((json) => Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      participants: json['participants'] ?? 0,
      daysLeft: json['end_date'] != null
          ? DateTime.parse(json['end_date']).difference(DateTime.now()).inDays
          : 30,
      progress: 0.0, // Would need user-specific progress
    )).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> likePost(String postId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    try {
      // Check if user already liked this post
      final existingLike = await Supabase.instance.client
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', currentUserId)
          .maybeSingle();

      if (existingLike != null) {
        // Unlike the post - remove from post_likes table
        await Supabase.instance.client
            .from('post_likes')
            .delete()
            .eq('post_id', postId)
            .eq('user_id', currentUserId);

        _posts[postIndex].likes--;
      } else {
        // Like the post - add to post_likes table
        await Supabase.instance.client
            .from('post_likes')
            .insert({
              'post_id': postId,
              'user_id': currentUserId,
            });

        _posts[postIndex].likes++;
      }

      notifyListeners();
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  // Old method removed - replaced with async version below

  Future<bool> isUserJoinedChallenge(String challengeId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    try {
      final response = await Supabase.instance.client
          .from('user_challenges')
          .select()
          .eq('user_id', currentUserId)
          .eq('challenge_id', challengeId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking challenge join status: $e');
      return false;
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    final challengeIndex = _challenges.indexWhere((c) => c.id == challengeId);
    if (challengeIndex == -1) return;

    try {
      // Check if already joined
      final alreadyJoined = await isUserJoinedChallenge(challengeId);

      if (alreadyJoined) {
        // Leave the challenge
        await Supabase.instance.client
            .from('user_challenges')
            .delete()
            .eq('user_id', currentUserId)
            .eq('challenge_id', challengeId);

        _challenges[challengeIndex].participants--;
      } else {
        // Join the challenge
        await Supabase.instance.client.from('user_challenges').insert({
          'user_id': currentUserId,
          'challenge_id': challengeId,
        });

        _challenges[challengeIndex].participants++;
      }

      notifyListeners();
    } catch (e) {
      print('Error joining/leaving challenge: $e');
    }
  }

  Future<void> createPost(String content, {String? imageUrl}) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    final response = await Supabase.instance.client.from('posts').insert({
      'user_id': currentUserId,
      'content': content,
      'image_url': imageUrl,
    }).select().single();

    final newPost = Post(
      id: response['id'],
      userId: currentUserId,
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

  Future<void> addComment(String postId, String content) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('comments').insert({
      'post_id': postId,
      'user_id': currentUserId,
      'content': content,
    });

    // Update comment count in posts
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex != -1) {
      _posts[postIndex].comments++;
      notifyListeners();
    }
  }

  Future<List<Comment>> getComments(String postId) async {
    final response = await Supabase.instance.client
        .from('comments')
        .select()
        .eq('post_id', postId)
        .order('created_at', ascending: true);

    return response.map((json) => Comment(
      id: json['id'],
      postId: postId,
      userId: json['user_id'],
      userName: 'User', // Would need to join with profiles
      userAvatar: 'assets/images/placeholder-user.jpg',
      content: json['content'],
      timestamp: DateTime.parse(json['created_at']),
      likes: 0,
    )).toList();
  }

  Future<void> sharePost(String postId) async {
    // In a real app, this would open share dialog or copy link
    // For now, just show a snackbar
    print('Shared post: $postId');
  }

  Future<void> hidePost(String postId) async {
    // Remove post from user's feed (client-side only)
    _posts.removeWhere((post) => post.id == postId);
    notifyListeners();
  }

  Future<void> reportPost(String postId, String reason) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // In a real app, this would create a report record
    // For now, just hide the post
    await hidePost(postId);
    print('Reported post: $postId for reason: $reason');
  }

  Future<void> followUser(String userId) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    // Add to friends table
    await Supabase.instance.client.from('friends').insert({
      'user_id': currentUser.id,
      'friend_id': userId,
      'friend_name': 'User', // Would need to get actual name
      'status': 'accepted',
    });

    // Refresh friends list
    await _loadInitialData();
  }

  Future<void> unfollowUser(String userId) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    await Supabase.instance.client
        .from('friends')
        .delete()
        .eq('user_id', currentUser.id)
        .eq('friend_id', userId);

    // Refresh friends list
    await _loadInitialData();
  }

  // Follow/Unfollow methods with new follows table
  Future<bool> isFollowing(String userId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    try {
      final response = await Supabase.instance.client
          .from('follows')
          .select()
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  Future<void> followUserNew(String userId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('follows').insert({
      'follower_id': currentUserId,
      'following_id': userId,
    });

    // Refresh friends list to include the newly followed user
    await _refreshFriendsList();
  }

  Future<void> unfollowUserNew(String userId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client
        .from('follows')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId);

    // Refresh friends list to remove the unfollowed user
    await _refreshFriendsList();
  }

  Future<void> _refreshFriendsList() async {
    // Load friends from both old friends table and new follows table
    final friendsResponse = await Supabase.instance.client
        .from('friends')
        .select()
        .eq('user_id', 'demo_user')
        .eq('status', 'accepted');

    // Load followed users from follows table
    final followsResponse = await Supabase.instance.client
        .from('follows')
        .select()
        .eq('follower_id', 'demo_user');

    // Combine friends from both tables
    final oldFriends = friendsResponse.map((json) => User(
      id: json['friend_id'],
      name: json['friend_name'],
      avatar: json['friend_avatar'] ?? 'assets/images/placeholder-user.jpg',
      level: json['friend_level'] ?? 1,
      streak: json['friend_streak'] ?? 0,
    )).toList();

    // For followed users, we need to get their details (for demo, use placeholder data)
    final followedUsers = followsResponse.map((json) => User(
      id: json['following_id'],
      name: json['following_id'], // Use ID as name for demo
      avatar: 'assets/images/placeholder-user.jpg',
      level: 1,
      streak: 0,
    )).toList();

    // Combine and remove duplicates
    final allFriends = [...oldFriends, ...followedUsers];
    _friends = allFriends.toSet().toList(); // Remove duplicates by converting to Set then back to List

    notifyListeners();
  }

  // Chat methods
  Future<List<ChatMessage>> getChatMessages(String otherUserId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    final response = await Supabase.instance.client
        .from('chat_messages')
        .select()
        .or('and(sender_id.eq.$currentUserId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$currentUserId)')
        .order('created_at', ascending: true);

    return response.map((json) => ChatMessage.fromJson(json)).toList();
  }

  Future<void> sendMessage(String receiverId, String content, {String messageType = 'text', String? mediaUrl}) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('chat_messages').insert({
      'sender_id': currentUserId,
      'receiver_id': receiverId,
      'content': content,
      'message_type': messageType,
      'media_url': mediaUrl,
    });
  }

  // Report methods
  Future<void> reportUser(String userId, String reason) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('reports').insert({
      'reporter_id': currentUserId,
      'reported_user_id': userId,
      'report_type': 'user',
      'reason': reason,
    });
  }

  Future<void> reportPostNew(String postId, String reason) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('reports').insert({
      'reporter_id': currentUserId,
      'reported_post_id': postId,
      'report_type': 'post',
      'reason': reason,
    });
  }

  // Block methods
  Future<bool> isBlocked(String userId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    try {
      final response = await Supabase.instance.client
          .from('blocks')
          .select()
          .eq('blocker_id', currentUserId)
          .eq('blocked_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> blockUser(String userId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client.from('blocks').insert({
      'blocker_id': currentUserId,
      'blocked_id': userId,
    });
  }

  Future<void> unblockUser(String userId) async {
    // For demo purposes, use 'demo_user' as the current user
    const currentUserId = 'demo_user';

    await Supabase.instance.client
        .from('blocks')
        .delete()
        .eq('blocker_id', currentUserId)
        .eq('blocked_id', userId);
  }

  // Share methods
  Future<void> sharePostToUser(String postId, String recipientId) async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return;

    // Get post content
    final post = _posts.firstWhere((p) => p.id == postId);
    final shareContent = 'Check out this post: "${post.content}"';

    // Send as message
    await sendMessage(recipientId, shareContent, messageType: 'share');
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
  final String? videoUrl;
  int participants;
  final int daysLeft;
  final double progress;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    this.videoUrl,
    required this.participants,
    required this.daysLeft,
    required this.progress,
  });
}