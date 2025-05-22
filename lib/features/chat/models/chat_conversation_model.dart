import 'package:hive_flutter/hive_flutter.dart';

// Temporary adapter until we can generate it properly
class ChatConversationAdapter extends TypeAdapter<ChatConversation> {
  @override
  final typeId = 2;

  @override
  ChatConversation read(BinaryReader reader) {
    return ChatConversation(
      id: reader.read(),
      participantId: reader.read(),
      participantName: reader.read(),
      participantImageUrl: reader.read(),
      lastMessage: reader.read(),
      lastMessageTime: reader.read(),
      hasUnreadMessages: reader.read(),
      isGroup: reader.read(),
      participantHasVerifiedSkills: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatConversation obj) {
    writer.write(obj.id);
    writer.write(obj.participantId);
    writer.write(obj.participantName);
    writer.write(obj.participantImageUrl);
    writer.write(obj.lastMessage);
    writer.write(obj.lastMessageTime);
    writer.write(obj.hasUnreadMessages);
    writer.write(obj.isGroup);
    writer.write(obj.participantHasVerifiedSkills);
  }
}

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
  final bool hasUnreadMessages;
  
  @HiveField(7)
  final bool isGroup;

  @HiveField(8)
  final bool participantHasVerifiedSkills;
  
  ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantImageUrl,
    required this.lastMessage,
    required this.lastMessageTime,
    this.hasUnreadMessages = false,
    this.isGroup = false,
    this.participantHasVerifiedSkills = false,
  });
  
  String get timeString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(lastMessageTime.year, lastMessageTime.month, lastMessageTime.day);
    
    if (messageDate == today) {
      return '${lastMessageTime.hour.toString().padLeft(2, '0')}:${lastMessageTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${lastMessageTime.day}/${lastMessageTime.month}/${lastMessageTime.year}';
    }
  }
  
  ChatConversation copyWith({
    String? id,
    String? participantId,
    String? participantName,
    String? participantImageUrl,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool? hasUnreadMessages,
    bool? isGroup,
    bool? participantHasVerifiedSkills,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantImageUrl: participantImageUrl ?? this.participantImageUrl,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
      isGroup: isGroup ?? this.isGroup,
      participantHasVerifiedSkills: participantHasVerifiedSkills ?? this.participantHasVerifiedSkills,
    );
  }
} 