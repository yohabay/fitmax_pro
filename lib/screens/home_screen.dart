import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/quick_action_button.dart';
import 'ai_chat_screen.dart';
import 'workouts_screen.dart';
import 'nutrition_screen.dart';
import '../utils/theme.dart';
import 'main_app.dart'; // Added import
import '../providers/navigation_provider.dart'; // Added

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

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
              color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.85),
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
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurfaceVariant ,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTodayStatItem('Calories', '420', Icons.local_fire_department, AppTheme.errorColor),
                _buildTodayStatItem('Active Time', '45m', Icons.timer, AppTheme.accentColor),
                _buildTodayStatItem('Steps', '8,432', Icons.directions_walk, AppTheme.successColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChallenge() {
    return ChallengeCard(
      title: '50 Push-ups Challenge',
      progress: 32,
      target: 50,
      xpReward: 100,
      onTap: () {},
    );
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
            color: Theme.of(context).colorScheme.onSurfaceVariant ,
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
                Provider.of<NavigationProvider>(context, listen: false).setIndex(2); // Navigate to Nutrition tab
                Provider.of<NavigationProvider>(context, listen: false).showManualEntry(); // Show manual entry modal
              },
            ),
            QuickActionButton(
              title: 'Live Classes',
              subtitle: 'Join live sessions',
              icon: Icons.video_call,
              color: AppTheme.secondaryColor,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTodayStatItem(String title, String value, IconData icon, Color color) {
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
}