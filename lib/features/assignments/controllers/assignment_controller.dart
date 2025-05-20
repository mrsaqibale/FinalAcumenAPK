import 'package:acumen/features/assignments/models/assignment_model.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class AssignmentController extends ChangeNotifier {
  List<AssignmentModel> _assignments = [];
  bool _isLoading = false;
  String? _error;

  List<AssignmentModel> get assignments => _assignments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get assignments for a specific course
  List<AssignmentModel> getAssignmentsForCourse(String courseId) {
    return _assignments.where((assignment) => assignment.courseId == courseId).toList();
  }

  // Get assignments for a specific student
  List<AssignmentModel> getAssignmentsForStudent(String studentId) {
    return _assignments.where((assignment) => 
      assignment.assignedToStudentIds.isEmpty || // If empty, it's assigned to all students
      assignment.assignedToStudentIds.contains(studentId)
    ).toList();
  }

  // Get assignments created by a specific teacher
  List<AssignmentModel> getAssignmentsCreatedByTeacher(String teacherId) {
    return _assignments.where((assignment) => assignment.teacherId == teacherId).toList();
  }

  // Load all assignments
  Future<void> loadAssignments() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // In a real app, you would fetch from an API or local database
      _assignments = [
        AssignmentModel(
          id: '1',
          title: 'Midterm Project',
          description: 'Complete a research paper on a topic of your choice.',
          dueDate: DateTime.now().add(const Duration(days: 14)),
          courseId: 'CS101',
          courseName: 'Introduction to Computer Science',
          teacherId: 'teacher1',
          teacherName: 'Professor Johnson',
          maxPoints: 100,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        AssignmentModel(
          id: '2',
          title: 'Weekly Quiz',
          description: 'Complete the online quiz covering chapters 3-5.',
          dueDate: DateTime.now().add(const Duration(days: 3)),
          courseId: 'MATH202',
          courseName: 'Advanced Calculus',
          teacherId: 'teacher2',
          teacherName: 'Dr. Smith',
          maxPoints: 50,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
          updatedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        AssignmentModel(
          id: '3',
          title: 'Final Exam',
          description: 'Comprehensive exam covering all course material.',
          dueDate: DateTime.now().add(const Duration(days: 30)),
          courseId: 'CS101',
          courseName: 'Introduction to Computer Science',
          teacherId: 'teacher1',
          teacherName: 'Professor Johnson',
          maxPoints: 200,
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        print('Error loading assignments: $e');
      }
      notifyListeners();
    }
  }

  // Create a new assignment
  Future<AssignmentModel> createAssignment({
    required String title,
    required String description,
    required DateTime dueDate,
    required String courseId,
    required String courseName,
    required String teacherId,
    required String teacherName,
    List<String>? assignedToStudentIds,
    required int maxPoints,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final now = DateTime.now();
      final assignment = AssignmentModel(
        id: const Uuid().v4(),
        title: title,
        description: description,
        dueDate: dueDate,
        courseId: courseId,
        courseName: courseName,
        teacherId: teacherId,
        teacherName: teacherName,
        assignedToStudentIds: assignedToStudentIds ?? [],
        maxPoints: maxPoints,
        additionalInfo: additionalInfo,
        createdAt: now,
        updatedAt: now,
      );

      _assignments.add(assignment);
      notifyListeners();
      
      return assignment;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating assignment: $e');
      }
      rethrow;
    }
  }

  // Update an existing assignment
  Future<AssignmentModel> updateAssignment({
    required String id,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? assignedToStudentIds,
    int? maxPoints,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      final index = _assignments.indexWhere((a) => a.id == id);
      if (index < 0) {
        throw Exception('Assignment not found');
      }

      final oldAssignment = _assignments[index];
      final updatedAssignment = oldAssignment.copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
        assignedToStudentIds: assignedToStudentIds,
        maxPoints: maxPoints,
        additionalInfo: additionalInfo,
        updatedAt: DateTime.now(),
      );

      _assignments[index] = updatedAssignment;
      notifyListeners();
      
      return updatedAssignment;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating assignment: $e');
      }
      rethrow;
    }
  }

  // Delete an assignment
  Future<void> deleteAssignment(String id) async {
    try {
      _assignments.removeWhere((a) => a.id == id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting assignment: $e');
      }
      rethrow;
    }
  }

  // Assign an assignment to specific students
  Future<AssignmentModel> assignToStudents({
    required String assignmentId,
    required List<String> studentIds,
  }) async {
    try {
      final index = _assignments.indexWhere((a) => a.id == assignmentId);
      if (index < 0) {
        throw Exception('Assignment not found');
      }

      final oldAssignment = _assignments[index];
      final updatedAssignment = oldAssignment.copyWith(
        assignedToStudentIds: studentIds,
        updatedAt: DateTime.now(),
      );

      _assignments[index] = updatedAssignment;
      notifyListeners();
      
      return updatedAssignment;
    } catch (e) {
      if (kDebugMode) {
        print('Error assigning to students: $e');
      }
      rethrow;
    }
  }
} 