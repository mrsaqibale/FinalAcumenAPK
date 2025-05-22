import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/widgets/chat/chat_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatCardWidget extends StatelessWidget {
  final ChatConversation conversation;
  final VoidCallback onTap;

  const ChatCardWidget({
    super.key,
    required this.conversation,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shadowColor: Colors.black12,
      color: conversation.hasUnreadMessages ? Colors.blue.shade50 : Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: ChatAvatarWidget(conversation: conversation),
        title: Row(
          children: [
            Expanded(
              child: Text(
          conversation.participantName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
              ),
            ),
            if (conversation.participantHasVerifiedSkills)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: Colors.blue,
                  size: 14,
                ),
              ),
          ],
        ),
        subtitle: Text(
          conversation.lastMessage.isEmpty ? 'Start a conversation' : conversation.lastMessage,
          style: TextStyle(
            fontSize: 14,
            color: conversation.hasUnreadMessages ? Colors.black : Colors.grey,
            fontWeight: conversation.hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          conversation.timeString,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
} 