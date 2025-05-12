class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role;
  final String? employeeId;
  final String? department;
  final int? rollNo;
  final bool? isFirstSemester;
  final String status;
  final bool isApproved;
  final String? document;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.employeeId,
    this.department,
    this.rollNo,
    this.isFirstSemester,
    required this.status,
    required this.isApproved,
    this.document,
  });

  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'employeeId': employeeId,
      'department': department,
      'rollNo': rollNo,
      'isFirstSemester': isFirstSemester,
      'status': status,
      'isApproved': isApproved,
      'document': document,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: map['role'] as String,
      employeeId: map['employeeId'] as String?,
      department: map['department'] as String?,
      rollNo: map['rollNo'] as int?,
      isFirstSemester: map['isFirstSemester'] as bool?,
      status: map['status'] as String,
      isApproved: map['isApproved'] as bool,
      document: map['document'] as String?,
    );
  }
} 