import 'dart:async';
import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';


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
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Wait for 2 seconds to show the splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Get AuthController from provider
    final authController = Provider.of<AuthController>(context, listen: false);
    
    // Check if a user is already logged in
    final currentUser = authController.currentUser;
    final appUser = authController.appUser;
    
    if (kDebugMode) {
      print("Current user on splash: ${currentUser?.email}");
      print("App user on splash: ${appUser?.email}");
    }
    
    if (currentUser != null && currentUser.emailVerified) {
      // User is logged in, go to dashboard
      if (appUser != null) {
        // Check user role and navigate accordingly
        if (appUser.role == 'mentor') {
          if (appUser.isApproved) {
            // Mentor is approved, go to mentor dashboard
            Navigator.pushReplacementNamed(context, '/mentor-dashboard');
          } else {
            // Mentor is not approved, go to approval screen
            Navigator.pushReplacementNamed(context, '/mentor-approval');
          }
        } else if (appUser.role == 'admin') {
          // Admin user, go to admin dashboard
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else {
          // Student or other role, go to general dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                username: appUser.name ?? "User",
              ),
            ),
          );
        }
      } else {
        // User data not loaded yet, wait a bit and try again
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          _navigateAfterDelay();
        }
      }
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
