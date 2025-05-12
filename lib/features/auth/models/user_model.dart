import 'package:acumen/features/auth/models/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? profileImageUrl;
  final UserRole role;
  final List<String> courseIds;
  final Map<String, dynamic>? additionalInfo;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.role,
    this.courseIds = const [],
    this.additionalInfo,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? profileImageUrl,
    UserRole? role,
    List<String>? courseIds,
    Map<String, dynamic>? additionalInfo,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      courseIds: courseIds ?? this.courseIds,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      role: UserRole.values.firstWhere(
        (role) => role.name == (json['role'] as String),
        orElse: () => UserRole.student,
      ),
      courseIds: (json['courseIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'role': role.name,
      'courseIds': courseIds,
      'additionalInfo': additionalInfo,
    };
  }
}

class AppUser {
  final String uid;
  final String email;
  final String? name;
  final String? rollNumber;
  final String? employeeId;
  final String? department;
  final String? photoURL;
  final bool isTeacher;
  final bool isApproved;
  final List<String> enrolledCourses;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    required this.email,
    this.name,
    this.rollNumber,
    this.employeeId,
    this.department,
    this.photoURL,
    required this.isTeacher,
    this.isApproved = false,
    this.enrolledCourses = const [],
    required this.createdAt,
  });

  factory AppUser.fromFirebaseUser(auth.User user, {Map<String, dynamic>? userData}) {
    final data = userData ?? {};
    
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      name: user.displayName ?? data['name'],
      rollNumber: data['rollNo']?.toString(),
      employeeId: data['employeeId'],
      department: data['department'],
      photoURL: user.photoURL ?? data['photoURL'],
      isTeacher: data['role'] == 'teacher',
      isApproved: data['isApproved'] ?? false,
      enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'],
      rollNumber: data['rollNo']?.toString(),
      employeeId: data['employeeId'],
      department: data['department'],
      photoURL: data['photoURL'],
      isTeacher: data['role'] == 'teacher',
      isApproved: data['isApproved'] ?? false,
      enrolledCourses: List<String>.from(data['enrolledCourses'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'rollNo': rollNumber != null ? int.tryParse(rollNumber!) : null,
      'employeeId': employeeId,
      'department': department,
      'photoURL': photoURL,
      'role': isTeacher ? 'teacher' : 'student',
      'isApproved': isApproved,
      'enrolledCourses': enrolledCourses,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
} 