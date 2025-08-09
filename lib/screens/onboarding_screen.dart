import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'main_app.dart';
import '../utils/theme.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // User data
  String _selectedGoal = '';
  String _fitnessLevel = '';
  int _age = 25;
  double _height = 170;
  double _weight = 70;
  String _gender = '';
  List<String> _selectedActivities = [];
  int _workoutDays = 3;
  int _workoutDuration = 30;

  final List<String> _goals = [
    'Lose Weight',
    'Build Muscle',
    'Stay Fit',
    'Improve Endurance',
  ];

  final List<String> _fitnessLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  final List<String> _activities = [
    'Strength Training',
    'Cardio',
    'Yoga',
    'Running',
    'Cycling',
    'Dancing',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 6) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await userProvider.completeOnboarding({
      'goal': _selectedGoal,
      'fitnessLevel': _fitnessLevel,
      'age': _age,
      'height': _height,
      'weight': _weight,
      'gender': _gender,
      'activities': _selectedActivities,
      'workoutDays': _workoutDays,
      'workoutDuration': _workoutDuration,
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => MainApp()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 0 ? _previousPage : null,
                    icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / 7,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_currentPage + 1}/7',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildGoalPage(),
                  _buildFitnessLevelPage(),
                  _buildPersonalInfoPage(),
                  _buildActivitiesPage(),
                  _buildSchedulePage(),
                  _buildSummaryPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Text(_currentPage == 6 ? 'Get Started' : 'Next'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
  }

  Widget _buildWelcomePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 80,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 40),
          Text(
            'Welcome to FitMax Pro!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Let\'s personalize your fitness journey with a few quick questions.',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your main fitness goal?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Choose the goal that best describes what you want to achieve.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: _goals.length,
            itemBuilder: (context, index) {
              final goal = _goals[index];
              final isSelected = _selectedGoal == goal;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGoal = goal;
                  });
                },
                child: Card(
                  elevation: isSelected ? 8 : 2,
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag,
                        size: 40,
                        color: isSelected ? Colors.white : AppTheme.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        goal,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFitnessLevelPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What\'s your fitness level?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This helps us recommend the right intensity for your workouts.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _fitnessLevels.length,
            itemBuilder: (context, index) {
              final level = _fitnessLevels[index];
              final isSelected = _fitnessLevel == level;
              return Card(
                elevation: isSelected ? 8 : 2,
                color: isSelected ? AppTheme.primaryColor : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  onTap: () {
                    setState(() {
                      _fitnessLevel = level;
                    });
                  },
                  leading: Icon(
                    Icons.trending_up,
                    size: 32,
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                  title: Text(
                    level,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.white)
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tell us about yourself',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'This information helps us create personalized recommendations.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Male';
                    });
                  },
                  child: Card(
                    elevation: _gender == 'Male' ? 8 : 2,
                    color: _gender == 'Male' ? AppTheme.primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.male,
                            color: _gender == 'Male' ? Colors.white : AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Male',
                            style: TextStyle(
                              color: _gender == 'Male' ? Colors.white : AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _gender = 'Female';
                    });
                  },
                  child: Card(
                    elevation: _gender == 'Female' ? 8 : 2,
                    color: _gender == 'Female' ? AppTheme.primaryColor : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.female,
                            color: _gender == 'Female' ? Colors.white : AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Female',
                            style: TextStyle(
                              color: _gender == 'Female' ? Colors.white : AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSliderCard('Age', _age.toDouble(), 18, 80, 'years', (value) {
            setState(() {
              _age = value.round();
            });
          }),
          const SizedBox(height: 16),
          _buildSliderCard('Height', _height, 140, 220, 'cm', (value) {
            setState(() {
              _height = value;
            });
          }),
          const SizedBox(height: 16),
          _buildSliderCard('Weight', _weight, 40, 150, 'kg', (value) {
            setState(() {
              _weight = value;
            });
          }),
        ],
      ),
    );
  }

  Widget _buildActivitiesPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What activities interest you?',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Select all that apply. We\'ll use this to recommend workouts.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: _activities.map((activity) {
              final isSelected = _selectedActivities.contains(activity);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedActivities.remove(activity);
                    } else {
                      _selectedActivities.add(activity);
                    }
                  });
                },
                child: Chip(
                  label: Text(activity),
                  backgroundColor: isSelected ? AppTheme.primaryColor : Colors.grey[200],
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.primaryColor,
                  ),
                  avatar: isSelected
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s plan your schedule',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How often and how long would you like to work out?',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildSliderCard('Workout Days per Week', _workoutDays.toDouble(), 1, 7, 'days', (value) {
            setState(() {
              _workoutDays = value.round();
            });
          }),
          const SizedBox(height: 24),
          _buildSliderCard('Workout Duration', _workoutDuration.toDouble(), 15, 120, 'minutes', (value) {
            setState(() {
              _workoutDuration = value.round();
            });
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You\'re all set!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Here\'s your personalized fitness profile:',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildSummaryCard('Goal', _selectedGoal, Icons.flag),
          const SizedBox(height: 16),
          _buildSummaryCard('Fitness Level', _fitnessLevel, Icons.trending_up),
          const SizedBox(height: 16),
          _buildSummaryCard('Personal Info', '$_age years, $_height cm, $_weight kg, $_gender', Icons.person),
          const SizedBox(height: 16),
          _buildSummaryCard('Preferred Activities', _selectedActivities.join(', '), Icons.sports),
          const SizedBox(height: 16),
          _buildSummaryCard('Schedule', '$_workoutDays days/week, $_workoutDuration min/session', Icons.schedule),
        ],
      ),
    );
  }

  Widget _buildSliderCard(String title, double value, double min, double max, String unit, Function(double) onChanged) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  '${value.round()} $unit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min).round(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor, size: 24),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}
