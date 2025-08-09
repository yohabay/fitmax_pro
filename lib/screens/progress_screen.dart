import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/progress.dart';
import '../providers/progress_provider.dart';

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
        return SingleChildScrollView(
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
                        child: const Center(
                          child: Text('Weight chart would go here'),
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
                      ...progressProvider.workoutSessions.take(3).map(
                        (session) => _buildWorkoutTile(session),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: progressProvider.workoutSessions.length,
          itemBuilder: (context, index) {
            final session = progressProvider.workoutSessions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildWorkoutTile(session),
            );
          },
        );
      },
    );
  }

  Widget _buildBodyTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return SingleChildScrollView(
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
                      if (progressProvider.weightEntries.isNotEmpty) ...[
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
              if (progressProvider.bodyMeasurements.isNotEmpty) ...[
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecordsTab() {
    return Consumer<ProgressProvider>(
      builder: (context, progressProvider, child) {
        return ListView.builder(
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
      onTap: () {
        // Navigate to workout details
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
    // Implementation for adding body measurements
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Body Measurements'),
        content: const Text('Body measurement form would go here'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
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
