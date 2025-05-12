import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginFunctions {
  final AuthController _authController = AuthController();

  Future<User?> login({
    required String identifier,
    required String password,
    required BuildContext context,
    required Function(bool) setLoading,
    required bool isAdminLogin,
  }) async {
    if (isAdminLogin) {
      // Admin login with email
      return _adminLogin(
        email: identifier,
        password: password,
        context: context,
        setLoading: setLoading,
      );
    } else {
      // Student login with roll number
      return _studentLogin(
        rollNumber: identifier,
        password: password,
        context: context,
        setLoading: setLoading,
      );
    }
  }

  Future<User?> _adminLogin({
    required String email,
    required String password,
    required BuildContext context,
    required Function(bool) setLoading,
  }) async {
    // Validate email
    final emailError = LoginValidation.validateEmail(email);
    if (emailError != null) {
      showErrorMessage(context, emailError);
      return null;
    }

    // Validate password
    final passwordError = LoginValidation.validatePassword(password);
    if (passwordError != null) {
      showErrorMessage(context, passwordError);
      return null;
    }

    setLoading(true);

    try {
      final userCredential = await _authController.signInWithEmail(
        email: email.trim(),
        password: password,
        context: context,
      );

      if (userCredential != null && context.mounted) {
        final user = userCredential.user;
        if (user != null) {
          // Check if user is admin
          final isAdmin = await _authController.isUserAdmin(user.uid);
          
          if (isAdmin) {
            // Navigate to admin dashboard
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            }
          } else {
            // Not an admin
            showErrorMessage(context, 'This account does not have admin privileges');
            await _authController.signOut();
          }
        }
      }
      return userCredential?.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Admin login error: ${e.code} - ${e.message}');
      }
      showErrorMessage(context, LoginValidation.handleAuthError(e));
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Admin login error: $e');
      }
      showErrorMessage(context, 'Login failed: ${e.toString()}');
      return null;
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  Future<User?> _studentLogin({
    required String rollNumber,
    required String password,
    required BuildContext context,
    required Function(bool) setLoading,
  }) async {
    // Validate roll number
    final rollNumberError = LoginValidation.validateRollNumber(rollNumber);
    if (rollNumberError != null) {
      showErrorMessage(context, rollNumberError);
      return null;
    }

    // Validate password
    final passwordError = LoginValidation.validatePassword(password);
    if (passwordError != null) {
      showErrorMessage(context, passwordError);
      return null;
    }

    setLoading(true);

    try {
      final userCredential = await _authController.signIn(
        rollNumber: rollNumber.trim(),
        password: password,
        context: context,
      );

      if (userCredential != null && context.mounted) {
        if (userCredential.user!.emailVerified) {
          // Navigate to dashboard if email is verified
          Navigator.pushReplacementNamed(context, '/dashboard');
        }
        // If email is not verified, the AuthController will handle the navigation
      }
      return userCredential?.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Student login error: ${e.code} - ${e.message}');
      }
      showErrorMessage(context, LoginValidation.handleAuthError(e));
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Student login error: $e');
      }
      showErrorMessage(context, 'Login failed: ${e.toString()}');
      return null;
    } finally {
      if (context.mounted) {
        setLoading(false);
      }
    }
  }

  static void showErrorMessage(BuildContext context, String message) {
    AppSnackbar.showError(
      context: context,
      message: message,
    );
  }
} 