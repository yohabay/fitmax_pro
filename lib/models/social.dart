class SocialPost {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;
  final int comments;
  final String? imageUrl;
  final List<String> tags;

  SocialPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
    required this.comments,
    this.imageUrl,
    this.tags = const [],
  });
}

class SocialUser {
  final String id;
  final String name;
  final String username;
  final String avatar;
  final String bio;
  final int followers;
  final int following;
  final int level;
  final int streak;
  final List<String> achievements;

  SocialUser({
    required this.id,
    required this.name,
    required this.username,
    required this.avatar,
    required this.bio,
    required this.followers,
    required this.following,
    required this.level,
    required this.streak,
    this.achievements = const [],
  });
}

class SocialChallenge {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int participants;
  final String category;
  final Map<String, dynamic> rules;
  final List<String> rewards;

  SocialChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.participants,
    required this.category,
    required this.rules,
    this.rewards = const [],
  });
}

class Comment {
  final String id;
  final String postId;
  final String userId;
  final String userName;
  final String userAvatar;
  final String content;
  final DateTime timestamp;
  final int likes;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.content,
    required this.timestamp,
    required this.likes,
  });
}
