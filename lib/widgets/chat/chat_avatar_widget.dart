import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:flutter/material.dart';

class ChatAvatarWidget extends StatelessWidget {
  final ChatConversation conversation;
  final double size;
  final double radius;

  const ChatAvatarWidget({
    super.key,
    required this.conversation,
    this.size = 48,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (conversation.isGroup) {
      return CircleAvatar(
        backgroundColor: Colors.grey[400],
        radius: radius,
        child: Icon(
          Icons.group,
          color: Colors.white,
          size: size * 0.625, // 30/48 ratio from original
        ),
      );
    } else {
      return CachedProfileImage(
        imageUrl: conversation.participantImageUrl,
        size: size,
        radius: radius,
        placeholderColor: AppTheme.primaryColor,
        backgroundColor: Colors.grey[300]!,
      );
    }
  }
} 