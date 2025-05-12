class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String creatorId;
  final String creatorName;
  final List<String> memberIds;
  final List<String> moderatorIds;
  final String courseId;
  final String courseName;
  final Map<String, dynamic>? additionalInfo;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.creatorId,
    required this.creatorName,
    this.memberIds = const [],
    this.moderatorIds = const [],
    required this.courseId,
    required this.courseName,
    this.additionalInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? creatorId,
    String? creatorName,
    List<String>? memberIds,
    List<String>? moderatorIds,
    String? courseId,
    String? courseName,
    Map<String, dynamic>? additionalInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      memberIds: memberIds ?? this.memberIds,
      moderatorIds: moderatorIds ?? this.moderatorIds,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['imageUrl'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      memberIds: (json['memberIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      moderatorIds: (json['moderatorIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      courseId: json['courseId'] as String,
      courseName: json['courseName'] as String,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'memberIds': memberIds,
      'moderatorIds': moderatorIds,
      'courseId': courseId,
      'courseName': courseName,
      'additionalInfo': additionalInfo,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 