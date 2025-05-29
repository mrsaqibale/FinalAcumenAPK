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
      type:
          data['fileType'] ??
          data['type'] ??
          'other', // Support both old and new field names
      resourceType: data['resourceType'] ?? 'Other',
      dateAdded: (data['dateAdded'] as Timestamp).toDate(),
      fileUrl: data['fileUrl'],
      fileName: data['fileName'],
      mentorId: data['mentorId'] ?? '',
      mentorName: data['mentorName'] ?? 'Unknown Mentor',
      mentorEmail: data['mentorEmail'] ?? '',
    );
  }

  factory ResourceItem.fromChatMessage(dynamic msg) {
    // msg can be a ChatMessage or Map<String, dynamic>
    final isMap = msg is Map<String, dynamic>;
    final id = isMap ? (msg['id'] ?? '') : (msg.id ?? '');
    final fileUrl = isMap ? msg['fileUrl'] : msg.fileUrl;
    final fileName = isMap ? msg['fileName'] : msg.fileName;
    final fileType =
        isMap
            ? (msg['fileType'] ?? msg['type'] ?? 'other')
            : (msg.fileType ?? msg.type ?? 'other');
    final senderId = isMap ? (msg['senderId'] ?? '') : (msg.senderId ?? '');
    final senderName =
        isMap ? (msg['senderName'] ?? '') : (msg.senderName ?? '');
    final timestamp =
        isMap
            ? (msg['timestamp'] is DateTime
                ? msg['timestamp']
                : (msg['timestamp']?.toDate() ?? DateTime.now()))
            : (msg.timestamp ?? DateTime.now());
    final text = isMap ? (msg['text'] ?? '') : (msg.text ?? '');
    final chatId = isMap ? (msg['chatId'] ?? null) : (msg.chatId ?? null);
    final chatName = isMap ? (msg['chatName'] ?? null) : (msg.chatName ?? null);
    final communityId =
        isMap ? (msg['communityId'] ?? null) : (msg.communityId ?? null);
    final communityName =
        isMap ? (msg['communityName'] ?? null) : (msg.communityName ?? null);
    final isCommunity = communityId != null;
    return ResourceItem(
      id: id,
      title: fileName ?? 'Media',
      description: text,
      type: fileType,
      resourceType: isCommunity ? 'Community Media' : 'Chat Media',
      dateAdded: timestamp,
      fileUrl: fileUrl,
      fileName: fileName,
      mentorId: senderId,
      mentorName: senderName,
      sourceType: isCommunity ? 'Community' : 'Chat',
      chatId: chatId,
      chatName: chatName,
      communityId: communityId,
      communityName: communityName,
    );
  }
}
