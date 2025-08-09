import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../providers/nutrition_provider.dart';
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
                const Text(
                  'Intermittent Fasting',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      Text(
                        provider.fastingTimer.timeRemaining,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        'Time remaining in fast',
                        style: TextStyle(
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => provider.endFast(),
                              child: const Text('End Fast'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => provider.setFastingReminder(),
                              icon: const Icon(Icons.notifications),
                              label: const Text('Set Reminder'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
        Card(
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
                              '6/7',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo[600],
                              ),
                            ),
                            const Text(
                              'Days on track',
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
                              '15,400',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                            const Text(
                              'Total calories',
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
      print('Image picked: ${image.path}');
      // Process the image here (e.g., send to a food recognition API)
    } else {
      print('No image picked.');
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
              print('AI Meal Plan button pressed!');
              // Add meal planning logic
            },
            child: const Text('Generate Plan'),
          ),
        ],
      ),
    );
  }

  void _showBarcodeScanner() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()));
    if (result != null) {
      print('Scanned barcode: $result');
      // Process the scanned barcode
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
                                  // Return data or call provider here
                                  print('Food Name: ${nameController.text}');
                                  print('Serving Size: ${servingSizeController.text}');
                                  print('Calories: $calories');
                                  print('Protein: $protein');
                                  print('Carbs: $carbs');
                                  print('Fat: $fat');
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