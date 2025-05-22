import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:acumen/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Constructor to set persistence
  AuthService() {
    // Set persistence for both web and mobile platforms
    if (kIsWeb) {
      _auth.setPersistence(Persistence.LOCAL);
      if (kDebugMode) {
        print("Auth service initialized with LOCAL persistence (Web platform)");
      }
    } else {
      // For mobile platforms, Firebase Auth automatically persists the auth state
      // We just need to ensure we're not clearing it
      if (kDebugMode) {
        print("Auth service initialized (Mobile platform - persistence enabled by default)");
      }
    }
  }

  // Stream to listen to authentication changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;

  // Reload current user to get updated properties
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
      if (kDebugMode) {
        print("User reloaded successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error reloading user: $e");
      }
      rethrow;
    }
  }

  // Sign in user with persistence
  Future<UserCredential?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Ensure persistence is set
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
      }
      
      // Check if user is active
      final userData = await getUserData(userCredential.user!.uid);
      if (userData != null && !userData.isActive) {
        // User is inactive, throw exception
        await _auth.signOut(); // Sign them out immediately
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Your account has been deactivated. Please contact an administrator.',
        );
      }
      
      if (kDebugMode) {
        print("User signed in successfully: ${userCredential.user?.email}");
      }
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print("Error signing in: $e");
      }
      rethrow;
    }
  }

  // Sign in mentor
  Future<UserCredential?> signInMentor(String email, String password, String employeeId) async {
    try {
      // First verify the employee ID
      final mentorDoc = await _firestore
          .collection('users')
          .where('employeeId', isEqualTo: employeeId)
          .where('role', isEqualTo: 'mentor')
          .limit(1)
          .get();

      if (mentorDoc.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Invalid employee ID or not registered as mentor',
        );
      }
      
      // Check if mentor is active
      final mentorData = mentorDoc.docs.first.data();
      final isActive = mentorData['isActive'] ?? true;
      if (!isActive) {
        throw FirebaseAuthException(
          code: 'user-disabled',
          message: 'Your account has been deactivated. Please contact an administrator.',
        );
      }

      // Then sign in
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Sign up user
  Future<UserCredential> signUp(
    String email,
    String password,
    String name,
    int rollNo,
    bool isFirstSemester,
    String? document,
  ) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user data in Firestore
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: 'student',
        rollNo: rollNo,
        isFirstSemester: isFirstSemester,
        status: 'active',
        isApproved: true,
        document: document,
      );
      
      await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Sign up mentor
  Future<UserCredential> signUpMentor(
    String email,
    String password,
    String name,
    String employeeId,
    String department,
    String? document,
  ) async {
    try {
      // Create auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user data in Firestore
      final user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
        role: 'mentor',
        employeeId: employeeId,
        department: department,
        status: 'pending_approval',
        isApproved: false,
        document: document,
      );
      
      await _firestore.collection('users').doc(userCredential.user!.uid).set(user.toMap());

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Sign out user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
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

  // Upload document to Firebase Storage
  Future<String> _uploadDocument(PlatformFile file) async {
    try {
      if (kDebugMode) {
        print("Starting document upload for: ${file.name}");
        print("File has bytes: ${file.bytes != null}");
        print("File has path: ${file.path != null}");
      }

      final Uint8List fileBytes;
      
      // Get file bytes either from memory or from path
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        // If we're on mobile, the bytes might be null but the path is available
        throw Exception('File path handling not implemented. Please use web picker.');
      } else {
        throw Exception('File data is missing. Please try uploading again.');
      }

      final storageRef = _storage.ref()
          .child('user_documents')
          .child('${DateTime.now().millisecondsSinceEpoch}_${file.name}');

      if (kDebugMode) {
        print("Upload started to path: ${storageRef.fullPath}");
      }
      
      // Upload the file with appropriate content type
      final uploadTask = await storageRef.putData(
        fileBytes,
        SettableMetadata(
          contentType: _getContentType(file.name),
          customMetadata: {
            'fileName': file.name,
            'fileSize': file.size.toString(),
            'fileType': file.name.split('.').last.toLowerCase(),
          },
        ),
      );

      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      if (kDebugMode) {
        print("Upload completed. Download URL: $downloadUrl");
      }
      
      return downloadUrl;
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading document: $e");
      }
      rethrow;
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData({
    required String uid,
    required String name,
    required int rollNo,
    required String email,
    required bool isFirstSemester,
    required String documentUrl,
    required bool isEmailVerified,
  }) async {
    try {
      if (kDebugMode) {
        print("Saving user data to Firestore for UID: $uid");
      }
      
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'rollNo': rollNo,
        'email': email,
        'semester': isFirstSemester ? 1 : 2,
        'documentUrl': documentUrl,
        'documentType': isFirstSemester ? 'admission_slip' : 'transcript',
        'isEmailVerified': isEmailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': 'student',  // Default role
        'status': 'pending', // Pending until email verification
      });
      
      if (kDebugMode) {
        print("User data saved successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving user data: $e");
      }
      rethrow;
    }
  }

  // Save teacher data to Firestore
  Future<void> _saveTeacherData({
    required String uid,
    required String name,
    required String employeeId,
    required String email,
    required String department,
    required String documentUrl,
    required bool isEmailVerified,
  }) async {
    try {
      if (kDebugMode) {
        print("Saving teacher data to Firestore for UID: $uid");
      }
      
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'employeeId': employeeId,
        'email': email,
        'department': department,
        'documentUrl': documentUrl,
        'documentType': 'teacher_credentials',
        'isEmailVerified': isEmailVerified,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'role': 'teacher',
        'status': 'pending_approval', // Requires admin approval even after email verification
        'isApproved': false, // Flag to track admin approval
      });
      
      if (kDebugMode) {
        print("Teacher data saved successfully");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error saving teacher data: $e");
      }
      rethrow;
    }
  }

  // Update user verification status in Firestore
  Future<void> updateUserVerificationStatus(String uid, bool isVerified) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isEmailVerified': isVerified,
        'status': isVerified ? 'active' : 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print("Error updating verification status: $e");
      }
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }
      await user.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) {
        print("Error sending verification email: $e");
      }
      rethrow;
    }
  }

  // Check if email is verified
  Future<bool> isEmailVerified() async {
    try {
      // Reload user to get the latest verification status
      await _auth.currentUser?.reload();
      final isVerified = _auth.currentUser?.emailVerified ?? false;
      
      // Update Firestore if email is verified
      if (isVerified && _auth.currentUser != null) {
        await updateUserVerificationStatus(_auth.currentUser!.uid, true);
      }
      
      return isVerified;
    } catch (e) {
      if (kDebugMode) {
        print("Error checking email verification: $e");
      }
      return false;
    }
  }

  // Sign in student with roll number
  Future<UserCredential?> signInWithRollNumber(String rollNumber, String password) async {
    try {
      if (kDebugMode) {
        print('Attempting to sign in with roll number: $rollNumber');
      }

      // Try to parse roll number as integer, but also keep the original string
      int? rollNoInt;
      try {
        rollNoInt = int.parse(rollNumber);
      } catch (e) {
        if (kDebugMode) {
          print('Roll number is not a valid integer: $rollNumber');
        }
      }

      // Query for student with either string or integer roll number
      QuerySnapshot studentQuery;
      if (rollNoInt != null) {
        studentQuery = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('isActive', isEqualTo: true)  // Only active students
            .where(Filter.or(
              Filter('rollNo', isEqualTo: rollNoInt),
              Filter('rollNo', isEqualTo: rollNumber),
            ))
            .limit(1)
            .get();
      } else {
        studentQuery = await _firestore
            .collection('users')
            .where('role', isEqualTo: 'student')
            .where('isActive', isEqualTo: true)  // Only active students
            .where('rollNo', isEqualTo: rollNumber)
            .limit(1)
            .get();
      }

      if (studentQuery.docs.isEmpty) {
        if (kDebugMode) {
          print('No student found with roll number: $rollNumber');
        }
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Invalid roll number or student account is inactive',
        );
      }

      final studentData = studentQuery.docs.first.data() as Map<String, dynamic>;
      final email = studentData['email'] as String?;

      if (email == null) {
        if (kDebugMode) {
          print('Student found but email is null for roll number: $rollNumber');
        }
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Student account is not properly configured',
        );
      }

      if (kDebugMode) {
        print('Found student with email: $email');
      }

      // Then sign in with email and password
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error in signInWithRollNumber: $e');
      }
      if (e is FirebaseAuthException) {
        rethrow;
      }
      throw FirebaseAuthException(
        code: 'sign-in-failed',
        message: 'Failed to sign in: ${e.toString()}',
      );
    }
  }
} 