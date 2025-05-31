import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/profile/screens/mentor_profile_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {
  final ChatConversation conversation;
  final VoidCallback onBackPressed;

  const ChatHeader({
    super.key,
    required this.conversation,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryColor,
      elevation: 0,
      centerTitle: true,
      title: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MentorProfileScreen(
                mentorId: conversation.participantId,
              ),
            ),
          );
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedProfileImage(
              imageUrl: conversation.participantImageUrl,
              size: 36,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conversation.participantName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
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
                const Text(
                  'Online',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
        onPressed: onBackPressed,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
} 