import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/social_provider.dart';
import '../models/social.dart';
import 'comments_screen.dart';
import 'user_profile_screen.dart';
import 'chat_screen.dart';
import 'challenge_detail_screen.dart';
import 'workouts_screen.dart'; // For VideoPlayerWidget

class SocialScreen extends StatefulWidget {
  @override
  _SocialScreenState createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Feed', icon: Icon(Icons.home)),
                Tab(text: 'Friends', icon: Icon(Icons.people)),
                Tab(text: 'Challenges', icon: Icon(Icons.emoji_events)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFeedTab(),
                _buildFriendsTab(),
                _buildChallengesTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        child: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildFeedTab() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        if (socialProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: socialProvider.refreshFeed,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: socialProvider.posts.length,
            itemBuilder: (context, index) {
              final post = socialProvider.posts[index];
              return _buildPostCard(post);
            },
          ),
        );
      },
    );
  }

  Widget _buildPostCard(Post post) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to user profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserProfileScreen(
                          userName: post.userName,
                          userAvatar: post.userAvatar,
                          userLevel: 5,
                          userStreak: 12,
                        ),
                      ),
                    );
                  },
                  child: CircleAvatar(
                    backgroundImage: AssetImage(post.userAvatar),
                    radius: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfileScreen(
                            userName: post.userName,
                            userAvatar: post.userAvatar,
                            userLevel: 5,
                            userStreak: 12,
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatTimestamp(post.timestamp),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                    switch (value) {
                      case 'report':
                        await socialProvider.reportPost(post.id, 'Inappropriate content');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post reported')),
                        );
                        break;
                      case 'hide':
                        await socialProvider.hidePost(post.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Post hidden')),
                        );
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      value: 'hide',
                      child: Text('Hide'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(fontSize: 16),
            ),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  post.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                FutureBuilder<bool>(
                  future: _checkIfUserLikedPost(post.id),
                  builder: (context, snapshot) {
                    final isLiked = snapshot.data ?? false;
                    return IconButton(
                      onPressed: () async {
                        await Provider.of<SocialProvider>(context, listen: false)
                            .likePost(post.id);
                        setState(() {}); // Refresh to update like status
                      },
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                    );
                  },
                ),
                Text('${post.likes}'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // Navigate to chat with post author
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          userName: post.userName,
                          userAvatar: post.userAvatar,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.message_outlined), // Changed to message icon
                  tooltip: 'Message ${post.userName}',
                ),
                Text('${post.comments}'),
                const Spacer(),
                IconButton(
                  onPressed: () => _showShareMenu(context, post),
                  icon: const Icon(Icons.share_outlined),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        return RefreshIndicator(
          onRefresh: socialProvider.refreshFeed,
          child: socialProvider.friends.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No friends yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Follow users to see them here!',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: socialProvider.friends.length,
                  itemBuilder: (context, index) {
                    final friend = socialProvider.friends[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(friend.avatar),
                        ),
                        title: Text(friend.name),
                        subtitle: Text('Level ${friend.level} • ${friend.streak} day streak'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                // Navigate to chat with friend
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      userName: friend.name,
                                      userAvatar: friend.avatar,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.message),
                              tooltip: 'Message ${friend.name}',
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UserProfileScreen(
                                      userName: friend.name,
                                      userAvatar: friend.avatar,
                                      userLevel: friend.level,
                                      userStreak: friend.streak,
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.person),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildChallengesTab() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: socialProvider.challenges.length,
          itemBuilder: (context, index) {
            final challenge = socialProvider.challenges[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChallengeDetailScreen(challenge: challenge),
                  ),
                );
              },
              child: Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Video preview or fallback
                    if (challenge.videoUrl != null && challenge.videoUrl!.isNotEmpty)
                      SizedBox(
                        height: 120,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            VideoPlayerWidget(
                              videoUrl: challenge.videoUrl!,
                              height: 120,
                            ),
                            // Overlay with play button hint
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.center,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Tap to view',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  challenge.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.grey[400],
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            challenge.description,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: challenge.progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${challenge.participants} participants',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              Text(
                                '${challenge.daysLeft} days left',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          FutureBuilder<bool>(
                            future: socialProvider.isUserJoinedChallenge(challenge.id),
                            builder: (context, snapshot) {
                              final hasJoined = snapshot.data ?? false;
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    await Provider.of<SocialProvider>(context, listen: false)
                                        .joinChallenge(challenge.id);
                                    setState(() {}); // Refresh to update button state
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: hasJoined
                                        ? Colors.grey[400]
                                        : Theme.of(context).primaryColor,
                                    foregroundColor: hasJoined
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  child: Text(hasJoined ? 'Joined' : 'Join Challenge'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _postController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Share your fitness journey...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    // Add photo
                  },
                  icon: const Icon(Icons.photo_camera),
                ),
                IconButton(
                  onPressed: () {
                    // Add location
                  },
                  icon: const Icon(Icons.location_on),
                ),
                IconButton(
                  onPressed: () {
                    // Add workout
                  },
                  icon: const Icon(Icons.fitness_center),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_postController.text.isNotEmpty) {
                Provider.of<SocialProvider>(context, listen: false)
                    .createPost(_postController.text);
                _postController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkIfUserLikedPost(String postId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    try {
      final response = await Supabase.instance.client
          .from('post_likes')
          .select()
          .eq('post_id', postId)
          .eq('user_id', user.id)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  void _showCommentsBottomSheet(BuildContext context, Post post) {
    final TextEditingController commentController = TextEditingController();
    final ScrollController scrollController = ScrollController();
    String? replyingTo;
    String? replyHint;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    children: [
                      // Handle bar
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),   
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                        ), 
                        child: Row(
                          children: [
                            Text(
                              '${post.comments} Comments',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),

                      // Comments list
                      Expanded(
                        child: FutureBuilder<List<Comment>>(
                          future: Provider.of<SocialProvider>(context, listen: false).getComments(post.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    Text('Error loading comments: ${snapshot.error}'),
                                  ],
                                ),
                              );
                            }

                            final comments = snapshot.data ?? [];

                            if (comments.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No comments yet',
                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Be the first to comment!',
                                      style: TextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundImage: AssetImage(comment.userAvatar),
                                        radius: 16,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  comment.userName,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  _formatTimestamp(comment.timestamp),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              comment.content,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    // Like comment functionality could be added here
                                                  },
                                                  icon: const Icon(Icons.favorite_border, size: 16),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${comment.likes}',
                                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                                ),
                                                const SizedBox(width: 16),
                                                TextButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      replyingTo = comment.userName;
                                                      replyHint = 'Replying to ${comment.userName}';
                                                      // Focus the text field
                                                      Future.delayed(const Duration(milliseconds: 100), () {
                                                        // This would focus the text field in a real implementation
                                                      });
                                                    });
                                                  },
                                                  style: TextButton.styleFrom(
                                                    padding: EdgeInsets.zero,
                                                    minimumSize: const Size(0, 0),
                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  ),
                                                  child: const Text(
                                                    'Reply',
                                                    style: TextStyle(fontSize: 12, color: Colors.blue),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      // Reply indicator (shown when replying)
                      if (replyingTo != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            border: Border(top: BorderSide(color: Colors.blue.withOpacity(0.3))),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  replyHint ?? '',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    replyingTo = null;
                                    replyHint = null;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 16, color: Colors.blue),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),

                      // Comment input - Telegram style
                      Container(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 12,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          border: Border(top: BorderSide(color: Colors.grey[200]!)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Attachment button
                            IconButton(
                              onPressed: () {
                                // Show attachment options
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) => Container(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo),
                                          title: const Text('Photo'),
                                          onTap: () => Navigator.pop(context),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.video_file),
                                          title: const Text('Video'),
                                          onTap: () => Navigator.pop(context),
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.gif),
                                          title: const Text('GIF'),
                                          onTap: () => Navigator.pop(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.attach_file, color: Colors.grey),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),

                            const SizedBox(width: 8),

                            // Text input field - Telegram style
                            Expanded(
                              child: Container(
                                constraints: const BoxConstraints(minHeight: 40, maxHeight: 100),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: TextField(
                                  controller: commentController,
                                  decoration: InputDecoration(
                                    hintText: replyHint ?? 'Write a comment...',
                                    hintStyle: TextStyle(color: Colors.grey[500]),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    suffixIcon: commentController.text.isNotEmpty
                                        ? IconButton(
                                            onPressed: () {
                                              commentController.clear();
                                              setState(() {
                                                replyingTo = null;
                                                replyHint = null;
                                              });
                                            },
                                            icon: const Icon(Icons.clear, size: 16),
                                          )
                                        : null,
                                  ),
                                  maxLines: null,
                                  textCapitalization: TextCapitalization.sentences,
                                  onChanged: (value) {
                                    setState(() {}); // Update UI for send button
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Send button - Telegram style
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: commentController.text.trim().isNotEmpty
                                    ? Colors.blue
                                    : Colors.grey[300],
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                onPressed: commentController.text.trim().isNotEmpty
                                    ? () async {
                                        final content = replyingTo != null
                                            ? '@$replyingTo ${commentController.text.trim()}'
                                            : commentController.text.trim();

                                        await Provider.of<SocialProvider>(context, listen: false)
                                            .addComment(post.id, content);
                                        commentController.clear();

                                        setState(() {
                                          replyingTo = null;
                                          replyHint = null;
                                        });

                                        // Refresh comments
                                        setState(() {});
                                      }
                                    : null,
                                icon: Icon(
                                  commentController.text.trim().isNotEmpty
                                      ? Icons.send
                                      : Icons.mic,
                                  color: commentController.text.trim().isNotEmpty
                                      ? Colors.white
                                      : Colors.grey[600],
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showShareMenu(BuildContext context, Post post) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Share options header
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(post.userAvatar),
                    radius: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          post.content.length > 50
                              ? '${post.content.substring(0, 50)}...'
                              : post.content,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Share options
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share via...'),
              subtitle: const Text('Send to other apps'),
              onTap: () async {
                Navigator.pop(context);
                final postContent = post.content;
                final shareText = '"$postContent" - via FitMax Pro';
                await Share.share(shareText, subject: 'FitMax Pro Post');
              },
            ),
            ListTile(
              leading: const Icon(Icons.send, color: Colors.green),
              title: const Text('Send to Friend'),
              subtitle: const Text('Share with someone on FitMax'),
              onTap: () {
                Navigator.pop(context);
                _showFriendSelector(context, post);
              },
            ),

            ListTile(
              leading: const Icon(Icons.link, color: Colors.green),
              title: const Text('Copy Link'),
              subtitle: const Text('Copy post link to clipboard'),
              onTap: () {
                Navigator.pop(context);
                // In a real app, this would copy the post URL
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link copied to clipboard!')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.message, color: Colors.orange),
              title: const Text('Send in Direct Message'),
              subtitle: const Text('Send to a friend'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to DM screen or show friend selector
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Direct message feature coming soon!')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.bookmark_border, color: Colors.purple),
              title: const Text('Save Post'),
              subtitle: const Text('Add to saved posts'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post saved!')),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text('Report Post'),
              subtitle: const Text('Report inappropriate content'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                  await socialProvider.reportPostNew(post.id, 'Reported via share menu');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post reported')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to report post')),
                  );
                }
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showFriendSelector(BuildContext context, Post post) {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Share with friends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: socialProvider.friends.length,
                itemBuilder: (context, index) {
                  final friend = socialProvider.friends[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(friend.avatar),
                      radius: 20,
                    ),
                    title: Text(friend.name),
                    subtitle: Text('Level ${friend.level}'),
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        await socialProvider.sharePostToUser(post.id, friend.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Post shared with ${friend.name}!')),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to share post')),
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
