import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';

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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    // Handle menu actions
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
                IconButton(
                  onPressed: () {
                    Provider.of<SocialProvider>(context, listen: false)
                        .likePost(post.id);
                  },
                  icon: const Icon(Icons.favorite_border),
                ),
                Text('${post.likes}'),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    _showCommentsDialog(post);
                  },
                  icon: const Icon(Icons.comment_outlined),
                ),
                Text('${post.comments}'),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Share functionality
                  },
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
        return ListView.builder(
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
                        // Message friend
                      },
                      icon: const Icon(Icons.message),
                    ),
                    IconButton(
                      onPressed: () {
                        // View profile
                      },
                      icon: const Icon(Icons.person),
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

  Widget _buildChallengesTab() {
    return Consumer<SocialProvider>(
      builder: (context, socialProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: socialProvider.challenges.length,
          itemBuilder: (context, index) {
            final challenge = socialProvider.challenges[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      challenge.description,
                      style: TextStyle(color: Colors.grey[600]),
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
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<SocialProvider>(context, listen: false)
                              .joinChallenge(challenge.id);
                        },
                        child: const Text('Join Challenge'),
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

  void _showCommentsDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Comments'),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: const Column(
            children: [
              Expanded(
                child: Center(
                  child: Text('No comments yet'),
                ),
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
