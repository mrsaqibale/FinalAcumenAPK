// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatConversationAdapter extends TypeAdapter<ChatConversation> {
  @override
  final int typeId = 2;

  @override
  ChatConversation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatConversation(
      id: fields[0] as String,
      participantId: fields[1] as String,
      participantName: fields[2] as String,
      participantImageUrl: fields[3] as String?,
      lastMessage: fields[4] as String,
      lastMessageTime: fields[5] as DateTime,
      isUnread: fields[6] as bool,
      isGroup: fields[7] as bool,
      isActive: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ChatConversation obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.participantId)
      ..writeByte(2)
      ..write(obj.participantName)
      ..writeByte(3)
      ..write(obj.participantImageUrl)
      ..writeByte(4)
      ..write(obj.lastMessage)
      ..writeByte(5)
      ..write(obj.lastMessageTime)
      ..writeByte(6)
      ..write(obj.isUnread)
      ..writeByte(7)
      ..write(obj.isGroup)
      ..writeByte(8)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatConversationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
