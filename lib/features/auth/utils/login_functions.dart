import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/features/dashboard/screens/admin_dashboard_screen.dart';
import 'package:acumen/features/dashboard/screens/mentor_dashboard_screen.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginFunctions {
  final AuthController _authController = AuthController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> login({
    required String identifier,
    required String password,
    required BuildContext context,
    required Function(bool) setLoading,
  }) async {
    if (identifier.isEmpty) {
      showErrorMessage(context, 'Please enter your roll number, email, or ID');
      return null;
    }

    final passwordError = LoginValidation.validatePassword(password);
    if (passwordError != null) {
      showErrorMessage(context, passwordError);
      return null;
    }

    setLoading(true);

    try {
      UserCredential? userCredential;
      
      if (identifier.contains('@')) {
        // Email login (any user type)
        if (kDebugMode) {
          print('Attempting login with email: $identifier');
        }
        
        userCredential = await _authController.signInWithEmail(
          email: identifier.trim(),
          password: password,
          context: context,
        );
      } else {
        // First try as a student roll number
        try {
          if (kDebugMode) {
            print('Attempting login with roll number: $identifier');
          }
          
          // Check if the identifier is a student roll number
          final studentDoc = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('isActive', isEqualTo: true)
            .where(
              // Try both as string and integer
              Filter.or(
                Filter('rollNo', isEqualTo: identifier.trim()),
                Filter('rollNo', isEqualTo: int.tryParse(identifier.trim())),
              )
            )
            .limit(1)
            .get();

          if (studentDoc.docs.isNotEmpty) {
            // It's a student roll number
            if (kDebugMode) {
              print('Found student with roll number: $identifier');
            }
            
            final studentData = studentDoc.docs.first.data();
            final email = studentData['email'] as String;
            
            // Sign in with the student's email
            userCredential = await _authController.signInWithEmail(
              email: email,
              password: password,
              context: context,
            );
          } else {
            // If not a student roll number, try as a mentor employee ID
            if (kDebugMode) {
              print('No student found, trying as mentor ID: $identifier');
            }
            
            final mentorDoc = await _firestore
              .collection('users')
              .where('role', isEqualTo: 'mentor')
              .where('isActive', isEqualTo: true)
              .where('employeeId', isEqualTo: identifier.trim())
              .limit(1)
              .get();
              
            if (mentorDoc.docs.isNotEmpty) {
              // It's a mentor ID
              if (kDebugMode) {
                print('Found mentor with ID: $identifier');
              }
              
              final mentorData = mentorDoc.docs.first.data();
              final email = mentorData['email'] as String;
              
              // Sign in with the mentor's email
              userCredential = await _authController.signInWithEmail(
                email: email,
          password: password,
          context: context,
        );
            } else {
              throw FirebaseAuthException(
                code: 'user-not-found',
                message: 'No user found with this ID or roll number',
              );
            }
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error finding user by ID: $e');
          }
          
          if (e is FirebaseAuthException) {
            rethrow;
          }
          
          throw FirebaseAuthException(
            code: 'invalid-credential',
            message: 'Invalid ID, roll number, or password',
          );
        }
      }

      if (userCredential != null && context.mounted) {
        if (_authController.appUser != null && context.mounted) {
          final appUser = _authController.appUser!;
          if (appUser.role == 'admin') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else if (appUser.role == 'mentor') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MentorDashboardScreen(),
              ),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        } else {
          showErrorMessage(context, 'Could not retrieve user information. Please try again.');
          await _authController.signOut();
        }
      }
      return userCredential?.user;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Login error: ${e.code} - ${e.message}');
      }
      showErrorMessage(context, LoginValidation.handleAuthError(e));
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
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