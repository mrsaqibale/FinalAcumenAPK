import 'package:acumen/features/profile/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MentorController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<UserModel> _mentors = [];
  bool _isLoading = false;
  String? _error;
  
  List<UserModel> get mentors => _mentors;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  MentorController() {
    loadMentors();
  }
  
  Future<void> loadMentors() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get all users with role 'mentor' and status 'active' (approved mentors)
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', whereIn: ['mentor', 'teacher']) // Include both mentors and teachers
          .where('status', isEqualTo: 'active')
          .where('isApproved', isEqualTo: true)
          .get();
      
      _mentors = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
      
      if (kDebugMode) {
        print('Loaded ${_mentors.length} mentors');
      }
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading mentors: $_error');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 