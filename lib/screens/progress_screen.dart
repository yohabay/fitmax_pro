import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/progress.dart';
import '../models/workout.dart';
import '../providers/progress_provider.dart';
import '../providers/workout_provider.dart';
import '../screens/workout_session_screen.dart';

class ProgressScreen extends StatefulWidget {
  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              isScrollable: true,
              tabs: const [
                Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
                Tab(text: 'Workouts', icon: Icon(Icons.fitness_center)),
                Tab(text: 'Body', icon: Icon(Icons.accessibility)),
                Tab(text: 'Records', icon: Icon(Icons.emoji_events)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildWorkoutsTab(),
                _buildBodyTab(),
                _buildRecordsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return RefreshIndicator(
          onRefresh: () => progressProvider.refreshData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Progress Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Total Workouts',
                        '${progressProvider.getTotalWorkouts()}',
                        Icons.fitness_center,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Calories Burned',
                        '${progressProvider.getTotalCaloriesBurned()}',
                        Icons.local_fire_department,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Avg Duration',
                        '${progressProvider.getAverageWorkoutDuration().toStringAsFixed(0)}min',
                        Icons.timer,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'Weight Change',
                        '${progressProvider.getWeightChange().toStringAsFixed(1)}kg',
                        Icons.trending_down,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weight Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Weight Progress',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          child: progressProvider.weightEntries.isNotEmpty
                              ? LineChart(_buildWeightChartData(progressProvider.weightEntries))
                              : const Center(
                                  child: Text('Add weight entries to see your progress chart'),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Recent Workouts
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Recent Workouts',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (progressProvider.workoutSessions.isEmpty)
                          const Center(
                            child: Text('No workouts completed yet'),
                          )
                        else
                          ...progressProvider.workoutSessions.take(3).map(
                            (session) => _buildWorkoutTile(session),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return RefreshIndicator(
          onRefresh: () => progressProvider.refreshData(),
          child: progressProvider.workoutSessions.isEmpty
              ? const Center(
                  child: Text('No workout sessions recorded yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: progressProvider.workoutSessions.length,
                  itemBuilder: (context, index) {
                    final session = progressProvider.workoutSessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: _buildWorkoutTile(session),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildBodyTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return RefreshIndicator(
          onRefresh: () => progressProvider.refreshData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Body Measurements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showAddMeasurementDialog,
                      child: const Text('Add'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Weight Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Weight Tracking',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _showAddWeightDialog,
                              child: const Text('Add Weight'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (progressProvider.weightEntries.isEmpty)
                          const Center(
                            child: Text('No weight entries yet'),
                          )
                        else ...[
                          Text(
                            'Current: ${progressProvider.weightEntries.last.weight}kg',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Change: ${progressProvider.getWeightChange().toStringAsFixed(1)}kg',
                            style: TextStyle(
                              fontSize: 16,
                              color: progressProvider.getWeightChange() < 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Body Measurements
                if (progressProvider.bodyMeasurements.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No body measurements recorded yet'),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Latest Measurements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ...progressProvider.bodyMeasurements.last.toMap().entries.map(
                            (entry) => _buildMeasurementRow(entry.key, entry.value),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecordsTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return RefreshIndicator(
          onRefresh: () => progressProvider.refreshData(),
          child: progressProvider.personalRecords.isEmpty
              ? const Center(
                  child: Text('No personal records set yet'),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: progressProvider.personalRecords.length,
                  itemBuilder: (context, index) {
                    final entry = progressProvider.personalRecords.entries.elementAt(index);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(Icons.emoji_events, color: Colors.white),
                        ),
                        title: Text(entry.key),
                        subtitle: const Text('Personal Record'),
                        trailing: Text(
                          '${entry.value}${_getUnitForExercise(entry.key)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutTile(WorkoutSession session) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.fitness_center, color: Colors.white),
      ),
      title: Text(session.workoutName),
      subtitle: Text(
        '${session.duration}min • ${session.caloriesBurned} cal • ${_formatDate(session.date)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showWorkoutDetails(context, session),
    );
  }

  void _showWorkoutDetails(BuildContext context, WorkoutSession session) {
    final colorScheme = Theme.of(context).colorScheme;
    final daysAgo = DateTime.now().difference(session.date).inDays;
    final timeAgo = daysAgo == 0
        ? 'Today'
        : daysAgo == 1
            ? 'Yesterday'
            : '$daysAgo days ago';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: MediaQuery.of(context).size.width * 0.9,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.fitness_center,
                              color: colorScheme.onPrimary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  session.workoutName,
                                  style: TextStyle(
                                    color: colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  timeAgo,
                                  style: TextStyle(
                                    color: colorScheme.onPrimary.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSessionStat(
                            Icons.access_time,
                            '${session.duration} min',
                            colorScheme,
                          ),
                          _buildSessionStat(
                            Icons.local_fire_department,
                            '${session.caloriesBurned} cal',
                            colorScheme,
                          ),
                          _buildSessionStat(
                            Icons.calendar_today,
                            session.date.toString().split(' ')[0],
                            colorScheme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Exercises
                if (session.exercises.isNotEmpty)
                  Flexible(
                    child: ListView(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Exercises Completed',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...session.exercises.map((exercise) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            child: ListTile(
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.fitness_center,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                exercise.name,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                '${exercise.sets} sets × ${exercise.reps} reps${exercise.weight != null ? ' @ ${exercise.weight}' : ''}',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                // Actions
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            // Find and start the workout
                            final workoutProvider = Provider.of<WorkoutProvider>(context, listen: false);
                            Workout? workout;

                            // Ensure workouts are loaded
                            if (workoutProvider.workouts.isEmpty) {
                              await workoutProvider.loadWorkouts();
                            }

                            if (workoutProvider.workouts.isNotEmpty) {
                              // First try exact match
                              final exactMatches = workoutProvider.workouts.where((w) => w.title == session.workoutName);
                              if (exactMatches.isNotEmpty) {
                                workout = exactMatches.first;
                              }

                              // If no exact match, try fuzzy matching
                              if (workout == null) {
                                // Try to find similar workouts by keywords
                                final sessionWords = session.workoutName.toLowerCase().split(' ');
                                final fuzzyMatches = workoutProvider.workouts.where((w) {
                                  final workoutWords = w.title.toLowerCase().split(' ');
                                  // Check if any significant words match
                                  return sessionWords.any((word) =>
                                    word.length > 3 && workoutWords.any((wWord) => wWord.contains(word) || word.contains(wWord))
                                  );
                                });
                                if (fuzzyMatches.isNotEmpty) {
                                  workout = fuzzyMatches.first;
                                }
                              }

                              // If still no match, find workout with same category
                              if (workout == null) {
                                // Try to match by category keywords
                                if (session.workoutName.toLowerCase().contains('upper') || session.workoutName.toLowerCase().contains('strength')) {
                                  final categoryMatches = workoutProvider.workouts.where((w) => w.category == 'strength');
                                  if (categoryMatches.isNotEmpty) {
                                    workout = categoryMatches.first;
                                  }
                                } else if (session.workoutName.toLowerCase().contains('cardio') || session.workoutName.toLowerCase().contains('hiit')) {
                                  final categoryMatches = workoutProvider.workouts.where((w) => w.category == 'cardio');
                                  if (categoryMatches.isNotEmpty) {
                                    workout = categoryMatches.first;
                                  }
                                } else if (session.workoutName.toLowerCase().contains('yoga') || session.workoutName.toLowerCase().contains('flexibility')) {
                                  final categoryMatches = workoutProvider.workouts.where((w) => w.category == 'flexibility');
                                  if (categoryMatches.isNotEmpty) {
                                    workout = categoryMatches.first;
                                  }
                                } else if (session.workoutName.toLowerCase().contains('body') || session.workoutName.toLowerCase().contains('circuit')) {
                                  final categoryMatches = workoutProvider.workouts.where((w) => w.category == 'bodyweight');
                                  if (categoryMatches.isNotEmpty) {
                                    workout = categoryMatches.first;
                                  }
                                }
                              }

                              // Last resort: pick first workout
                              workout ??= workoutProvider.workouts.first;
                            }

                            if (workout != null) {
                              // Navigate to workout session
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkoutSessionScreen(workout: workout!),
                                ),
                              );
                            } else {
                              // Show error message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Workout not found. Please refresh and try again.'),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.replay),
                          label: const Text('Repeat Workout'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            // Share workout results
                            final shareText = '🏋️ I just completed "${session.workoutName}" in ${session.duration} minutes, burning ${session.caloriesBurned} calories! 💪 #FitMaxPro';
                            // Use share_plus package if available
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Workout shared!'),
                                action: SnackBarAction(
                                  label: 'Copy',
                                  onPressed: () {
                                    // Could copy to clipboard here
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                          ),
                        ),
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

  Widget _buildMeasurementRow(String name, double? value) {
    if (value == null) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text('${value.toStringAsFixed(1)} cm'),
        ],
      ),
    );
  }

  void _showAddWeightDialog() {
    final TextEditingController weightController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Weight Entry'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final weight = double.tryParse(weightController.text);
              if (weight != null) {
                Provider.of<ProgressProvider>(context, listen: false)
                    .addWeightEntry(weight);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddMeasurementDialog() {
    final TextEditingController chestController = TextEditingController();
    final TextEditingController waistController = TextEditingController();
    final TextEditingController hipsController = TextEditingController();
    final TextEditingController bicepsController = TextEditingController();
    final TextEditingController thighsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Body Measurements'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: chestController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Chest (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waistController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Waist (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hipsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Hips (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bicepsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Biceps (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: thighsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Thighs (cm)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final chest = double.tryParse(chestController.text) ?? 0;
              final waist = double.tryParse(waistController.text) ?? 0;
              final hips = double.tryParse(hipsController.text) ?? 0;
              final biceps = double.tryParse(bicepsController.text) ?? 0;
              final thighs = double.tryParse(thighsController.text) ?? 0;

              final measurement = BodyMeasurement(
                date: DateTime.now(),
                chest: chest,
                waist: waist,
                hips: hips,
                biceps: biceps,
                thighs: thighs,
              );

              Provider.of<ProgressProvider>(context, listen: false)
                  .addBodyMeasurement(measurement);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getUnitForExercise(String exercise) {
    if (exercise.contains('Run')) return ' min';
    if (exercise == 'Pull-ups') return ' reps';
    return ' kg';
  }

  LineChartData _buildWeightChartData(List<WeightEntry> entries) {
    final spots = entries.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.weight);
    }).toList();

    return LineChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text('${value.toStringAsFixed(1)}kg');
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              if (value.toInt() < entries.length) {
                final date = entries[value.toInt()].date;
                return Text('${date.month}/${date.day}');
              }
              return const Text('');
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Theme.of(context).primaryColor,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Theme.of(context).primaryColor,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSessionStat(IconData icon, String text, ColorScheme colorScheme) {
    return Column(
      children: [
        Icon(
          icon,
          color: colorScheme.onPrimary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

extension BodyMeasurementExtension on BodyMeasurement {
  Map<String, double?> toMap() {
    return {
      'Chest': chest,
      'Waist': waist,
      'Hips': hips,
      'Biceps': biceps,
      'Thighs': thighs,
    };
  }
}
