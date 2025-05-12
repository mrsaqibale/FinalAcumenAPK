import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/profile/controllers/user_controller.dart';
import 'package:acumen/widgets/chat/mentor_list_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewChatDialogWidget extends StatelessWidget {
  const NewChatDialogWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    final chatController = Provider.of<ChatController>(context, listen: false);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'New Chat',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select a mentor to start a conversation:',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: userController.mentors.length,
              itemBuilder: (context, index) {
                final mentor = userController.mentors[index];
                return MentorListItemWidget(
                  mentor: mentor,
                  chatController: chatController,
                  parentContext: context,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static void show(BuildContext context) async {
    final userController = Provider.of<UserController>(context, listen: false);
    
    if (userController.mentors.isEmpty) {
      await userController.loadUsersByRole('mentor');
    }
    
    if (!context.mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NewChatDialogWidget(),
    );
  }
} 