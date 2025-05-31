import 'package:acumen/features/profile/models/user_model.dart';
import 'package:acumen/features/profile/screens/mentor_profile_screen.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MentorCardWidget extends StatelessWidget {
  final UserModel mentor;

  const MentorCardWidget({
    Key? key,
    required this.mentor,
  }) : super(key: key);

  Future<void> _startChat(BuildContext context) async {
    if (!mentor.isActive) {
      AppSnackbar.showError(
        context: context,
        message: 'This mentor is currently inactive',
      );
      return;
    }

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final chatController = Provider.of<ChatController>(context, listen: false);
      final conversationId = await chatController.createOrGetDirectChat(mentor.id);
      
      if (!context.mounted) return;
      
      // Remove loading indicator
      Navigator.pop(context);
      
      // Navigate to chat detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatDetailScreen(
            conversationId: conversationId,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Remove loading indicator if it's showing
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      AppSnackbar.showError(
        context: context,
        message: 'Failed to start chat: $e',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        leading: Stack(
          children: [
            CachedProfileImage(
              imageUrl: mentor.photoUrl,
              size: 48,
              radius: 24,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MentorProfileScreen(
                      mentorId: mentor.id,
                ),
              ),
            );
          },
            ),
            if (!mentor.isActive)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
            if (mentor.isActive)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          mentor.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          mentor.title ?? 'Mentor',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () => _startChat(context),
      ),
    );
  }
} 