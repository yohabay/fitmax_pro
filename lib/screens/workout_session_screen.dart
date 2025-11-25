import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../models/workout.dart';
import '../models/progress.dart';
import '../providers/progress_provider.dart';
import '../utils/theme.dart';
import 'workouts_screen.dart'; // For VideoPlayerWidget

class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({Key? key, required this.workout}) : super(key: key);

  @override
  _WorkoutSessionScreenState createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> with TickerProviderStateMixin {
  late Timer _timer;
  int _secondsElapsed = 0;
  bool _isRunning = false;
  int _currentExerciseIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) {
        setState(() {
          _secondsElapsed++;
        });
      }
    });
  }

  void _toggleWorkout() {
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  void _nextExercise() {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
      });
    }
  }

  void _previousExercise() {
    if (_currentExerciseIndex > 0) {
      setState(() {
        _currentExerciseIndex--;
      });
    }
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  int _parseDurationToMinutes(String duration) {
    // Parse duration strings like "45 min", "30 min", etc.
    final match = RegExp(r'(\d+)').firstMatch(duration);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    return 30; // Default to 30 minutes if parsing fails
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentExercise = widget.workout.exercises.isNotEmpty
        ? widget.workout.exercises[_currentExerciseIndex]
        : null;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.workout.title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _formatTime(_secondsElapsed),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: [const FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: widget.workout.exercises.isNotEmpty
                ? (_currentExerciseIndex + 1) / widget.workout.exercises.length
                : 1.0,
            backgroundColor: colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),

          // Workout video
          if (widget.workout.videoUrl != null && widget.workout.videoUrl!.isNotEmpty)
            Container(
              height: 250,
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: VideoPlayerWidget(
                  videoUrl: widget.workout.videoUrl!,
                  height: 250,
                ),
              ),
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current exercise
                  if (currentExercise != null) ...[
                    Card(
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${currentExercise.sets} sets × ${currentExercise.reps} reps',
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              currentExercise.name,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (currentExercise.instructions != null &&
                                currentExercise.instructions!.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                currentExercise.instructions!,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                            if (currentExercise.weight != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    Icons.fitness_center,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Weight: ${currentExercise.weight}',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            if (currentExercise.duration != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Duration: ${currentExercise.duration}',
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // No exercises available
                    Card(
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.fitness_center,
                                size: 64,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No exercises available',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'This workout doesn\'t have detailed exercises yet.',
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Workout stats
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Duration',
                          widget.workout.duration,
                          Icons.access_time,
                          colorScheme,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Calories',
                          '${widget.workout.calories}',
                          Icons.local_fire_department,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Control buttons
                  Row(
                    children: [
                      if (_currentExerciseIndex > 0)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _previousExercise,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Previous'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                              foregroundColor: colorScheme.primary,
                            ),
                          ),
                        ),
                      if (_currentExerciseIndex > 0) const SizedBox(width: 12),

                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: _toggleWorkout,
                          icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                          label: Text(_isRunning ? 'Pause' : 'Start'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isRunning ? colorScheme.secondary : colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 0,
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      if (_currentExerciseIndex < widget.workout.exercises.length - 1)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _nextExercise,
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('Next'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              // Calculate calories burned based on duration and workout intensity
                              final minutes = _secondsElapsed / 60;
                              final caloriesBurned = (widget.workout.calories * (minutes / _parseDurationToMinutes(widget.workout.duration))).round();

                              // Create workout session
                              final session = WorkoutSession(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                date: DateTime.now(),
                                workoutName: widget.workout.title,
                                duration: (_secondsElapsed / 60).round(), // Convert to minutes
                                caloriesBurned: caloriesBurned,
                                exercises: widget.workout.exercises.map((e) => ExerciseLog(
                                  name: e.name,
                                  sets: e.sets,
                                  reps: e.reps,
                                  weight: e.weight != null ? double.tryParse(e.weight!.split(' ')[0]) ?? 0 : 0,
                                )).toList(),
                              );

                              // Save to database
                              final progressProvider = Provider.of<ProgressProvider>(context, listen: false);
                              await progressProvider.addWorkoutSession(session);

                              // Finish workout
                              if (mounted) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Workout Complete!'),
                                    content: Text(
                                      'Great job! You completed ${widget.workout.title} in ${_formatTime(_secondsElapsed)} and burned $caloriesBurned calories.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context).pop(),
                                        child: const Text('Continue'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop(); // Close dialog
                                          Navigator.of(context).pop(); // Close workout screen
                                        },
                                        child: const Text('Finish'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Finish'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.successColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
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

  Widget _buildStatCard(String title, String value, IconData icon, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.surfaceVariant.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}