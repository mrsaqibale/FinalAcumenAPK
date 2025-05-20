import 'dart:async';
import 'package:flutter/material.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:acumen/routes/app_routes.dart';
import 'package:acumen/services/navigation_service.dart';

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
    await NavigationService().handleInitialNavigation(context, widget.onboardingComplete);
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
