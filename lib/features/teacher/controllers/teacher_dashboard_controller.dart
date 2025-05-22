import 'package:flutter/material.dart';
import 'package:acumen/features/auth/models/user_model.dart';
import 'package:acumen/features/courses/models/course_model.dart';
import 'package:acumen/features/assignments/controllers/assignment_controller.dart';

class TeacherDashboardController extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _isLoading = false;
  String? _error;

  // Getters
  int get selectedIndex => _selectedIndex;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Set selected index
  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Mock data for recent activities
  List<Map<String, dynamic>> getRecentActivities() {
    return [
      {
        'title': 'New Assignment Created',
        'description': 'Midterm Project for CS101',
        'time': '2 hours ago',
        'icon': Icons.assignment,
        'color': Colors.orange,
      },
      {
        'title': 'Resource Shared',
        'description': 'Lecture Notes for MATH202',
        'time': '1 day ago',
        'icon': Icons.book,
        'color': Colors.blue,
      },
      {
        'title': 'Community Message',
        'description': 'New message in CS101 Community',
        'time': '2 days ago',
        'icon': Icons.chat,
        'color': Colors.green,
      },
    ];
  }

  // Mock data for courses
  List<CourseModel> getMockCourses() {
    return [
      CourseModel(
        id: 'CS101',
        name: 'Introduction to Computer Science',
        code: 'CS101',
        description: 'An introductory course to computer science concepts.',
        imageUrl: '',
        teacherId: 'teacher1',
        teacherName: 'Professor Johnson',
        studentIds: ['student1', 'student2', 'student3'],
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      CourseModel(
        id: 'MATH202',
        name: 'Advanced Calculus',
        code: 'MATH202',
        description: 'A course covering advanced calculus topics.',
        imageUrl: '',
        teacherId: 'teacher1',
        teacherName: 'Professor Johnson',
        studentIds: ['student1', 'student4', 'student5'],
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ];
  }

  // Quick actions
  void onQuickActionCreateAssignment() {
    // TODO: Implement create assignment navigation
  }

  void onUploadResource() {
    // TODO: Implement upload resource navigation
  }

  void onCreateCommunity() {
    // TODO: Implement create community navigation
  }

  // Course actions
  void onCourseTap(CourseModel course) {
    // TODO: Implement course detail navigation
  }

  void onCreateCourse() {
    // TODO: Implement create course navigation
  }

  void onCourseAction(String action, CourseModel course) {
    switch (action) {
      case 'assignments':
        // TODO: Navigate to course assignments
        break;
      case 'resources':
        // TODO: Navigate to course resources
        break;
      case 'students':
        // TODO: Navigate to course students
        break;
      case 'settings':
        // TODO: Navigate to course settings
        break;
    }
  }

  // Assignment actions
  void onEditAssignment(dynamic assignment) {
    // TODO: Implement edit assignment navigation
  }

  void onViewAssignmentStudents(dynamic assignment) {
    // TODO: Implement view assignment students navigation
  }

  Future<void> onDeleteAssignment(dynamic assignment) async {
    // TODO: Implement delete assignment
  }
} 