import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'package:acumen/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Welcome to\nAcumen Conectify',
      'image': 'assets/images/onboard-1.png',
      'showText': true,
      'description': 'Discover a smarter way to grow your skills and shape your career. Our app connects you with the right tools to succeed – from learning to landing opportunities.',
      'buttonText': 'Next',
    },
    {
      'title': 'Track your\nprogress',
      'image': 'assets/images/onboard-2.png',
      'showText': false,
      'description': 'Whether it\'s quizzes, lessons, or achievements – monitor your growth in real time and stay motivated every step of the way.',
      'buttonText': 'Next',
    },
    {
      'title': 'Achieve your\nGoals',
      'image': 'assets/images/onboard-3.png',
      'showText': false,
      'description': 'Get expert advice and resources tailored to your goals. From resume building to job suggestions, we\'ve got you covered.',
      'buttonText': 'Get Started',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set status bar to dark (black) icons on light background
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: Colors.transparent,
    ));
  }

  @override
  void dispose() {
    // Reset to default status bar style when leaving
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    _pageController.dispose();
    super.dispose();
  }

  // Mark onboarding as completed
  Future<void> _completeOnboarding() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboardingComplete', true);
      
      if (!mounted) return;
      
      // Navigate to login screen
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      // If there's an error with shared preferences, just navigate to login
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _onboardingData.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(
                      title: _onboardingData[index]['title'],
                      image: _onboardingData[index]['image'],
                      description: _onboardingData[index]['description'],
                      showText: _onboardingData[index]['showText'],
                    );
                  },
                ),
              ),
              SizedBox(
                width: 180, // Smaller button width
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _onboardingData.length - 1) {
                      _completeOnboarding();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12), // Smaller vertical padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _onboardingData[_currentPage]['buttonText'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Space from bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage({
    required String title,
    required String image,
    required String description,
    required bool showText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, // Center the column content
      children: [
        SizedBox(
          width: double.infinity, // Full width container
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center, // Center the title text
          ),
        ),
        const SizedBox(height: 30),
        Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              image,
              height: 350,
              fit: BoxFit.contain,
            ),
            if (showText)
              const Positioned(
                child: Text(
                  'Acumen\nConectify',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity, // Full width container
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left, // Keep description left-aligned
          ),
        ),
      ],
    );
  }
} 
