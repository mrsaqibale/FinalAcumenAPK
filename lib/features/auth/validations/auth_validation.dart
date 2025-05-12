import 'package:file_picker/file_picker.dart';

class AuthValidation {
  // Validate email
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  // Validate password
  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }

  // Validate name
  static String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Name is required';
    }
    
    if (name.length < 3) {
      return 'Name must be at least 3 characters';
    }
    
    return null;
  }

  // Validate roll number
  static String? validateRollNumber(String? rollNo) {
    if (rollNo == null || rollNo.isEmpty) {
      return 'Roll number is required';
    }
    
    if (int.tryParse(rollNo) == null) {
      return 'Roll number must be a valid number';
    }
    
    return null;
  }

  // Validate document (PDF, PNG, JPG)
  static String? validateDocument(PlatformFile? file) {
    if (file == null) {
      return 'Document is required';
    }
    
    final fileName = file.name.toLowerCase();
    final allowedExtensions = ['.pdf', '.png', '.jpg', '.jpeg'];
    final hasValidExtension = allowedExtensions.any((ext) => fileName.endsWith(ext));
    
    if (!hasValidExtension) {
      return 'Only PDF, PNG, and JPG files are allowed';
    }
    
    if (file.bytes == null) {
      return 'File data is missing. Please try uploading again.';
    }
    
    // 2MB size limit
    if (file.size > 2 * 1024 * 1024) {
      return 'Document size must be less than 2MB';
    }
    
    return null;
  }
} 