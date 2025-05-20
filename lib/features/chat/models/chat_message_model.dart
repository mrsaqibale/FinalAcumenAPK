import 'package:hive_flutter/hive_flutter.dart';

// Note: To generate the adapters, run:
// flutter packages pub run build_runner build --delete-conflicting-outputs

// Temporary adapter until we can generate it properly
class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final typeId = 1;

  @override
  ChatMessage read(BinaryReader reader) {
    return ChatMessage(
      id: reader.read(),
      senderId: reader.read(),
      receiverId: reader.read(),
      text: reader.read(),
      timestamp: reader.read(),
      isRead: reader.read(),
      imageUrl: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer.write(obj.id);
    writer.write(obj.senderId);
    writer.write(obj.receiverId);
    writer.write(obj.text);
    writer.write(obj.timestamp);
    writer.write(obj.isRead);
    writer.write(obj.imageUrl);
  }
}

@HiveType(typeId: 1)
class ChatMessage {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String senderId;
  
  @HiveField(2)
  final String receiverId;
  
  @HiveField(3)
  final String text;
  
  @HiveField(4)
  final DateTime timestamp;
  
  @HiveField(5)
  final bool isRead;
  
  @HiveField(6)
  final String? imageUrl;
  
  @HiveField(7)
  final String? fileUrl;
  
  @HiveField(8)
  final String? fileName;
  
  @HiveField(9)
  final String? fileType;
  
  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.fileType,
  });
  
  bool get isMine => senderId == 'current_user';
  
  String get timeString {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
    
    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? text,
    DateTime? timestamp,
    bool? isRead,
    String? imageUrl,
    String? fileUrl,
    String? fileName,
    String? fileType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      imageUrl: imageUrl ?? this.imageUrl,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      fileType: fileType ?? this.fileType,
    );
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      text: map['text'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      timestamp: map['timestamp']?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      fileType: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp,
      'isRead': isRead,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'type': fileType,
    };
  }
} 