import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String venue;
  final DateTime startDate;
  final DateTime endDate;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;
  final String? imageUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.venue,
    required this.startDate,
    required this.endDate,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
    this.imageUrl,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      venue: map['venue'] ?? '',
      startDate: _parseDate(map['startDate']),
      endDate: _parseDate(map['endDate']),
      createdBy: map['createdBy'] ?? '',
      createdAt: _parseDate(map['createdAt']),
      isActive: map['isActive'] ?? true,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  // Helper method to handle different date formats
  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is int) {
      // Handle milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is DateTime) {
      return value;
    }
    // Default fallback
    return DateTime.now();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'venue': venue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? venue,
    DateTime? startDate,
    DateTime? endDate,
    String? createdBy,
    DateTime? createdAt,
    bool? isActive,
    String? imageUrl,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      venue: venue ?? this.venue,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 