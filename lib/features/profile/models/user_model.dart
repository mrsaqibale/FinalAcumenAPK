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
    );
  }
} 