import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/social_provider.dart';
import 'chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userName;
  final String userAvatar;
  final int userLevel;
  final int userStreak;

  const UserProfileScreen({
    Key? key,
    required this.userName,
    required this.userAvatar,
    required this.userLevel,
    required this.userStreak,
  }) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isFollowing = false;
  bool _isLoading = true; // Start as loading to check follow status

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
  }

  Future<void> _loadFollowStatus() async {
    try {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);
      final isFollowing = await socialProvider.isFollowing(widget.userName);
      setState(() {
        _isFollowing = isFollowing;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error loading follow status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with back button
          SliverAppBar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            title: Text('${widget.userName}\'s Profile'),
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Profile Header
          SliverToBoxAdapter(
            child: Container(
              color: colorScheme.surface,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Avatar with online status
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: AssetImage(widget.userAvatar),
                        backgroundColor: colorScheme.surfaceVariant,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 3),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Name and Bio
                  Text(
                    widget.userName,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fitness enthusiast | Personal trainer | Health coach',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Location and Join Date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'New York, USA',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        'Joined March 2024',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Level and Streak
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Level ${widget.userLevel} • ${widget.userStreak} day streak',
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatColumn(colorScheme, 'Followers', '1.2K'),
                      _buildStatColumn(colorScheme, 'Following', '850'),
                      _buildStatColumn(colorScheme, 'Posts', '45'),
                      _buildStatColumn(colorScheme, 'Workouts', '127'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _toggleFollow,
                          icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                          label: Text(_isFollowing ? 'Following' : 'Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isFollowing ? colorScheme.surfaceVariant : colorScheme.primary,
                            foregroundColor: _isFollowing ? colorScheme.onSurfaceVariant : colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: _isFollowing ? 0 : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: _sendMessage,
                        icon: const Icon(Icons.message),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceVariant,
                          foregroundColor: colorScheme.onSurfaceVariant,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showMoreOptions,
                        icon: const Icon(Icons.more_vert),
                        style: IconButton.styleFrom(
                          backgroundColor: colorScheme.surfaceVariant,
                          foregroundColor: colorScheme.onSurfaceVariant,
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Recent Activity Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // Activity List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.fitness_center,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Completed ${['Upper Body Power', 'HIIT Cardio', 'Morning Yoga'][index % 3]}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${['2 hours ago', 'Yesterday', '3 days ago'][index % 3]}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                );
              },
              childCount: 5,
            ),
          ),

          // Achievements Section
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),

          // Achievements Grid
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                itemBuilder: (context, index) {
                  final achievements = [
                    {'icon': Icons.emoji_events, 'title': 'First Workout', 'color': Colors.amber},
                    {'icon': Icons.local_fire_department, 'title': '7 Day Streak', 'color': Colors.orange},
                    {'icon': Icons.fitness_center, 'title': 'Strength Master', 'color': Colors.blue},
                    {'icon': Icons.timer, 'title': 'Speed Demon', 'color': Colors.green},
                    {'icon': Icons.star, 'title': 'Consistency King', 'color': Colors.purple},
                    {'icon': Icons.military_tech, 'title': 'Champion', 'color': Colors.red},
                  ];

                  final achievement = achievements[index];

                  return Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: (achievement['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color: achievement['color'] as Color,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          achievement['title'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }

  void _toggleFollow() async {
    final wasFollowing = _isFollowing;
    setState(() {
      _isLoading = true;
    });

    try {
      final socialProvider = Provider.of<SocialProvider>(context, listen: false);

      if (_isFollowing) {
        await socialProvider.unfollowUserNew(widget.userName); // Using username as ID for demo
      } else {
        await socialProvider.followUserNew(widget.userName);
      }

      // Reload follow status to ensure it's accurate
      await _loadFollowStatus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFollowing
                ? 'Now following ${widget.userName}!'
                : 'Unfollowed ${widget.userName}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Revert loading state
      setState(() {
        _isFollowing = wasFollowing;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update follow status'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _sendMessage() {
    // Navigate to real chat screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userName: widget.userName,
          userAvatar: widget.userAvatar,
        ),
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User'),
              subtitle: const Text('Stop seeing posts from this user'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                  await socialProvider.blockUser(widget.userName);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.userName} has been blocked')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to block user')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Report User'),
              subtitle: const Text('Report inappropriate behavior'),
              onTap: () async {
                Navigator.pop(context);
                try {
                  final socialProvider = Provider.of<SocialProvider>(context, listen: false);
                  await socialProvider.reportUser(widget.userName, 'Inappropriate behavior');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${widget.userName} has been reported')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to report user')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.blue),
              title: const Text('Share Profile'),
              subtitle: const Text('Share this profile with others'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile link copied to clipboard!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off, color: Colors.grey),
              title: const Text('Mute Notifications'),
              subtitle: const Text('Stop receiving notifications from this user'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications from ${widget.userName} muted')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(ColorScheme colorScheme, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}