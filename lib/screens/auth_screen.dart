import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'main_app.dart';
import 'forgot_password_screen.dart';
import 'onboarding_screen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    if (_tabController.index == 1 && !_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (_tabController.index == 1) {
        await userProvider.register(
          _nameController.text,
          _emailController.text,
          _passwordController.text,
        );

        // Check if user is actually logged in after registration
        if (userProvider.isLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => OnboardingScreen()),
          );
        } else {
          throw Exception('Registration failed. Please try again.');
        }
      } else {
        await userProvider.login(
          _emailController.text,
          _passwordController.text,
        );

        // Check if user is actually logged in after login
        if (userProvider.isLoggedIn) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainApp()),
          );
        } else {
          throw Exception('Login failed. Please check your credentials.');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1C2526),
              Color(0xFF2D3A3A),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Header image with overlay and text
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/images/fitness-man.png',
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(
                              Icons.fitness_center,
                              size: 80,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                        ),
                      ),
                      Positioned(
                        left: 16,
                        bottom: 24,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FitMax Pro',
                              style: TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 4,
                                    color: Colors.black45,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Unleash Your Strength',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[300],
                                fontStyle: FontStyle.italic,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 1),
                                    blurRadius: 3,
                                    color: Colors.black38,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // TabBar with minimal border radius on container
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[400],
                    labelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(child: Text('Sign In', textAlign: TextAlign.center)),
                      Tab(child: Text('Sign Up', textAlign: TextAlign.center)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form card with dynamic height based on tab index
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.grey[850],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          height: _tabController.index == 0
                              ? screenHeight * 0.2
                              : screenHeight * 0.35,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildSignInForm(),
                              _buildSignUpForm(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: userProvider.isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 5,
                        ),
                        child: userProvider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                          _tabController.index == 0 ? 'Sign In' : 'Create Account',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                Text(
                  'Or continue with',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => MainApp()),
                          );
                        },
                        icon: const Icon(Icons.g_mobiledata, color: Colors.red),
                        label: const Text(
                          'Google',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => MainApp()),
                          );
                        },
                        icon: const Icon(Icons.apple, color: Colors.white),
                        label: const Text(
                          'Apple',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 5),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.redAccent),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.redAccent),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 10), // Reduced space here
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 5),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.person_outlined, color: Colors.redAccent),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email',
              labelStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.redAccent),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.redAccent),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              labelStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.lock_outlined, color: Colors.redAccent),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _agreeToTerms,
                checkColor: Colors.white,
                activeColor: Colors.redAccent,
                onChanged: (value) {
                  setState(() {
                    _agreeToTerms = value ?? false;
                  });
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _agreeToTerms = !_agreeToTerms;
                    });
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[400]),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms and Conditions',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}