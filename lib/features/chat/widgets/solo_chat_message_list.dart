import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/chat/widgets/message_components.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SoloChatMessageList extends StatefulWidget {
  final String conversationId;
  final String? currentUserId;
  final ScrollController scrollController;
  final List<Map<String, dynamic>>? messages;
  final Function(String) onDeleteMessage;
  final Function(String, String) onReplyToMessage;
  final Function(String) onForwardMessage;

  const SoloChatMessageList({
    Key? key,
    required this.conversationId,
    required this.currentUserId,
    required this.scrollController,
    required this.onDeleteMessage,
    required this.onReplyToMessage,
    required this.onForwardMessage,
    this.messages,
  }) : super(key: key);

  @override
  State<SoloChatMessageList> createState() => _SoloChatMessageListState();
}

class _SoloChatMessageListState extends State<SoloChatMessageList> {
  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCurrentUser = message['senderId'] == widget.currentUserId;
    final hasVerifiedSkills = message['senderHasVerifiedSkills'] == true;

    return Container(
      margin: EdgeInsets.only(
        left: isCurrentUser ? 64 : 0,
        right: isCurrentUser ? 0 : 64,
        bottom: 8,
      ),
      child: Column(
        crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCurrentUser) ...[
                CachedProfileImage(
                  imageUrl: message['senderImageUrl'],
                  size: 32,
                  radius: 16,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                message['senderName'] ?? 'Unknown',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
              if (hasVerifiedSkills)
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
          const SizedBox(height: 4),
          // ... rest of the message bubble code ...
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: widget.messages?.length ?? 0,
      itemBuilder: (context, index) {
        final message = widget.messages![index];
        return _buildMessageBubble(message);
      },
    );
  }
} 