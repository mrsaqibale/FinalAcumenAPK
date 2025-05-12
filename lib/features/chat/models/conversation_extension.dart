import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';

extension ConversationExtensions on ChatConversation {
  ConversationModel toConversationModel() {
    return ConversationModel(
      id: id,
      name: participantName,
      members: [participantId],
      createdBy: '', // Set a default value
      createdAt: DateTime.now(),
      lastMessageAt: lastMessageTime,
      isGroup: isGroup,
      unreadCount: hasUnreadMessages ? 1 : 0,
      lastMessage: lastMessage,
    );
  }
}

extension ConversationListExtensions on List<ChatConversation> {
  List<ConversationModel> toConversationModels() {
    return map((chat) => chat.toConversationModel()).toList();
  }
}

extension ConversationModelExtensions on ConversationModel {
  ChatConversation toChatConversation() {
    return ChatConversation(
      id: id,
      participantId: members.isNotEmpty ? members.first : '',
      participantName: name,
      lastMessage: lastMessage ?? '',
      lastMessageTime: lastMessageAt,
      hasUnreadMessages: unreadCount > 0,
      isGroup: true,
    );
  }
}

extension ConversationModelListExtensions on List<ConversationModel> {
  List<ChatConversation> toChatConversations() {
    return map((model) => model.toChatConversation()).toList();
  }
} 