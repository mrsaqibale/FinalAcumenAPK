enum UserRole {
  student,
  teacher,
  admin;

  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.teacher:
        return 'Teacher';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  bool get canCreateAssignments => this == UserRole.teacher || this == UserRole.admin;
  bool get canCreateCommunities => this == UserRole.teacher || this == UserRole.admin;
  bool get canShareResources => this == UserRole.teacher || this == UserRole.admin;
  bool get canManageUsers => this == UserRole.admin;
} 