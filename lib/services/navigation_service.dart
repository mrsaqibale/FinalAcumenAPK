import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/models/user_model.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:acumen/routes/app_routes.dart';
import 'package:flutter/foundation.dart';

class NavigationService {
  // Singleton pattern
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Navigation methods
  Future<void> handleInitialNavigation(BuildContext context, bool onboardingComplete) async {
    if (!context.mounted) return;
    
    // Get AuthController from provider
    final authController = Provider.of<AuthController>(context, listen: false);
    
    try {
      // Wait for auth state to be initialized
      int attempts = 0;
      const maxAttempts = 5; // Increased from 2 to 5
      const retryDelay = Duration(milliseconds: 500);
      
      while (attempts < maxAttempts) {
        // Try to reload the user to ensure we have the latest state
        await authController.reloadUser();
        
        final currentUser = authController.currentUser;
        final appUser = authController.appUser;
        
        if (kDebugMode) {
          print("Attempt $attempts - Current user on splash: ${currentUser?.email}");
          print("Attempt $attempts - App user on splash: ${appUser?.email}");
          print("Attempt $attempts - Is email verified: ${currentUser?.emailVerified}");
        }
        
        if (currentUser != null) {
          // User is logged in
          if (currentUser.emailVerified) {
            if (appUser != null) {
              // User data is loaded, navigate based on role
              switch (appUser.role) {
                case 'mentor':
                  if (appUser.isApproved) {
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.mentorDashboard);
                    }
                    return;
                  } else {
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppRoutes.mentorApproval);
                    }
                    return;
                  }
                case 'admin':
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
                  }
                  return;
                default:
                  // Student or other role
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DashboardScreen(
                          username: appUser.name ?? "User",
                        ),
                      ),
                    );
                  }
                  return;
              }
            } else {
              // User is logged in but app user data is not loaded yet
              if (kDebugMode) {
                print("User is logged in but app user data is not loaded yet. Retrying...");
              }
            }
          } else {
            // User is not verified, go to email verification
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, AppRoutes.emailConfirmation);
            }
            return;
          }
        }
        
        attempts++;
        if (attempts < maxAttempts) {
          await Future.delayed(retryDelay);
        }
      }
      
      // If we get here after max attempts, navigate to onboarding or login
      if (context.mounted) {
        if (onboardingComplete) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error during initial navigation: $e");
      }
      
      // On error, navigate to login
      if (context.mounted) {
        if (onboardingComplete) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      }
    }
  }
} 