import 'package:acumen/models/user_model.dart';
import 'package:acumen/features/auth/services/auth_service.dart';
import 'package:acumen/features/auth/validations/auth_validation.dart';
import 'package:acumen/features/auth/utils/login_validation.dart';
import 'package:acumen/routes/app_routes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:acumen/utils/app_snackbar.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  UserModel? _appUser;
  bool _isLoading = false;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get current user
  User? get currentUser => _currentUser;
  
  // Get current app user (with additional info)
  UserModel? get appUser => _appUser;
  
  // Get auth state stream
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  AuthController() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData();
      } else {
        _appUser = null;
      }
      notifyListeners();
    });

    // Initialize current user
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _loadUserData();
    }
  }
  
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  
  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _authService.getUserData(_currentUser!.uid);
      if (userData != null) {
        _appUser = userData;
        if (kDebugMode) {
          print("User data loaded: ${_appUser?.email}");
          print("User role: ${_appUser?.role}");
          print("User status: ${_appUser?.status}");
          print("Is approved: ${_appUser?.isApproved}");
        }
      } else {
        if (kDebugMode) {
          print("No user data found for: ${_currentUser?.email}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading user data: $e");
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in user with roll number
  Future<UserCredential?> signIn({
    required String rollNumber,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print("AuthController: Starting signin with roll number");
      }

      // Validate inputs
      if (rollNumber.trim().isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: "Roll number is required"
        );
      }

      final String? passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: passwordError
        );
      }

      if (kDebugMode) {
        print("AuthController: All validations passed, attempting signin");
      }

      // Find student's email using roll number
      final studentDoc = await _firestore
            .collection('users')
          .where('rollNo', isEqualTo: int.parse(rollNumber))
            .where('role', isEqualTo: 'student')
            .limit(1)
            .get();

      if (studentDoc.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No student found with this roll number'
        );
      }

      final studentData = studentDoc.docs.first.data();
      final email = studentData['email'] as String;

      // Sign in with email and password
      final userCredential = await _authService.signIn(email, password);
      
      if (kDebugMode) {
        print("AuthController: Signin completed successfully");
        print("Email verified: ${userCredential?.user?.emailVerified}");
      }
      
      // Load user data
      if (userCredential != null) {
        await _loadUserData();
      }
      
      // Check if email is verified
      if (userCredential != null && !userCredential.user!.emailVerified) {
        if (kDebugMode) {
          print("Email not verified, redirecting to verification screen");
        }
        
        if (context.mounted) {
          // Navigate to email verification screen using AppRoutes
          AppRoutes.navigateToEmailVerification(context, email);
          
          // Send verification email
          await _authService.sendEmailVerification();
        }
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e, context);
      return null;
    } catch (e) {
      _showErrorMessage(context, 'Error: ${e.toString()}');
      if (kDebugMode) {
        print("Error during signin: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Teacher sign in (delegates to mentorSignIn for backward compatibility)
  Future<UserCredential?> teacherSignIn({
    required String email,
    required String password,
    required String employeeId,
    required BuildContext context,
  }) async {
    // Delegate to mentorSignIn for backward compatibility
    return mentorSignIn(
      email: email,
      password: password,
      employeeId: employeeId,
      context: context,
    );
  }

  // Mentor sign in
  Future<UserCredential?> mentorSignIn({
    required String email,
    required String password,
    required String employeeId,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print("AuthController: Starting mentor signin validation");
      }

      // Validate inputs
      final String? emailError = AuthValidation.validateEmail(email);
      if (emailError != null) {
        _showErrorMessage(context, emailError);
        return null;
      }

      final String? passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        _showErrorMessage(context, passwordError);
        return null;
      }

      if (employeeId.trim().isEmpty) {
        _showErrorMessage(context, 'Employee ID is required');
        return null;
      }

      if (kDebugMode) {
        print("AuthController: All validations passed, attempting mentor signin");
      }

      // Sign in mentor
      final userCredential = await _authService.signInMentor(email, password, employeeId);
      
      // Check if user is actually a mentor
      final userData = await _authService.getUserData(userCredential!.user!.uid);
      if (userData == null || userData.role != 'mentor') {
        _showErrorMessage(context, 'This account is not registered as a mentor');
        await _authService.signOut();
        return null;
      }
      
      // Check if mentor is approved
      if (!userData.isApproved) {
        _showErrorMessage(context, 'Your mentor account is pending approval by an administrator');
        await _authService.signOut();
        return null;
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e, context);
      return null;
    } catch (e) {
      _showErrorMessage(context, 'Error: ${e.toString()}');
      if (kDebugMode) {
        print("Error during mentor signin: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign up student
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String rollNoString,
    required bool isFirstSemester,
    required PlatformFile document,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print("AuthController: Starting student signup");
      }

      // Validate inputs
      final String? emailError = AuthValidation.validateEmail(email);
      if (emailError != null) {
        _showErrorMessage(context, emailError);
        return false;
      }

      final String? passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        _showErrorMessage(context, passwordError);
        return false;
      }

      if (name.trim().isEmpty) {
        _showErrorMessage(context, 'Name is required');
        return false;
      }

      // Validate roll number format
      final String? rollNoError = LoginValidation.validateRollNumber(rollNoString);
      if (rollNoError != null) {
        _showErrorMessage(context, rollNoError);
        return false;
      }

      // Check if roll number is unique
      final isUnique = await isRollNumberUnique(rollNoString);
      if (!isUnique) {
        _showErrorMessage(context, 'This roll number is already registered');
        return false;
      }

      // Parse roll number to integer
      final rollNo = int.parse(rollNoString);

      if (kDebugMode) {
        print("AuthController: All validations passed, attempting signup");
      }

      String documentUrl;
      try {
        // Upload document to Firebase Storage
        documentUrl = await _uploadDocument(document);
      } catch (e) {
        _showErrorMessage(context, 'Failed to upload document: ${e.toString()}');
        return false;
      }

      // Create user in Firebase Auth and Firestore
      await _authService.signUp(
        email.trim(),
        password,
        name.trim(),
        rollNo,
        isFirstSemester,
        documentUrl,
      );
      
      if (kDebugMode) {
        print("AuthController: Signup completed successfully");
      }
      
      // Send verification email
      await _authService.sendEmailVerification();
      
      return true;
    } catch (e) {
      _showErrorMessage(context, 'Error: ${e.toString()}');
      if (kDebugMode) {
        print("Error during signup: $e");
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Signup mentor
  Future<bool> signUpMentor({
    required String email,
    required String password,
    required String name,
    required String employeeId,
    required String department,
    required PlatformFile? document,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print("AuthController: Starting mentor signup validation");
      }

      // Validate inputs
      final String? emailError = AuthValidation.validateEmail(email);
      if (emailError != null) {
        _showErrorMessage(context, emailError);
        return false;
      }

      final String? passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        _showErrorMessage(context, passwordError);
        return false;
      }

      final String? nameError = AuthValidation.validateName(name);
      if (nameError != null) {
        _showErrorMessage(context, nameError);
        return false;
      }

      final String? documentError = AuthValidation.validateDocument(document);
      if (documentError != null) {
        _showErrorMessage(context, documentError);
        return false;
      }

      if (document == null) {
        _showErrorMessage(context, 'Document is required');
        return false;
      }

      if (kDebugMode) {
        print("AuthController: All validations passed");
      }

      // Upload document and get URL
      final String documentUrl = await _uploadDocument(document);

      // Sign up mentor
      await _authService.signUpMentor(email, password, name, employeeId, department, documentUrl);
      
      if (kDebugMode) {
        print("AuthController: Mentor signup completed successfully");
      }
      
      return true;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e, context);
      return false;
    } catch (e) {
      _showErrorMessage(context, 'Error: ${e.toString()}');
      if (kDebugMode) {
        print("Error during mentor signup: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get all students (for adding to communities)
  Future<List<Map<String, dynamic>>> getAllStudents() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'rollNumber': data['rollNo']?.toString() ?? '',
          'email': data['email'] ?? '',
          'role': data['role'] ?? 'student',
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting students: $e');
      }
      return [];
    }
  }
  
  // Get only students (excluding mentors and admins)
  Future<List<Map<String, dynamic>>> getStudents() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();
          
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'rollNumber': data['rollNo']?.toString() ?? '',
          'email': data['email'] ?? '',
          'role': 'student',
          'isActive': data['isActive'] ?? true,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting students: $e');
      }
      return [];
    }
  }
  
  // Sign out user
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
      _appUser = null;
    } catch (e) {
      if (kDebugMode) {
        print("Error signing out: $e");
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Show error message
  void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      AppSnackbar.showError(
        context: context, 
        message: message,
      );
    }
  }

  // Handle Firebase auth exceptions
  void _handleFirebaseAuthException(FirebaseAuthException e, BuildContext context) {
    if (kDebugMode) {
      print("Firebase Auth Exception: ${e.code} - ${e.message}");
    }
    
    final errorMessage = LoginValidation.handleAuthError(e);
    _showErrorMessage(context, errorMessage);
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    return await _authService.isEmailVerified();
  }

  // Resend email verification
  Future<void> resendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      if (kDebugMode) {
        print("Verification email resent successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error resending verification email: $e");
      }
      throw Exception('Failed to resend verification email: $e');
    }
  }

  // Upload document to Firebase Storage
  Future<String> _uploadDocument(PlatformFile file) async {
    try {
      if (kDebugMode) {
        print("Starting document upload for: ${file.name}");
      }

      final Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else {
        throw Exception('File data is missing. Please try uploading again.');
      }

      final ref = _storage.ref()
          .child('documents')
          .child('student')
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');
      
      final metadata = SettableMetadata(
        contentType: _getContentType(file.name),
      );
      
      final uploadTask = await ref.putData(fileBytes, metadata);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading document: $e");
      }
      rethrow;
    }
  }
  
  // Get content type based on file extension
  String _getContentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      default:
        return 'application/octet-stream';
    }
  }

  // Get users by IDs
  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> userIds) async {
    try {
      List<Map<String, dynamic>> users = [];
      
      // Process in batches to avoid potential limitations
      const int batchSize = 10;
      for (int i = 0; i < userIds.length; i += batchSize) {
        final end = (i + batchSize < userIds.length) ? i + batchSize : userIds.length;
        final batch = userIds.sublist(i, end);
        
        // Get each user individually (alternative to whereIn which may not work with document ID)
        for (final userId in batch) {
          final doc = await _firestore.collection('users').doc(userId).get();
          if (doc.exists) {
            final data = doc.data()!;
            users.add({
              'id': doc.id,
              'name': data['name'] ?? 'Unknown',
              'email': data['email'] ?? '',
              'role': data['role'] ?? 'student',
              'photoUrl': data['photoUrl'],
            });
          }
        }
      }
      
      return users;
    } catch (e) {
    if (kDebugMode) {
        print('Error getting users by IDs: $e');
      }
      return [];
    }
  }

  // Sign in with email (for admin login)
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (kDebugMode) {
        print("AuthController: Starting signin with email");
      }

      // Validate inputs
      final String? emailError = AuthValidation.validateEmail(email);
      if (emailError != null) {
        throw FirebaseAuthException(
          code: 'invalid-email',
          message: emailError
        );
    }
    
      final String? passwordError = AuthValidation.validatePassword(password);
      if (passwordError != null) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: passwordError
        );
      }

      if (kDebugMode) {
        print("AuthController: All validations passed, attempting signin with email");
      }

      // Sign in with email and password
      final userCredential = await _authService.signIn(email, password);
      
      if (kDebugMode) {
        print("AuthController: Signin with email completed successfully");
      }
      
      // Load user data
      if (userCredential != null) {
        await _loadUserData();
      }
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      _handleFirebaseAuthException(e, context);
      return null;
    } catch (e) {
      _showErrorMessage(context, 'Error: ${e.toString()}');
      if (kDebugMode) {
        print("Error during signin with email: $e");
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if a user is an admin
  Future<bool> isUserAdmin(String userId) async {
    try {
      final userData = await _firestore.collection('users').doc(userId).get();
      if (!userData.exists) {
        return false;
      }
      
      final role = userData.data()?['role'] as String?;
      return role == 'admin';
    } catch (e) {
      if (kDebugMode) {
        print("Error checking if user is admin: $e");
      }
      return false;
    }
  }

  // Reload current user
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
      // After reloading, update the current user and load user data
      _currentUser = _authService.currentUser;
      if (_currentUser != null) {
        await _loadUserData();
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("Error reloading user in AuthController: $e");
      }
      rethrow;
    }
  }

  // Check if roll number is unique
  Future<bool> isRollNumberUnique(String rollNo) async {
    try {
      final rollNoInt = int.tryParse(rollNo);
      if (rollNoInt == null) {
        return false;
      }
      
      final querySnapshot = await _firestore
          .collection('users')
          .where('rollNo', isEqualTo: rollNoInt)
          .where('role', isEqualTo: 'student')
          .limit(1)
          .get();
      
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking roll number uniqueness: $e");
      }
      return false;
    }
  }
} 