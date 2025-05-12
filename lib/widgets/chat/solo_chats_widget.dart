import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/chat/chat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';

class SoloChatsWidget extends StatefulWidget {
  const SoloChatsWidget({super.key});

  @override
  State<SoloChatsWidget> createState() => _SoloChatsWidgetState();
}

class _SoloChatsWidgetState extends State<SoloChatsWidget> {
  String? selectedConversationId;

  void _showDeleteOptions(String conversationId) {
    setState(() {
      selectedConversationId = conversationId;
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.grey),
              title: const Text('Archive chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _archiveChat(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined, color: Colors.orange),
              title: const Text('Block contact', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmation(conversationId);
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        selectedConversationId = null;
      });
    });
  }

  void _showDeleteConfirmation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this chat?'),
        content: const Text('Messages will be removed from this device only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.deleteConversation(conversationId);
              AppSnackbar.showInfo(
                context: context,
                message: 'Chat deleted',
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _archiveChat(String conversationId) {
    // Implement archive functionality
    AppSnackbar.showInfo(
      context: context,
      message: 'Chat archived',
    );
  }

  void _showBlockConfirmation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block this contact?'),
        content: const Text('Blocked contacts will no longer be able to call you or send you messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement block functionality
              AppSnackbar.showInfo(
                context: context,
                message: 'Contact blocked',
              );
            },
            child: const Text('BLOCK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        if (chatController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (chatController.error != null) {
          return Center(
            child: Text('Error: ${chatController.error}'),
          );
        }
        
        final soloChats = chatController.conversations.where((chat) => !chat.isGroup).toList();
        
        if (soloChats.isEmpty) {
          return const Center(
            child: Text(
              'No conversations yet.\nTap the + button to start a chat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: soloChats.length,
          itemBuilder: (context, index) {
            final conversation = soloChats[index];
            final isSelected = selectedConversationId == conversation.id;
            
            return InkWell(
              onLongPress: () => _showDeleteOptions(conversation.id),
              child: Container(
                color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
                child: ChatCardWidget(
                  conversation: conversation,
                  onTap: () {
                    chatController.markConversationAsRead(conversation.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
} 