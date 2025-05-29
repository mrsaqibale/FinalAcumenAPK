import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/widgets/chat/chat_avatar_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';

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
    // Show offline status by default (grey dot)
    final bool isOnline = false;
    final currentUserId =
        Provider.of<AuthController>(context, listen: false).currentUser?.uid;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black12,
      color:
          conversation.hasUnreadMessages ? Colors.blue.shade50 : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 18,
        ),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  conversation.participantImageUrl != null &&
                          conversation.participantImageUrl!.isNotEmpty
                      ? NetworkImage(conversation.participantImageUrl!)
                      : null,
              child:
                  (conversation.participantImageUrl == null ||
                          conversation.participantImageUrl!.isEmpty)
                      ? Text(
                        conversation.participantName.isNotEmpty
                            ? conversation.participantName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 22,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.participantName,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight:
                      conversation.hasUnreadMessages
                          ? FontWeight.bold
                          : FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            if (conversation.participantHasVerifiedSkills)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: Colors.blue,
                  size: 15,
                ),
              ),
          ],
        ),
        subtitle: Row(
          children: [
            if (conversation.isGroup &&
                conversation.lastMessageSenderId != null)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  conversation.lastMessageSenderId == currentUserId
                      ? 'You:'
                      : conversation.lastMessageSenderId ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            if (!conversation.isGroup &&
                conversation.lastMessageSenderId == currentUserId)
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  'You:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            if (conversation.lastMessage.startsWith('[FILE]'))
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(
                  Icons.insert_drive_file,
                  size: 16,
                  color: Colors.blueGrey,
                ),
              ),
            Expanded(
              child: Text(
                conversation.lastMessage.isEmpty
                    ? 'No messages yet'
                    : conversation.lastMessage.startsWith('[FILE]')
                    ? conversation.lastMessage.replaceFirst('[FILE]', '').trim()
                    : conversation.lastMessage,
                style: TextStyle(
                  fontSize: 15,
                  color:
                      conversation.hasUnreadMessages
                          ? Colors.black
                          : Colors.grey[700],
                  fontWeight:
                      conversation.hasUnreadMessages
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              conversation.timeString,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            if (conversation.hasUnreadMessages)
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
