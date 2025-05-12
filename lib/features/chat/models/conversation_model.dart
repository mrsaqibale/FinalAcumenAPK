import 'package:cloud_firestore/cloud_firestore.dart';

class ConversationModel {
  final String id;
  final String name;
  final String? description;
  final List<String> members;
  final String createdBy;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final bool isGroup;
  final int unreadCount;
  final String? lastMessage;
  final String? lastMessageSender;
  final String? imageUrl;

  ConversationModel({
    required this.id,
    required this.name,
    this.description,
    required this.members,
    required this.createdBy,
    required this.createdAt,
    required this.lastMessageAt,
    required this.isGroup,
    this.unreadCount = 0,
    this.lastMessage,
    this.lastMessageSender,
    this.imageUrl,
  });

  factory ConversationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ConversationModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'],
      members: List<String>.from(data['members'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isGroup: data['isGroup'] ?? false,
      unreadCount: data['unreadCount'] ?? 0,
      lastMessage: data['lastMessage'],
      lastMessageSender: data['lastMessageSender'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'members': members,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      'isGroup': isGroup,
      'unreadCount': unreadCount,
      'lastMessage': lastMessage,
      'lastMessageSender': lastMessageSender,
      'imageUrl': imageUrl,
    };
  }

  ConversationModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? members,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    bool? isGroup,
    int? unreadCount,
    String? lastMessage,
    String? lastMessageSender,
    String? imageUrl,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      members: members ?? this.members,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isGroup: isGroup ?? this.isGroup,
      unreadCount: unreadCount ?? this.unreadCount,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageSender: lastMessageSender ?? this.lastMessageSender,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
} 