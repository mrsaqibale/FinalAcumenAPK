class CourseModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final String imageUrl;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final List<String> assignmentIds;
  final List<String> resourceIds;
  final List<String> communityIds;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CourseModel({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.imageUrl,
    required this.teacherId,
    required this.teacherName,
    this.studentIds = const [],
    this.assignmentIds = const [],
    this.resourceIds = const [],
    this.communityIds = const [],
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  CourseModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? imageUrl,
    String? teacherId,
    String? teacherName,
    List<String>? studentIds,
    List<String>? assignmentIds,
    List<String>? resourceIds,
    List<String>? communityIds,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentIds: studentIds ?? this.studentIds,
      assignmentIds: assignmentIds ?? this.assignmentIds,
      resourceIds: resourceIds ?? this.resourceIds,
      communityIds: communityIds ?? this.communityIds,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      studentIds: (json['studentIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      assignmentIds: (json['assignmentIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      resourceIds: (json['resourceIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      communityIds: (json['communityIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'imageUrl': imageUrl,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'studentIds': studentIds,
      'assignmentIds': assignmentIds,
      'resourceIds': resourceIds,
      'communityIds': communityIds,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 