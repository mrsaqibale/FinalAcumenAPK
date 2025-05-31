import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MentorListItemWidget extends StatelessWidget {
  final UserModel mentor;
  final ChatController chatController;
  final BuildContext parentContext;

  const MentorListItemWidget({
    super.key,
    required this.mentor,
    required this.chatController,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CachedProfileImage(
        imageUrl: mentor.photoUrl,
        size: 40,
        radius: 20,
        placeholderColor: AppTheme.primaryColor,
        backgroundColor: Colors.grey[300]!,
      ),
      title: Row(
        children: [
          Text(mentor.name),
          if (mentor.hasVerifiedSkills == true)
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
      subtitle: Text(mentor.title ?? 'Mentor'),
      onTap: () async {
        final conversation = await chatController.createConversation(
          participantId: mentor.id,
          participantName: mentor.name,
          participantImageUrl: mentor.photoUrl,
        );
        
        if (!context.mounted) return;
        
        Navigator.pop(context);
        
        Navigator.push(
          parentContext,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationId: conversation.id,
            ),
          ),
        );
      },
    );
  }
} 