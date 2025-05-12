class AssignmentModel {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final List<String> assignedToStudentIds;
  final int maxPoints;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AssignmentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    this.assignedToStudentIds = const [],
    required this.maxPoints,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  AssignmentModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
    List<String>? assignedToStudentIds,
    int? maxPoints,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      assignedToStudentIds: assignedToStudentIds ?? this.assignedToStudentIds,
      maxPoints: maxPoints ?? this.maxPoints,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      assignedToStudentIds: (json['assignedToStudentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      maxPoints: json['maxPoints'] as int,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'assignedToStudentIds': assignedToStudentIds,
      'maxPoints': maxPoints,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 