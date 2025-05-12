import 'package:firebase_auth/firebase_auth.dart';

class LoginValidation {
  // Validate roll number format
  static String? validateRollNumber(String? rollNumber) {
    if (rollNumber == null || rollNumber.isEmpty) {
      return 'Please enter your roll number';
    }
    
    // Add specific roll number format validation if needed
    // For example, if roll numbers follow a specific pattern
    // Example: if (!RegExp(r'^[A-Z]{2}\d{6}$').hasMatch(rollNumber)) {
    //   return 'Invalid roll number format';
    // }
    
    return null;
  }
  
  // Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Please enter your password';
    }
    
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    return null;
  }

  // Validate email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email address';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Validate name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Please enter your name';
    }
    
    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }
    
    return null;
  }

  // Validate employee ID
  static String? validateEmployeeId(String? employeeId) {
    if (employeeId == null || employeeId.isEmpty) {
      return 'Please enter your employee ID';
    }
    
    // Add specific employee ID format validation if needed
    
    return null;
  }

  // Validate department
  static String? validateDepartment(String? department) {
    if (department == null || department.isEmpty) {
      return 'Please enter your department';
    }
    
    return null;
  }
  
  // Handle Firebase authentication errors
  static String handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'No user found with this roll number';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid roll number format';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      case 'email-already-in-use':
        return 'The email address is already in use';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'weak-password':
        return 'The password is too weak';
      default:
        return 'Authentication failed: ${error.message}';
    }
  }
} 