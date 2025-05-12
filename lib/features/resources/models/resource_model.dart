class ResourceModel {
  final String id;
  final String title;
  final String description;
  final String type; // pdf, doc, link, video, etc.
  final String url;
  final String courseId;
  final String courseName;
  final String teacherId;
  final String teacherName;
  final List<String> sharedWithStudentIds;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ResourceModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.url,
    required this.courseId,
    required this.courseName,
    required this.teacherId,
    required this.teacherName,
    this.sharedWithStudentIds = const [],
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  ResourceModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    String? url,
    String? courseId,
    String? courseName,
    String? teacherId,
    String? teacherName,
    List<String>? sharedWithStudentIds,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      url: url ?? this.url,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      sharedWithStudentIds: sharedWithStudentIds ?? this.sharedWithStudentIds,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String,
      sharedWithStudentIds: (json['sharedWithStudentIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
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
      'type': type,
      'url': url,
      'courseId': courseId,
      'courseName': courseName,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'sharedWithStudentIds': sharedWithStudentIds,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 