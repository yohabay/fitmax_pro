import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../providers/nutrition_provider.dart';
import '../providers/progress_provider.dart';
import '../models/nutrition.dart';
import 'barcode_scanner_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({Key? key}) : super(key: key);

  static final GlobalKey<_NutritionScreenState> globalKey = GlobalKey();

  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NutritionProvider>(context, listen: false).loadNutritionData();
    });
  }

  void showManualEntryModal() {
    _showManualEntry();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NutritionProvider>( 
      builder: (context, nutritionProvider, child) {
        return SingleChildScrollView(
          child: Column(
            children: [
              // Daily calorie overview
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Daily Nutrition Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${nutritionProvider.dailyCalories.remaining}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Calories Remaining',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCalorieItem(
                          'Consumed',
                          '${nutritionProvider.dailyCalories.consumed}',
                          Colors.white,
                        ),
                        _buildCalorieItem(
                          'Target',
                          '${nutritionProvider.dailyCalories.target}',
                          Colors.white,
                        ),
                        _buildCalorieItem(
                          'Burned',
                          '${nutritionProvider.dailyCalories.burned}',
                          Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: nutritionProvider.dailyCalories.consumed /
                          nutritionProvider.dailyCalories.target,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 8,
                    ),
                  ],
                ),
              ),

              // Quick actions
              Container(
                height: 160,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.5,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildQuickAction(
                      'Scan Food',
                      Icons.camera_alt,
                      Colors.green,
                      () => _showFoodScanner(),
                    ),
                    _buildQuickAction(
                      'AI Meal Plan',
                      Icons.psychology,
                      Colors.purple,
                      () => _showMealPlanner(),
                    ),
                    _buildQuickAction(
                      'Barcode Scan',
                      Icons.qr_code_scanner,
                      Colors.blue,
                      () => _showBarcodeScanner(),
                    ),
                    _buildQuickAction(
                      'Manual Entry',
                      Icons.add,
                      Colors.orange,
                      () => _showManualEntry(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tab bar
              Material(
                color: Theme.of(context).colorScheme.surface, // Or Theme.of(context).scaffoldBackgroundColor
                child: TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: Theme.of(context).primaryColor,
                  tabs: const [
                    Tab(text: 'Today'),
                    Tab(text: 'Macros'),
                    Tab(text: 'Insights'),
                  ],
                ),
              ),

              // Tab content
              IndexedStack(
                index: _tabController.index,
                children: [
                  Visibility(
                    visible: _tabController.index == 0,
                    child: _buildTodayTab(nutritionProvider),
                  ),
                  Visibility(
                    visible: _tabController.index == 1,
                    child: _buildMacrosTab(nutritionProvider),
                  ),
                  Visibility(
                    visible: _tabController.index == 2,
                    child: _buildInsightsTab(nutritionProvider),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalorieItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTab(NutritionProvider provider) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Water intake
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.blue),
                    const SizedBox(width: 8),
                    const Text(
                      'Water Intake',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => provider.addWaterGlass(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Glass'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      '${provider.waterIntake.current} / ${provider.waterIntake.target} glasses',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    ...List.generate(provider.waterIntake.target, (index) {
                      return Container(
                        margin: const EdgeInsets.only(left: 4),
                        width: 20,
                        height: 30,
                        decoration: BoxDecoration(
                          color: index < provider.waterIntake.current
                              ? Colors.blue
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: provider.waterIntake.current / provider.waterIntake.target,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Today's meals
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Today\'s Meals',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.todaysMeals.map((meal) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: AssetImage(meal.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    meal.mealType,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${meal.calories}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const Text(
                                    ' cal',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                meal.foodName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Text(
                                    meal.time,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    'P: ${meal.macros.protein}g',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'C: ${meal.macros.carbs}g',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'F: ${meal.macros.fat}g',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange,
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
                }).toList(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Intermittent fasting
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Intermittent Fasting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<int>(
                      onSelected: (hours) => provider.setFastingGoal(hours),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 12, child: Text('12:12 Fast')),
                        const PopupMenuItem(value: 14, child: Text('14:10 Fast')),
                        const PopupMenuItem(value: 16, child: Text('16:8 Fast')),
                        const PopupMenuItem(value: 18, child: Text('18:6 Fast')),
                        const PopupMenuItem(value: 20, child: Text('20:4 Fast')),
                      ],
                      child: Row(
                        children: [
                          Text(
                            '${provider.fastingGoalHours}:${(24 - provider.fastingGoalHours).toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.blue),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        provider.fastingTimer.timeRemaining,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        provider.isFasting ? 'Time remaining in fast' : 'Ready to start fasting',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: provider.fastingTimer.progress,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.isFasting
                            ? '${(provider.fastingTimer.progress * 100).round()}% complete'
                            : 'Tap Start Fast to begin',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          if (provider.isFasting) ...[
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => provider.endFast(),
                                child: const Text('End Fast'),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: provider.isFasting
                                  ? () => provider.endFast()
                                  : () => provider.startFast(),
                              icon: Icon(provider.isFasting ? Icons.stop : Icons.play_arrow),
                              label: Text(provider.isFasting ? 'End Fast' : 'Start Fast'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Fasting History
                if (provider.fastingHistory.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Fasts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...provider.fastingHistory.take(3).map((session) {
                    final duration = session.duration;
                    final hours = duration.inHours;
                    final minutes = duration.inMinutes.remainder(60);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            session.completed ? Icons.check_circle : Icons.cancel,
                            color: session.completed ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${hours}h ${minutes}m fast',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${session.startTime.day}/${session.startTime.month} ${session.startTime.hour.toString().padLeft(2, '0')}:${session.startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: session.completed ? Colors.green[100] : Colors.red[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              session.completed ? 'Completed' : 'Incomplete',
                              style: TextStyle(
                                fontSize: 10,
                                color: session.completed ? Colors.green[700] : Colors.red[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacrosTab(NutritionProvider provider) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Macronutrients',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.macros.entries.map((entry) {
                  final macro = entry.key;
                  final data = entry.value;
                  final progress = data.current / data.target;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getMacroColor(macro),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              macro.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${data.current}g / ${data.target}g',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getMacroColor(macro),
                          ),
                          minHeight: 8,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${(progress * 100).round()}% of daily goal',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsTab(NutritionProvider provider) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        // Nutrition insights
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nutrition Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.insights.map((insight) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getInsightColor(insight.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getInsightColor(insight.type).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getInsightIcon(insight.type),
                          color: _getInsightColor(insight.type),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                insight.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                insight.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '+${insight.xpReward} XP',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Weekly summary
        Consumer<ProgressProvider>(
          builder: (context, progressProvider, child) {
            final workoutSessions = progressProvider.workoutSessions;
            final weekSessions = workoutSessions.where((session) {
              final sessionDate = session.date;
              final now = DateTime.now();
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              return sessionDate.isAfter(weekStart) || sessionDate.isAtSameMomentAs(weekStart);
            }).toList();

            final totalCalories = weekSessions.fold<int>(0, (sum, session) => sum + session.caloriesBurned);
            final daysOnTrack = weekSessions.length; // Could be more sophisticated

            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'This Week\'s Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.indigo[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$daysOnTrack/7',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo[600],
                                  ),
                                ),
                                const Text(
                                  'Workout days',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  totalCalories.toString(),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green[600],
                                  ),
                                ),
                                const Text(
                                  'Calories burned',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
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
            );
          },
        ),
      ],
    );
  }

  Color _getMacroColor(String macro) {
    switch (macro.toLowerCase()) {
      case 'protein':
        return Colors.red;
      case 'carbs':
        return Colors.blue;
      case 'fat':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Color _getInsightColor(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'info':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getInsightIcon(String type) {
    switch (type.toLowerCase()) {
      case 'success':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'info':
        return Icons.info;
      default:
        return Icons.lightbulb;
    }
  }

  void _showFoodScanner() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Analyzing Food'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Processing image...',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ],
          ),
        ),
      );

      // Simulate API processing delay
      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop(); // Close processing dialog

      // Show results dialog (in a real app, this would come from API)
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Food Detected'),
          content: const Text(
            'We detected "Grilled Chicken Salad". Would you like to add this to your meals, or enter details manually?'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _showManualEntry(); // Open manual entry with pre-filled data
              },
              child: const Text('Edit Details'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Add detected meal
                final meal = Meal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  mealType: 'Lunch',
                  foodName: 'Grilled Chicken Salad',
                  calories: 350,
                  time: DateTime.now().toString().split(' ')[1].substring(0, 5),
                  imageUrl: 'assets/images/placeholder.jpg',
                  macros: MacroData(
                    protein: 35.0,
                    carbs: 15.0,
                    fat: 18.0,
                  ),
                );

                Provider.of<NutritionProvider>(context, listen: false).addMeal(meal);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Grilled Chicken Salad added to your meals!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Add Meal'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No image selected'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showMealPlanner() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('AI Meal Planner'),
        content: const Text('Generate personalized meal suggestions based on your goals and preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _generateMealPlan();
            },
            child: const Text('Generate Plan'),
          ),
        ],
      ),
    );
  }

  void _generateMealPlan() {
    // Sample meal suggestions based on current nutrition data
    final nutritionProvider = Provider.of<NutritionProvider>(context, listen: false);
    final currentCalories = nutritionProvider.dailyCalories.consumed;
    final remainingCalories = nutritionProvider.dailyCalories.remaining;

    List<Map<String, dynamic>> mealSuggestions = [
      {
        'name': 'Grilled Chicken Breast',
        'calories': 165,
        'protein': 31,
        'carbs': 0,
        'fat': 3.6,
        'mealType': 'Lunch'
      },
      {
        'name': 'Quinoa Salad',
        'calories': 222,
        'protein': 8,
        'carbs': 39,
        'fat': 3.5,
        'mealType': 'Lunch'
      },
      {
        'name': 'Greek Yogurt Parfait',
        'calories': 180,
        'protein': 15,
        'carbs': 25,
        'fat': 2,
        'mealType': 'Snack'
      },
      {
        'name': 'Salmon with Vegetables',
        'calories': 280,
        'protein': 25,
        'carbs': 10,
        'fat': 18,
        'mealType': 'Dinner'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Meal Suggestions',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Based on your remaining ${remainingCalories} calories',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Meal suggestions
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mealSuggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = mealSuggestions[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: Theme.of(context).colorScheme.primary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion['name'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${suggestion['mealType']} • ${suggestion['calories']} cal',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      'P: ${suggestion['protein']}g',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'C: ${suggestion['carbs']}g',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'F: ${suggestion['fat']}g',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);

                              final meal = Meal(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                mealType: suggestion['mealType'],
                                foodName: suggestion['name'],
                                calories: suggestion['calories'],
                                time: DateTime.now().toString().split(' ')[1].substring(0, 5),
                                imageUrl: 'assets/images/placeholder.jpg',
                                macros: MacroData(
                                  protein: suggestion['protein'].toDouble(),
                                  carbs: suggestion['carbs'].toDouble(),
                                  fat: suggestion['fat'].toDouble(),
                                ),
                              );

                              Provider.of<NutritionProvider>(context, listen: false).addMeal(meal);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${meal.foodName} added to your meals!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBarcodeScanner() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));
    if (result != null) {
      // Show processing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Looking up Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Searching database for barcode: $result',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Simulate API lookup delay
      await Future.delayed(const Duration(seconds: 2));

      Navigator.of(context).pop(); // Close processing dialog

      // Mock product data (in a real app, this would come from an API)
      final mockProducts = {
        '123456789012': {
          'name': 'Protein Bar',
          'calories': 220,
          'protein': 20.0,
          'carbs': 18.0,
          'fat': 8.0,
        },
        '987654321098': {
          'name': 'Greek Yogurt',
          'calories': 150,
          'protein': 15.0,
          'carbs': 12.0,
          'fat': 5.0,
        },
      };

      final product = mockProducts[result] ?? {
        'name': 'Unknown Product',
        'calories': 100,
        'protein': 5.0,
        'carbs': 15.0,
        'fat': 3.0,
      };

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Product Found'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product['name'] as String,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('Barcode: $result'),
              const SizedBox(height: 12),
              Text('Nutrition per serving:'),
              Text('• Calories: ${product['calories'] as int}'),
              Text('• Protein: ${product['protein'] as double}g'),
              Text('• Carbs: ${product['carbs'] as double}g'),
              Text('• Fat: ${product['fat'] as double}g'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();

                final meal = Meal(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  mealType: 'Snack',
                  foodName: product['name'] as String,
                  calories: product['calories'] as int,
                  time: DateTime.now().toString().split(' ')[1].substring(0, 5),
                  imageUrl: 'assets/images/placeholder.jpg',
                  macros: MacroData(
                    protein: product['protein'] as double,
                    carbs: product['carbs'] as double,
                    fat: product['fat'] as double,
                  ),
                );

                Provider.of<NutritionProvider>(context, listen: false).addMeal(meal);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${meal.foodName} added to your meals!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Add to Meals'),
            ),
          ],
        ),
      );
    }
  }

  void _showManualEntry() {
    final _formKey = GlobalKey<FormState>();

    final nameController = TextEditingController();
    final servingSizeController = TextEditingController();

    int calories = 0;
    int protein = 0;
    int carbs = 0;
    int fat = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  spreadRadius: 6,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 48,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),

                      // Title
                      const Text(
                        'Add Food Manually',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Food Name
                      _buildLabeledTextField(
                        label: 'Food Name',
                        controller: nameController,
                        icon: Icons.fastfood,
                        hintText: 'e.g., Grilled Chicken',
                        validatorMsg: 'Please enter the food name',
                      ),

                      const SizedBox(height: 20),

                      // Serving Size
                      _buildLabeledTextField(
                        label: 'Serving Size',
                        controller: servingSizeController,
                        icon: Icons.straighten,
                        hintText: 'e.g., 1 cup, 150g',
                        validatorMsg: 'Please enter serving size',
                      ),

                      const SizedBox(height: 24),

                      // Macronutrients Header
                      Row(
                        children: const [
                          Icon(Icons.health_and_safety, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Macronutrients',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Calories
                      _buildNumberStepper(
                        label: 'Calories',
                        value: calories,
                        min: 0,
                        max: 2000,
                        onChanged: (val) => setState(() => calories = val),
                        icon: Icons.local_fire_department,
                        iconColor: Colors.redAccent,
                        tooltip: 'Total energy in kilocalories',
                      ),

                      const SizedBox(height: 16),

                      // Protein
                      _buildNumberStepper(
                        label: 'Protein (g)',
                        value: protein,
                        min: 0,
                        max: 500,
                        onChanged: (val) => setState(() => protein = val),
                        icon: Icons.fitness_center,
                        iconColor: Colors.deepOrange,
                        tooltip: 'Amount of protein in grams',
                      ),

                      const SizedBox(height: 16),

                      // Carbs
                      _buildNumberStepper(
                        label: 'Carbs (g)',
                        value: carbs,
                        min: 0,
                        max: 500,
                        onChanged: (val) => setState(() => carbs = val),
                        icon: Icons.bubble_chart,
                        iconColor: Colors.blueAccent,
                        tooltip: 'Amount of carbohydrates in grams',
                      ),

                      const SizedBox(height: 16),

                      // Fat
                      _buildNumberStepper(
                        label: 'Fat (g)',
                        value: fat,
                        min: 0,
                        max: 300,
                        onChanged: (val) => setState(() => fat = val),
                        icon: Icons.opacity,
                        iconColor: Colors.orangeAccent,
                        tooltip: 'Amount of fat in grams',
                      ),

                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  Navigator.pop(context);

                                  // Create meal object and add to provider
                                  final meal = Meal(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    mealType: 'Snack', // Default, could be made selectable
                                    foodName: nameController.text,
                                    calories: calories,
                                    time: DateTime.now().toString().split(' ')[1].substring(0, 5), // HH:MM format
                                    imageUrl: 'assets/images/placeholder.jpg',
                                    macros: MacroData(
                                      protein: protein.toDouble(),
                                      carbs: carbs.toDouble(),
                                      fat: fat.toDouble(),
                                    ),
                                  );

                                  // Add meal through provider
                                  Provider.of<NutritionProvider>(context, listen: false).addMeal(meal);

                                  // Show success message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${meal.foodName} added to your meals!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 3),
                                child: Text(
                                  'Add Food',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabeledTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    required String validatorMsg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: Colors.teal),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.teal),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.teal, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorMsg;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildNumberStepper({
    required String label,
    required int value,
    required int min,
    required int max,
    required void Function(int) onChanged,
    required IconData icon,
    required Color iconColor,
    String? tooltip,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Tooltip(
          message: tooltip ?? '',
          waitDuration: const Duration(milliseconds: 400),
          child: Icon(icon, color: iconColor, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: value > min ? () => onChanged(value - 1) : null,
          icon: const Icon(Icons.remove_circle_outline, size: 28),
          color: value > min ? iconColor : Colors.grey[400],
          splashRadius: 28,
          tooltip: 'Decrease $label',
        ),
        SizedBox(
          width: 44,
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: value < max ? () => onChanged(value + 1) : null,
          icon: const Icon(Icons.add_circle_outline, size: 28),
          color: value < max ? iconColor : Colors.grey[400],
          splashRadius: 28,
          tooltip: 'Increase $label',
        ),
      ],
    );
  }
}