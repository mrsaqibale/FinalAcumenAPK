import 'dart:async';
import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/foundation.dart';


class SplashScreen extends StatefulWidget {
  final bool onboardingComplete;
  
  const SplashScreen({
    super.key, 
    required this.onboardingComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = AuthController();
  
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for 2 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Check if a user is already logged in
    final currentUser = _authController.currentUser;
    
    if (kDebugMode) {
      print("Current user on splash: ${currentUser?.email}");
    }
    
    if (currentUser != null && currentUser.emailVerified) {
      // User is logged in, go to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
            username: currentUser.displayName ?? "User",
          ),
        ),
      );
    } else {
      // Navigate to onboarding or login based on status
      if (widget.onboardingComplete) {
        Navigator.pushReplacementNamed(context, '/');
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash.png',
              width: 300,
              height: 300,
            ),
            const Text(
              'Empowering Your Career Journey',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
