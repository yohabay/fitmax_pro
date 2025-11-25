import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/navigation_provider.dart'; // Added
import '../providers/social_provider.dart';
import '../providers/user_provider.dart';
import '../utils/theme.dart';
import '../widgets/challenge_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/stat_card.dart';
import 'ai_chat_screen.dart';
import 'challenge_detail_screen.dart';
import 'live_class_screen.dart';
import 'workouts_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(seconds: 1));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeHeader(userProvider),
                        const SizedBox(height: 24),
                        _buildStatsRow(userProvider),
                        const SizedBox(height: 24),
                        _buildTodayProgress(),
                        const SizedBox(height: 24),
                        _buildDailyChallenge(),
                        const SizedBox(height: 24),
                        _buildQuickActions(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeHeader(UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back, ${userProvider.user?.name ?? 'User'}!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              shadows: [
                Shadow(
                  blurRadius: 3,
                  color: Colors.black38,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re on a ${userProvider.user?.streak ?? 0}-day streak! Keep it up!',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(
                context,
              ).colorScheme.onPrimaryContainer.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(UserProvider userProvider) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Level',
            value: '${userProvider.user?.level ?? 1}',
            icon: Icons.emoji_events,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'XP Points',
            value: '${userProvider.user?.xp ?? 0}',
            icon: Icons.bolt,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayProgress() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTodayStatItem(
                  'Calories',
                  '420',
                  Icons.local_fire_department,
                  AppTheme.errorColor,
                ),
                _buildTodayStatItem(
                  'Active Time',
                  '45m',
                  Icons.timer,
                  AppTheme.accentColor,
                ),
                _buildTodayStatItem(
                  'Steps',
                  '8,432',
                  Icons.directions_walk,
                  AppTheme.successColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return FutureBuilder<List<String>>(
      future: _getJoinedChallengeIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final joinedChallengeIds = snapshot.data ?? [];
        final socialProvider = Provider.of<SocialProvider>(
          context,
          listen: false,
        );
        final joinedChallenges =
            socialProvider.challenges
                .where((challenge) => joinedChallengeIds.contains(challenge.id))
                .toList();

        if (joinedChallenges.isEmpty) {
          // Show default challenge if no joined challenges
          return ChallengeCard(
            title: '50 Push-ups Challenge',
            progress: 32,
            target: 50,
            xpReward: 100,
            onTap: () {},
          );
        }

        // Show all joined challenges
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Challenges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ...joinedChallenges.map(
              (challenge) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ChallengeCard(
                  title: challenge.title,
                  progress: (challenge.progress * 100).toInt(),
                  target: 100, // Assuming 100% completion
                  xpReward: 100,
                  onTap: () {
                    // Navigate to challenge detail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                ChallengeDetailScreen(challenge: challenge),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<String>> _getJoinedChallengeIds() async {
    final socialProvider = Provider.of<SocialProvider>(context, listen: false);
    final joinedIds = <String>[];

    for (final challenge in socialProvider.challenges) {
      final isJoined = await socialProvider.isUserJoinedChallenge(challenge.id);
      if (isJoined) {
        joinedIds.add(challenge.id);
      }
    }

    return joinedIds;
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            QuickActionButton(
              title: 'Start Workout',
              subtitle: 'Begin your session',
              icon: Icons.play_arrow,
              color: AppTheme.primaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WorkoutsScreen()),
                );
              },
            ),
            QuickActionButton(
              title: 'AI Coach',
              subtitle: 'Get personalized advice',
              icon: Icons.psychology,
              color: AppTheme.accentColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AIChatScreen()),
                );
              },
            ),
            QuickActionButton(
              title: 'Log Meal',
              subtitle: 'Track your nutrition',
              icon: Icons.camera_alt,
              color: AppTheme.successColor,
              onTap: () {
                Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                ).setIndex(2); // Navigate to Nutrition tab
                Provider.of<NavigationProvider>(
                  context,
                  listen: false,
                ).showManualEntry(); // Show manual entry modal
              },
            ),
            QuickActionButton(
              title: 'Live Classes',
              subtitle: 'Join live sessions',
              icon: Icons.video_call,
              color: AppTheme.secondaryColor,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => WorkoutsScreen(
                          initialTabIndex: 1,
                        ), // 1 is the Live Classes tab
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLiveClassesForChallenges() {
    return FutureBuilder<List<String>>(
      future: _getJoinedChallengeIds(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final joinedChallengeIds = snapshot.data ?? [];
        if (joinedChallengeIds.isEmpty) {
          return const SizedBox.shrink();
        }

        final socialProvider = Provider.of<SocialProvider>(
          context,
          listen: false,
        );
        final joinedChallenges =
            socialProvider.challenges
                .where((challenge) => joinedChallengeIds.contains(challenge.id))
                .toList();

        if (joinedChallenges.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show live classes for joined challenges
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Live Classes for Your Challenges',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                // Live now section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceVariant.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            backgroundImage: AssetImage(
                              'assets/images/fitness-woman.png',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppTheme.successColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${joinedChallenges.first.title} Live Session',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              'Starting in 15 min • Sarah M.',
                              style: TextStyle(
                                fontSize: 14,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.errorColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '🔴 LIVE',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => LiveClassScreen(
                                    className:
                                        '${joinedChallenges.first.title} Live Session',
                                    instructor: 'Sarah M.',
                                  ),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.primary,
                        ),
                        child: const Text('Join Now'),
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
  }
}
