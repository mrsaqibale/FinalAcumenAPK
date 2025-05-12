import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/dashboard/screens/dashboard_screen.dart';
import 'package:acumen/features/auth/screens/email_confirmation_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:acumen/utils/app_snackbar.dart';

class LoginService {
  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login function
  Future<bool> login({
    required BuildContext context,
    required String rollNo,
    required String password,
  }) async {
    // Validate inputs
    if (rollNo.trim().isEmpty || password.isEmpty) {
      _showErrorMessage(context, "Please fill in all required fields");
      return false;
    }

    try {
      if (kDebugMode) {
        print("Starting login process...");
        print("Roll number: $rollNo");
      }
      
      // Attempt login directly with roll number as username
      final user = await _authController.signIn(
        username: rollNo.trim(),
        password: password,
        context: context,
      );
      
      if (user != null && context.mounted) {
        // Check if email is verified
        if (!user.emailVerified) {
          if (kDebugMode) {
            print("Email not verified, redirecting to verification screen");
          }
          // Redirect to verification screen
          _navigateToEmailVerification(context, user.email ?? "");
          return true;
        }
        
        if (kDebugMode) {
          print("Login successful, navigating to dashboard");
        }
        
        // Navigate to dashboard
        _navigateToDashboard(context, user.displayName ?? rollNo);
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error in login: $e");
      }
      _showErrorMessage(context, "Error: ${e.toString()}");
      return false;
    }
  }
  
  // Navigate to email verification screen
  void _navigateToEmailVerification(BuildContext context, String email) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EmailConfirmationScreen(email: email),
      ),
    );
  }
  
  // Navigate to dashboard
  void _navigateToDashboard(BuildContext context, String username) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(username: username),
      ),
    );
  }
  
  // Show error message
  void _showErrorMessage(BuildContext context, String message) {
    if (!context.mounted) return;
    
    AppSnackbar.showError(
      context: context,
      message: message,
    );
  }
} 