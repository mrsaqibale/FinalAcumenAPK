import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  ProfileRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  Future<Map<String, dynamic>> loadUserData() async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final userDoc = await _firestore
        .collection('users')
        .doc(userId)
        .get();
    
    if (!userDoc.exists) {
      throw Exception('User document not found');
    }

    final userData = userDoc.data() ?? {};
    
    // Process skills data
    List<String> skills = [];
    if (userData['skills'] != null) {
      if (userData['skills'] is List) {
        skills = List<String>.from(userData['skills']);
      } else if (userData['skills'] is String) {
        skills = userData['skills'].toString().split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      }
    }

    return {
      'name': userData['name'] ?? '',
      'email': userData['email'] ?? _auth.currentUser?.email ?? '',
      'bio': userData['bio'] ?? 'No bio added yet. Tell us about yourself!',
      'skills': skills,
    };
  }

  Future<void> saveProfile({
    required String name,
    required String bio,
    required List<String> skills,
  }) async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (name.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }

    await _firestore.collection('users').doc(userId).update({
      'name': name.trim(),
      'bio': bio.trim(),
      'skills': skills,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      // Create a reference to the file location in Firebase Storage
      final storageRef = _storage.ref().child('profile_images').child('$userId.jpg');
      
      // Upload the file
      final uploadTask = storageRef.putFile(
        imageFile, 
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Wait for the upload to complete and get the download URL
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Update the user document with the new image URL
      await _firestore.collection('users').doc(userId).update({
        'profileImageUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  Future<String?> getProfileImageUrl() async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        return userDoc.data()?['profileImageUrl'] as String?;
      }
      
      return null;
    } catch (e) {
      throw Exception('Failed to get profile image URL: $e');
    }
  }
} 