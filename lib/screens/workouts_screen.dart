import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/workout_provider.dart';
import '../models/workout.dart';
import '../utils/theme.dart';
import 'ai_chat_screen.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final double height;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.height,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.videoUrl);
    } else {
      _controller = VideoPlayerController.network(widget.videoUrl);
    }
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      await _controller.setVolume(0.0); // Start muted
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleMute() {
    setState(() {
      if (_controller.value.volume > 0) {
        _controller.setVolume(0.0);
      } else {
        _controller.setVolume(1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Container(
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _showControls = !_showControls;
        });
      },
      child: Stack(
        children: [
          SizedBox(
            height: widget.height,
            width: double.infinity,
            child: VideoPlayer(_controller),
          ),
          if (_showControls)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: _togglePlayPause,
                        icon: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        onPressed: _toggleMute,
                        icon: Icon(
                          _controller.value.volume > 0 ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (!_isPlaying && !_showControls)
            Positioned.fill(
              child: Center(
                child: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white.withOpacity(0.8),
                  size: 64,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _SliverHeaderDelegate({required this.child, required this.height});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

class WorkoutsScreen extends StatefulWidget {
  @override
  _WorkoutsScreenState createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _categories = [
    {'id': 'all', 'name': 'All', 'icon': Icons.fitness_center, 'count': 150},
    {'id': 'strength', 'name': 'Strength', 'icon': Icons.fitness_center, 'count': 45},
    {'id': 'cardio', 'name': 'Cardio', 'icon': Icons.favorite, 'count': 38},
    {'id': 'flexibility', 'name': 'Flexibility', 'icon': Icons.self_improvement, 'count': 25},
    {'id': 'bodyweight', 'name': 'Bodyweight', 'icon': Icons.person, 'count': 42},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          // This will trigger a rebuild of the WorkoutsScreen, including the TabBar
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkoutProvider>(context, listen: false).loadWorkouts();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverHeaderDelegate(
                height: 90, // Adjust based on actual height
                child: Container(
                  color: colorScheme.background,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Search workouts...',
                              hintStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                              prefixIcon: Icon(Icons.search, color: colorScheme.onSurface.withOpacity(0.6)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: () {
                            // Show filter dialog (implement if needed)
                          },
                          icon: Icon(Icons.filter_list, color: colorScheme.onSurfaceVariant),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surface,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.5)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 32,
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Workout Generator',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Get a personalized workout in seconds',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
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
                                builder: (context) => AIChatScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                          ),
                          child: const Text('Generate'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverHeaderDelegate(
                height: 48,
                child: Container(
                  color: colorScheme.background,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: colorScheme.onSurface,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    unselectedLabelColor: colorScheme.onSurfaceVariant,
                    indicatorColor: colorScheme.primary,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Featured'),
                      Tab(text: 'Live Classes'),
                      Tab(text: 'My Workouts'),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildFeaturedTab(),
            _buildLiveClassesTab(),
            _buildMyWorkoutsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTab() {
    return Consumer<WorkoutProvider>(
      builder: (context, workoutProvider, child) {
        final colorScheme = Theme.of(context).colorScheme;
        List<Workout> filteredWorkouts = workoutProvider.workouts;
        if (_selectedCategory != 'all') {
          filteredWorkouts = filteredWorkouts.where((w) => w.category?.toLowerCase() == _selectedCategory).toList();
        }
        if (_searchQuery.isNotEmpty) {
          filteredWorkouts = filteredWorkouts.where((w) => w.title.toLowerCase().contains(_searchQuery)).toList();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await Provider.of<WorkoutProvider>(context, listen: false).loadWorkouts();
          },
          child: CustomScrollView(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  height: 60,
                  child: Container(
                    color: colorScheme.background,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = _selectedCategory == category['id'];
                        final int actualCount = category['id'] == 'all'
                            ? workoutProvider.workouts.length
                            : workoutProvider.workouts
                                .where((w) => w.category?.toLowerCase() == category['id'])
                                .length;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  category['icon'],
                                  size: 16,
                                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category['name'],
                                  style: TextStyle(
                                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? colorScheme.primary.withOpacity(0.1)
                                        : colorScheme.surfaceVariant.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$actualCount',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category['id'];
                              });
                            },
                            selectedColor: colorScheme.primary.withOpacity(0.1),
                            backgroundColor: colorScheme.surface,
                            checkmarkColor: colorScheme.primary,
                            shape: StadiumBorder(side: BorderSide(color: isSelected ? colorScheme.primary.withOpacity(0.3) : colorScheme.surfaceVariant.withOpacity(0.5))),
                            elevation: 0,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final workout = filteredWorkouts[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: _buildWorkoutCard(workout),
                    );
                  },
                  childCount: filteredWorkouts.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLiveClassesTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic for live classes if needed
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Live now section
          Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
            ),
            elevation: 1,
            shadowColor: colorScheme.shadow.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Stack(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundImage: AssetImage(
                          'assets/images/fitness-man.png',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppTheme.successColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: colorScheme.surface, width: 2),
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
                          'Power Yoga',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Starting in 15 min • Sarah M.',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurfaceVariant,
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
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                    ),
                    child: const Text('Join Now'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Upcoming classes
          Text(
            'Upcoming Classes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(3, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: colorScheme.surface,
              elevation: 1,
              shadowColor: colorScheme.shadow.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundImage: AssetImage(
                    'assets/images/fitness-woman.png',
                  ),
                ),
                title: Text(
                  'HIIT Training ${index + 1}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  '2:00 PM • Mike R. • 45 participants',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                trailing: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                    foregroundColor: colorScheme.primary,
                  ),
                  child: const Text('Schedule'),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMyWorkoutsTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return RefreshIndicator(
      onRefresh: () async {
        // Implement refresh logic for my workouts if needed
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Recent workouts
          Text(
            'Recent Workouts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),

          ...List.generate(5, (index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: colorScheme.surface,
              elevation: 1,
              shadowColor: colorScheme.shadow.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
              ),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: colorScheme.tertiary,
                  ),
                ),
                title: Text(
                  'Full Body Strength ${index + 1}',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  'Yesterday • 45 min • 320 calories',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.play_arrow, color: colorScheme.primary),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Personal records
          Card(
            color: colorScheme.surface,
            elevation: 1,
            shadowColor: colorScheme.shadow.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Personal Records',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '185 lbs',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Deadlift PR',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Set 3 days ago',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '2:45',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'Plank Hold',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'Set last week',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 1,
      shadowColor: colorScheme.shadow.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout media (video or image)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            child: Stack(
              children: [
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: workout.videoUrl != null && workout.videoUrl!.isNotEmpty
                      ? VideoPlayerWidget(
                          videoUrl: workout.videoUrl!,
                          height: 200,
                        )
                      : Image.asset(
                          workout.imageUrl,
                          fit: BoxFit.cover,
                        ),
                ),
                // Gradient overlay
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                // Badges
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(workout.difficulty),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      workout.difficulty,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (workout.isPremium)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                // Play button
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.play_circle_outline,
                      size: 64,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Workout details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout.title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'by ${workout.trainer}',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.bookmark_border, color: colorScheme.onSurfaceVariant),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.share, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Workout stats
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStatChip(Icons.access_time, workout.duration),
                    _buildStatChip(Icons.local_fire_department, '${workout.calories} cal'),
                    _buildStatChip(Icons.star, '${workout.rating}'),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  '${workout.completions} completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                          foregroundColor: colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Preview'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
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
  }

  Widget _buildStatChip(IconData icon, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppTheme.successColor.withOpacity(0.8);
      case 'intermediate':
        return AppTheme.warningColor.withOpacity(0.8);
      case 'advanced':
        return AppTheme.errorColor.withOpacity(0.8);
      default:
        return Colors.grey.shade400;
    }
  }
}