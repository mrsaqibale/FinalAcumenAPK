import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:flutter/material.dart';

class ChatMessageBubbleWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageBubbleWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isMine = message.isMine;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMine) 
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CachedProfileImage(
                imageUrl: null, // We don't have this in the message model
                size: 32,
                radius: 16,
                placeholderColor: AppTheme.primaryColor,
              ),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isMine ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isMine ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.timeString,
                        style: TextStyle(
                          fontSize: 12,
                          color: isMine ? Colors.white.withAlpha(179) : Colors.grey,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 4),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: Colors.white.withAlpha(179),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 