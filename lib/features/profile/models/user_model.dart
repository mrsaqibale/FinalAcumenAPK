class UserModel {
  final String id;
  final String name;
  final String email;
  final String role; // 'admin', 'mentor', 'student', 'teacher'
  final bool isActive;
  final String? title;
  final String? photoUrl;
  final String? status; // 'active', 'pending', 'pending_approval'
  final bool? isApproved; // For teacher approval
  final String? employeeId; // For mentors
  final String? department; // For mentors
  final int? rollNo; // For students
  final bool? isFirstSemester; // For students
  final String? document; // Document URL for students and mentors
  final Map<String, dynamic>? education; // Education information
  final Map<String, dynamic>? quizStats; // Quiz statistics
  final List<Map<String, dynamic>>? recentQuizzes; // Recent quiz results

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    this.title,
    this.photoUrl,
    this.status,
    this.isApproved,
    this.employeeId,
    this.department,
    this.rollNo,
    this.isFirstSemester,
    this.document,
    this.education,
    this.quizStats,
    this.recentQuizzes,
  });

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'isActive': isActive,
      'title': title,
      'photoUrl': photoUrl,
      'status': status,
      'isApproved': isApproved,
      'employeeId': employeeId,
      'department': department,
      'rollNo': rollNo,
      'isFirstSemester': isFirstSemester,
      'document': document,
      'education': education,
      'quizStats': quizStats,
      'recentQuizzes': recentQuizzes,
    };
  }

  // Create from Firebase map
  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      isActive: map['isActive'] ?? true,
      title: map['title'],
      photoUrl: map['photoUrl'],
      status: map['status'],
      isApproved: map['isApproved'],
      employeeId: map['employeeId'],
      department: map['department'],
      rollNo: map['rollNo'] is int ? map['rollNo'] as int : null,
      isFirstSemester: map['isFirstSemester'] as bool?,
      document: map['document'],
      education: map['education'] as Map<String, dynamic>?,
      quizStats: map['quizStats'] as Map<String, dynamic>?,
      recentQuizzes: map['recentQuizzes'] != null 
          ? List<Map<String, dynamic>>.from(map['recentQuizzes'])
          : null,
    );
  }
} 