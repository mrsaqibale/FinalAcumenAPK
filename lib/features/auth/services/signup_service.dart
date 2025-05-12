import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/routes/app_routes.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SignupService {
  final AuthController authController = AuthController();

  // Pick a document file (PDF, PNG, JPG)
  Future<PlatformFile?> pickDocumentFile(BuildContext context) async {
    try {
      if (kDebugMode) {
        print("Starting file picker...");
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
        withData: true, // Ensure we get the file bytes
      );

      if (result != null) {
        final file = result.files.first;
        
        if (kDebugMode) {
          print("File selected: ${file.name}");
          print("File size: ${file.size} bytes");
          print("Has bytes: ${file.bytes != null}");
          print("Has path: ${file.path != null}");
        }
        
        if (file.bytes == null && file.path == null) {
          _showErrorMessage(context, "Error: File data couldn't be loaded.");
          return null;
        }

        return file;
      } else {
        if (kDebugMode) {
          print("No file selected");
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print("Error picking file: $e");
      }
      _showErrorMessage(context, "Error selecting file: ${e.toString()}");
      return null;
    }
  }

  // Signup function
  Future<bool> signup({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String rollNo,
    required bool isFirstSemester,
    required PlatformFile? document,
  }) async {
    // Validate all fields first
    if (email.trim().isEmpty || 
        password.isEmpty ||
        name.trim().isEmpty ||
        rollNo.trim().isEmpty) {
      _showErrorMessage(context, "Please fill in all required fields");
      return false;
    }

    if (document == null) {
      _showErrorMessage(context, "Please upload your document");
      return false;
    }

    try {
      if (kDebugMode) {
        print("Starting signup process...");
        print("Using file: ${document.name}");
      }
      
      final success = await authController.signUp(
        email: email.trim(),
        password: password,
        name: name.trim(),
        rollNoString: rollNo.trim(),
        isFirstSemester: isFirstSemester,
        document: document,
        context: context,
      );

      if (success && context.mounted) {
        if (kDebugMode) {
          print("Signup successful, navigating to email confirmation");
        }
        
        // Navigate to email confirmation screen
        AppRoutes.navigateToEmailConfirmation(
          context,
          email.trim(),
        );
        return true;
      } else if (context.mounted) {
        if (kDebugMode) {
          print("Signup returned false");
        }
        return false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error in signup: $e");
      }
      _showErrorMessage(context, "Error: ${e.toString()}");
      return false;
    }
  }

  // Signup mentor function
  Future<bool> signupMentor({
    required BuildContext context,
    required String email,
    required String password,
    required String name,
    required String employeeId,
    required String department,
    required PlatformFile? document,
  }) async {
    // Validate all fields first
    if (email.trim().isEmpty || 
        password.isEmpty ||
        name.trim().isEmpty ||
        employeeId.trim().isEmpty ||
        department.trim().isEmpty) {
      _showErrorMessage(context, "Please fill in all required fields");
      return false;
    }

    if (document == null) {
      _showErrorMessage(context, "Please upload your credentials");
      return false;
    }

    try {
      if (kDebugMode) {
        print("Starting mentor signup process...");
        print("Using file: ${document.name}");
      }
      
      final success = await authController.signUpMentor(
        email: email.trim(),
        password: password,
        name: name.trim(),
        employeeId: employeeId.trim(),
        department: department.trim(),
        document: document,
        context: context,
      );

      if (success && context.mounted) {
        if (kDebugMode) {
          print("Mentor signup successful, navigating to email confirmation");
        }
        
        // Navigate to email confirmation screen first
        // The email confirmation screen will then navigate to the mentor approval screen
        AppRoutes.navigateToMentorEmailConfirmation(
          context,
          email.trim(),
        );
        return true;
      } else if (context.mounted) {
        if (kDebugMode) {
          print("Mentor signup returned false");
        }
        return false;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error in mentor signup: $e");
      }
      _showErrorMessage(context, "Error: ${e.toString()}");
      return false;
    }
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