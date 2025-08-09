import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'home_screen.dart';
import 'workouts_screen.dart';
import 'nutrition_screen.dart';
import 'social_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';
import 'notifications_screen.dart';
import '../providers/navigation_provider.dart'; // Added

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  static final GlobalKey<_MainAppState> globalKey = GlobalKey();

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _fabController;
  late NavigationProvider _navigationProvider; // Added

  final List<Widget> _screens = [
    HomeScreen(),
    WorkoutsScreen(),
    NutritionScreen(key: NutritionScreen.globalKey),
    SocialScreen(),
    ProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navigationProvider = Provider.of<NavigationProvider>(context, listen: false); // Added
    _pageController.addListener(() { // Added
      _navigationProvider.setIndex(_pageController.page!.round()); // Added
    }); // Added
    _navigationProvider.addListener(_handleNavigationChange); // Added
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabController.dispose();
    _navigationProvider.removeListener(_handleNavigationChange); // Added
    super.dispose();
  }

  void _onTabTapped(int index) {
    _navigationProvider.setIndex(index);
  }

  

  void _handleNavigationChange() {
    if (_navigationProvider.currentIndex != _pageController.page?.round()) {
      _pageController.jumpToPage(_navigationProvider.currentIndex);
    }
    if (_navigationProvider.shouldShowManualEntry) {
      NutritionScreen.globalKey.currentState?.showManualEntryModal();
      _navigationProvider.resetManualEntry();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: userProvider.user?.avatar != null
                      ? NetworkImage(userProvider.user!.avatar!)
                      : null,
                  child: userProvider.user?.avatar == null
                      ? Text(userProvider.user?.name[0] ?? 'U')
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${userProvider.user?.name ?? 'User'}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Level ${userProvider.user?.level ?? 1} • ${userProvider.user?.streak ?? 0} day streak 🔥',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.psychology),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AIChatScreen()),
                  );
                },
              ),
              IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: const Text(
                          '3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NotificationsScreen()),
                  );
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'profile':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                      break;
                    case 'settings':
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SettingsScreen()),
                      );
                      break;
                    case 'logout':
                      _showLogoutDialog();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text('Logout', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              _navigationProvider.setIndex(index);
            },
            children: _screens,
          ),
          bottomNavigationBar: Consumer<NavigationProvider>(
            builder: (context, navigationProvider, child) {
              return Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: BottomNavigationBar(
                  currentIndex: navigationProvider.currentIndex,
                  onTap: _onTabTapped,
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: Theme.of(context).primaryColor,
                  unselectedItemColor: Colors.grey,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.fitness_center),
                      label: 'Workouts',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.restaurant),
                      label: 'Nutrition',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.people),
                      label: 'Social',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart),
                      label: 'Progress',
                    ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: AnimatedBuilder(
            animation: _fabController,
            builder: (context, child) {
              return FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AIChatScreen()),
                  );
                },
                child: const Icon(Icons.psychology),
                backgroundColor: Theme.of(context).primaryColor,
              );
            },
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              userProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/splash', (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
