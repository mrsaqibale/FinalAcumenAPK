import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserController with ChangeNotifier {
  final UserRepository _repository = UserRepository();
  
  List<UserModel> _admins = [];
  List<UserModel> _mentors = [];
  List<UserModel> _students = [];
  List<UserModel> _teachers = [];
  List<UserModel> _pendingTeacherApplications = [];
  List<UserModel> _approvedMentors = [];
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserModel> get admins => _admins;
  List<UserModel> get mentors => _mentors;
  List<UserModel> get students => _students;
  List<UserModel> get teachers => _teachers;
  List<UserModel> get pendingTeacherApplications => _pendingTeacherApplications;
  List<UserModel> get approvedMentors => _approvedMentors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load users by role
  Future<void> loadUsersByRole(String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final users = await _repository.getUsersByRole(role);
      
      if (role == 'admin') {
        _admins = users;
      } else if (role == 'mentor') {
        _mentors = users;
      } else if (role == 'student') {
        _students = users;
      } else if (role == 'teacher') {
        _teachers = users;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load $role users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load pending teacher applications
  Future<void> loadPendingTeacherApplications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _pendingTeacherApplications = await _repository.getPendingTeacherApplications();
      if (_pendingTeacherApplications.isEmpty) {
        print("No pending mentor applications found");
      } else {
        print("Found ${_pendingTeacherApplications.length} pending mentor applications");
        for (var mentor in _pendingTeacherApplications) {
          print("Pending mentor: ${mentor.name}, status: ${mentor.status}, approved: ${mentor.isApproved}");
        }
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load pending mentor applications: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add a new user
  Future<bool> addUser(UserModel user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _repository.addUser(user);
      
      if (result) {
        // Reload the appropriate list
        await loadUsersByRole(user.role);
      }
      
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = 'Failed to add user: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update user active status
  Future<bool> updateUserActiveStatus(UserModel user, bool isActive) async {
    try {
      final result = await _repository.updateUserActiveStatus(user.id, isActive);
      
      if (result) {
        // Update the local list
        if (user.role == 'admin') {
          final index = _admins.indexWhere((a) => a.id == user.id);
          if (index != -1) {
            _admins[index] = UserModel(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role,
              isActive: isActive,
              title: user.title,
              photoUrl: user.photoUrl,
              status: user.status,
              isApproved: user.isApproved,
            );
          }
        } else if (user.role == 'mentor') {
          final index = _mentors.indexWhere((m) => m.id == user.id);
          if (index != -1) {
            _mentors[index] = UserModel(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role,
              isActive: isActive,
              title: user.title,
              photoUrl: user.photoUrl,
              status: user.status,
              isApproved: user.isApproved,
            );
          }
        } else if (user.role == 'student') {
          final index = _students.indexWhere((s) => s.id == user.id);
          if (index != -1) {
            _students[index] = UserModel(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role,
              isActive: isActive,
              title: user.title,
              photoUrl: user.photoUrl,
              status: user.status,
              isApproved: user.isApproved,
            );
          }
        } else if (user.role == 'teacher') {
          final index = _teachers.indexWhere((t) => t.id == user.id);
          if (index != -1) {
            _teachers[index] = UserModel(
              id: user.id,
              name: user.name,
              email: user.email,
              role: user.role,
              isActive: isActive,
              title: user.title,
              photoUrl: user.photoUrl,
              status: user.status,
              isApproved: user.isApproved,
            );
          }
        }
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to update user status: $e';
      notifyListeners();
      return false;
    }
  }

  // Update mentor approval status
  Future<bool> updateMentorApprovalStatus(UserModel mentor, bool isApproved) async {
    try {
      final result = await _repository.updateMentorApprovalStatus(mentor.id, isApproved);
      
      if (result) {
        // Update the local list
        final index = _mentors.indexWhere((m) => m.id == mentor.id);
        if (index != -1) {
          _mentors[index] = UserModel(
            id: mentor.id,
            name: mentor.name,
            email: mentor.email,
            role: mentor.role,
            isActive: mentor.isActive,
            title: mentor.title,
            photoUrl: mentor.photoUrl,
            status: isApproved ? 'active' : 'pending_approval',
            isApproved: isApproved,
          );
        }
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to update mentor approval status: $e';
      notifyListeners();
      return false;
    }
  }

  // Update teacher status
  Future<bool> updateTeacherStatus(UserModel teacher, String status) async {
    try {
      final result = await _repository.updateTeacherStatus(teacher.id, status);
      
      if (result) {
        // Update the local lists
        // If it was a pending application, update the pending list
        if (teacher.status == 'pending_approval') {
          final pendingIndex = _pendingTeacherApplications.indexWhere((t) => t.id == teacher.id);
          if (pendingIndex != -1) {
            if (status != 'pending_approval') {
              _pendingTeacherApplications.removeAt(pendingIndex);
            } else {
              _pendingTeacherApplications[pendingIndex] = _createUpdatedUserModel(teacher, status);
            }
          }
        }
        
        // Update the teachers list
        final teacherIndex = _teachers.indexWhere((t) => t.id == teacher.id);
        if (teacherIndex != -1) {
          _teachers[teacherIndex] = _createUpdatedUserModel(teacher, status);
        } else if (status == 'active') {
          // If the teacher wasn't in the list before (e.g., was pending) but is now active,
          // add them to the teachers list
          _teachers.add(_createUpdatedUserModel(teacher, status));
        }
        
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to update teacher status: $e';
      notifyListeners();
      return false;
    }
  }

  // Helper method to create an updated user model
  UserModel _createUpdatedUserModel(UserModel user, String status) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      isActive: user.isActive,
      title: user.title,
      photoUrl: user.photoUrl,
      status: status,
      isApproved: status == 'active',
    );
  }

  // Approve teacher account
  Future<bool> approveTeacherAccount(UserModel teacher) async {
    return updateTeacherStatus(teacher, 'active');
  }

  // Reject teacher application
  Future<bool> rejectTeacherApplication(UserModel teacher) async {
    return updateTeacherStatus(teacher, 'rejected');
  }

  // Load all users
  Future<void> loadAllUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load all users with their verified skills status
      final users = await _repository.getAllUsersWithSkillStatus();
      
      // Reset all user lists
      _admins = [];
      _mentors = [];
      _students = [];
      _teachers = [];
      _pendingTeacherApplications = [];
      _approvedMentors = [];
      
      // Categorize users
      for (final user in users) {
        switch (user.role.toLowerCase()) {
          case 'admin':
            _admins.add(user);
            break;
          case 'mentor':
            _mentors.add(user);
            if (user.status == 'pending_approval') {
              _pendingTeacherApplications.add(user);
            } else if (user.isApproved == true) {
              _approvedMentors.add(user);
            }
            break;
          case 'teacher':
            _teachers.add(user);
            if (user.status == 'pending_approval') {
              _pendingTeacherApplications.add(user);
            } else if (user.isApproved == true) {
              _approvedMentors.add(user);
            }
            break;
          default:
            _students.add(user);
        }
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load users: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Check if a user has verified skills
  Future<bool> checkUserVerifiedSkills(String userId) async {
    try {
      return await _repository.checkAndUpdateUserVerifiedSkills(userId);
    } catch (e) {
      print('Error checking verified skills: $e');
      return false;
    }
  }

  // Get user by ID
  Future<Map<String, dynamic>?> getUserById(String userId) async {
    try {
      final user = await _repository.getUserById(userId);
      if (user != null) {
        return {
          'id': user.id,
          'name': user.name,
          'email': user.email,
          'role': user.role,
          'isActive': user.isActive,
          'title': user.title,
          'photoUrl': user.photoUrl,
          'status': user.status,
          'isApproved': user.isApproved,
          'education': user.education,
          'quizStats': user.quizStats,
          'recentQuizzes': user.recentQuizzes,
        };
      }
      return null;
    } catch (e) {
      _error = 'Failed to get user: $e';
      notifyListeners();
      return null;
    }
  }

  // Get currently logged in user
  UserModel? getLoggedInUser() {
    try {
      // For now, return the first admin user as a placeholder
      // In a real app, this would get the actual logged-in user from Firebase Auth
      if (_admins.isNotEmpty) {
        return _admins.first;
      }
      return null;
    } catch (e) {
      _error = 'Failed to get logged in user: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      // Delete user document from Firestore
      await _repository.deleteUser(userId);
      
      // Update local lists
      _admins.removeWhere((user) => user.id == userId);
      _mentors.removeWhere((user) => user.id == userId);
      _students.removeWhere((user) => user.id == userId);
      _pendingTeacherApplications.removeWhere((user) => user.id == userId);
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }
} 