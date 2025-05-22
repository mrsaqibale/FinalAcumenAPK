import 'package:flutter/material.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MentorController extends ChangeNotifier {
  final UserController userController;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  List<UserModel> filteredMentors = [];

  MentorController({required this.userController}) {
    filteredMentors = userController.mentors;
    searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    searchQuery = searchController.text;
    _filterMentors();
    notifyListeners();
  }

  void _filterMentors() {
    if (searchQuery.isEmpty) {
      filteredMentors = userController.mentors;
    } else {
      final query = searchQuery.toLowerCase();
      filteredMentors = userController.mentors.where((mentor) {
        return mentor.name.toLowerCase().contains(query) ||
               mentor.email.toLowerCase().contains(query) ||
               (mentor.employeeId?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  Future<void> refreshMentors() async {
    await userController.loadUsersByRole('mentor');
    _filterMentors();
    notifyListeners();
  }

  void updateMentorActiveStatus(UserModel mentor, bool isActive) {
    userController.updateUserActiveStatus(mentor, isActive);
    notifyListeners();
  }

  void updateMentorApprovalStatus(UserModel mentor, bool isApproved) {
    userController.updateMentorApprovalStatus(mentor, isApproved);
    notifyListeners();
  }

  void clearSearch() {
    searchController.clear();
  }

  Future<bool> deleteMentor(UserModel mentor) async {
    try {
      // Delete the user from Firebase Auth
      await FirebaseAuth.instance.currentUser?.delete();
      
      // Delete the user from Firestore
      final success = await userController.deleteUser(mentor.id);
      
      if (success) {
        // Update the local list
        _filterMentors();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting mentor: $e');
      return false;
    }
  }
} 