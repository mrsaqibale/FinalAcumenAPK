
import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 1)
class ChatMessage {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String text;
  
  @HiveField(2)
  final String senderId;
  
  @HiveField(3)
  final String receiverId;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final bool isRead;
  
  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
  });
} 