import 'package:cloud_firestore/cloud_firestore.dart';

class ResourceItem {
  final String id;
  final String title;
  final String description;
  final String type; // pdf, doc, link, etc.
  final String resourceType; // Course Syllabus, Assignment, etc.
  final DateTime dateAdded;
  final String? fileUrl;
  final String? fileName;
  final String mentorId;
  final String mentorName;
  final String? mentorEmail;
  
  // New fields for resource source tracking
  String sourceType = 'Resource'; // 'Resource', 'Chat', or 'Community'
  
  // Chat related fields
  String? chatId;
  String? chatName;
  
  // Community related fields
  String? communityId;
  String? communityName;

  ResourceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.resourceType,
    required this.dateAdded,
    this.fileUrl,
    this.fileName,
    required this.mentorId,
    required this.mentorName,
    this.mentorEmail,
    this.sourceType = 'Resource',
    this.chatId,
    this.chatName,
    this.communityId,
    this.communityName,
  });
  
  factory ResourceItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ResourceItem(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: data['fileType'] ?? data['type'] ?? 'other', // Support both old and new field names
      resourceType: data['resourceType'] ?? 'Other',
      dateAdded: (data['dateAdded'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      mentorId: data['mentorId'] ?? '',
      mentorName: data['mentorName'] ?? 'Unknown Mentor',
      mentorEmail: data['mentorEmail'] ?? '',
    );
  }
} 