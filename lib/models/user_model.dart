import 'package:flutter/foundation.dart';

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
  final bool isActive;

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
    this.isActive = true,
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
      'isActive': isActive,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      return UserModel(
        uid: map['uid']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        role: map['role']?.toString() ?? 'student',
        employeeId: map['employeeId']?.toString(),
        department: map['department']?.toString(),
        rollNo: map['rollNo'] is int ? map['rollNo'] as int : null,
        isFirstSemester: map['isFirstSemester'] as bool?,
        status: map['status']?.toString() ?? 'pending',
        isApproved: map['isApproved'] as bool? ?? false,
        document: map['document']?.toString(),
        isActive: map['isActive'] as bool? ?? true,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error creating UserModel from map: $e');
        print('Map data: $map');
      }
      rethrow;
    }
  }
} 