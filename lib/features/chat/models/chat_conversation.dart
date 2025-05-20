import 'package:hive/hive.dart';

part 'chat_conversation.g.dart';

@HiveType(typeId: 2)
class ChatConversation {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String participantId;
  
  @HiveField(2)
  final String participantName;
  
  @HiveField(3)
  final String? participantImageUrl;
  
  @HiveField(4)
  final String lastMessage;
  
  @HiveField(5)
  final DateTime lastMessageTime;
  
  @HiveField(6)
  final bool isUnread;
  
  @HiveField(7)
  final bool isGroup;
  
  @HiveField(8)
  final bool isActive;
  
  ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.isUnread = false,
    this.isGroup = false,
    this.isActive = true,
  });
} 