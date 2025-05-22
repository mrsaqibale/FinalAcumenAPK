import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/skill_model.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();

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
    
    // Load skills from the skills subcollection
    final skillsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .get();

    final skills = skillsSnapshot.docs.map((doc) {
      return SkillModel.fromJson({...doc.data(), 'id': doc.id});
    }).toList();

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
    required List<SkillModel> skills,
  }) async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (name.trim().isEmpty) {
      throw Exception('Name cannot be empty');
    }

    // Start a batch write
    final batch = _firestore.batch();
    
    // Update user profile
    batch.update(_firestore.collection('users').doc(userId), {
      'name': name.trim(),
      'bio': bio.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    
    // Save skills individually in the skills subcollection
    for (var skill in skills) {
      final skillRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skill.id);
      
      batch.set(skillRef, skill.toJson());
    }
    
    // Commit the batch
    await batch.commit();
  }

  Future<SkillModel> addSkill({
    required String name,
    File? file,
    String? fileType,
  }) async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    if (name.trim().isEmpty) {
      throw Exception('Skill name cannot be empty');
    }

    String? fileUrl;
    
    // Upload file if provided
    if (file != null && fileType != null) {
      final extension = fileType == 'pdf' ? 'pdf' : 'jpg';
      final skillId = _uuid.v4();
      final storageRef = _storage.ref()
          .child('users')
          .child(userId)
          .child('skills')
          .child('$skillId.$extension');
      
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: fileType == 'pdf' ? 'application/pdf' : 'image/jpeg'),
      );
      
      final snapshot = await uploadTask;
      fileUrl = await snapshot.ref.getDownloadURL();
    }
    
    final skillData = SkillModel(
      id: _uuid.v4(),
      name: name.trim(),
      fileUrl: fileUrl,
      fileType: fileType,
      isVerified: false,
      createdAt: DateTime.now(),
    );
    
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .doc(skillData.id)
        .set(skillData.toJson());
        
    return skillData;
  }
  
  Future<void> removeSkill(String skillId) async {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Get the skill data to check if there's a file to delete
    final skillDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('skills')
        .doc(skillId)
        .get();
        
    if (skillDoc.exists) {
      final skillData = skillDoc.data();
      final fileUrl = skillData?['fileUrl'] as String?;
      
      // Delete the file from storage if it exists
      if (fileUrl != null) {
        try {
          final fileRef = _storage.refFromURL(fileUrl);
          await fileRef.delete();
        } catch (e) {
          // Log error but continue with document deletion
          print('Error deleting file: $e');
        }
      }
      
      // Delete the skill document
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skillId)
          .delete();
    }
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
  
  // Admin methods for skill verification
  
  static Future<List<Map<String, dynamic>>> getPendingSkillVerifications() async {
    final result = <Map<String, dynamic>>[];
    
    try {
      // Get all users
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      
      // For each user, get their skills that have files but are not verified
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        
        final skillsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('skills')
            .where('fileUrl', isNull: false)
            .where('isVerified', isEqualTo: false)
            .get();
            
        for (final skillDoc in skillsSnapshot.docs) {
          final skillData = skillDoc.data();
          
          result.add({
            'userId': userId,
            'userName': userData['name'] ?? 'Unknown',
            'userPhotoUrl': userData['profileImageUrl'],
            'skillId': skillDoc.id,
            'skillName': skillData['name'] ?? '',
            'fileUrl': skillData['fileUrl'] ?? '',
            'fileType': skillData['fileType'] ?? '',
          });
        }
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to get pending skill verifications: $e');
    }
  }
  
  static Future<List<Map<String, dynamic>>> getVerifiedSkillUsers() async {
    final result = <Map<String, dynamic>>[];
    
    try {
      // Get all users
      final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
      
      // For each user, check if they have any verified skills
      for (final userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        
        final skillsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('skills')
            .where('isVerified', isEqualTo: true)
            .get();
            
        if (skillsSnapshot.docs.isNotEmpty) {
          result.add({
            'userId': userId,
            'userName': userData['name'] ?? 'Unknown',
            'userEmail': userData['email'] ?? '',
            'userPhotoUrl': userData['profileImageUrl'],
            'verifiedSkills': skillsSnapshot.docs.map((doc) => doc.data()['name']).toList(),
          });
        }
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to get verified skill users: $e');
    }
  }
  
  static Future<void> verifySkill(String userId, String skillId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skillId)
          .update({
            'isVerified': true,
          });
    } catch (e) {
      throw Exception('Failed to verify skill: $e');
    }
  }
  
  static Future<void> rejectSkill(String userId, String skillId) async {
    try {
      // Get the skill data to check if there's a file to delete
      final skillDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skillId)
          .get();
          
      if (skillDoc.exists) {
        final skillData = skillDoc.data();
        final fileUrl = skillData?['fileUrl'] as String?;
        
        // Delete the file from storage if it exists
        if (fileUrl != null) {
          try {
            final fileRef = FirebaseStorage.instance.refFromURL(fileUrl);
            await fileRef.delete();
          } catch (e) {
            // Log error but continue with document update
            print('Error deleting file: $e');
          }
        }
        
        // Update the skill document to remove file and verification
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('skills')
            .doc(skillId)
            .update({
              'fileUrl': null,
              'fileType': null,
              'isVerified': false,
            });
      }
    } catch (e) {
      throw Exception('Failed to reject skill: $e');
    }
  }
} 