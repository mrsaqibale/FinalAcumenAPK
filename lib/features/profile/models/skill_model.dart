import 'package:cloud_firestore/cloud_firestore.dart';

class SkillModel {
  final String id;
  final String name;
  final String? fileUrl;
  final String? fileType; // 'pdf' or 'image'
  final bool isVerified;
  final DateTime createdAt;

  SkillModel({
    required this.id,
    required this.name,
    this.fileUrl,
    this.fileType,
    this.isVerified = false,
    required this.createdAt,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      fileUrl: json['fileUrl'],
      fileType: json['fileType'],
      isVerified: json['isVerified'] ?? false,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'isVerified': isVerified,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  SkillModel copyWith({
    String? id,
    String? name,
    String? fileUrl,
    String? fileType,
    bool? isVerified,
    DateTime? createdAt,
  }) {
    return SkillModel(
      id: id ?? this.id,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 