import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Get all users by role
  Future<List<UserModel>> getUsersByRole(String role) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('role', isEqualTo: role)
          .get();
      
      return querySnapshot.docs.map((doc) => 
        UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting $role users: $e');
      return [];
    }
  }

  // Get pending teacher applications
  Future<List<UserModel>> getPendingTeacherApplications() async {
    try {
      print("Fetching pending mentor applications...");
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('role', whereIn: ['teacher', 'mentor'])
          .where('status', isEqualTo: 'pending_approval')
          .where('isApproved', isEqualTo: false)
          .get();
      
      print("Found ${querySnapshot.docs.length} pending mentor applications");
      
      return querySnapshot.docs.map((doc) => 
        UserModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      print('Error getting pending mentor applications: $e');
      return [];
    }
  }

  // Add a new user
  Future<bool> addUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toMap());
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }

  // Update user active status
  Future<bool> updateUserActiveStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'isActive': isActive
      });
      return true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  // Update mentor approval status
  Future<bool> updateMentorApprovalStatus(String userId, bool isApproved) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'isApproved': isApproved,
        'status': isApproved ? 'active' : 'pending_approval'
      });
      return true;
    } catch (e) {
      print('Error updating mentor approval status: $e');
      return false;
    }
  }

  // Approve teacher account
  Future<bool> approveTeacher(String teacherId) async {
    try {
      await _firestore.collection(_collection).doc(teacherId).update({
        'status': 'active',
        'isApproved': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // In a real app, you might want to send an email notification to the teacher
      
      return true;
    } catch (e) {
      print('Error approving teacher: $e');
      return false;
    }
  }

  // Update teacher status
  Future<bool> updateTeacherStatus(String teacherId, String status) async {
    try {
      bool isApproved = status == 'active';
      
      await _firestore.collection(_collection).doc(teacherId).update({
        'status': status,
        'isApproved': isApproved,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return true;
    } catch (e) {
      print('Error updating teacher status: $e');
      return false;
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final docSnapshot = await _firestore.collection(_collection).doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
} 