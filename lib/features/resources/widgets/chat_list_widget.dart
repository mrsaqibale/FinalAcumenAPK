import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/resources/screens/resource_chat_detail_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListWidget extends StatefulWidget {
  final String? selectedConversationId;
  final Function(String) onShowSoloChatOptions;
  final Function(String, ChatConversation) onShowDeleteOptions;

  const ChatListWidget({
    super.key,
    this.selectedConversationId,
    required this.onShowSoloChatOptions,
    required this.onShowDeleteOptions,
  });

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  // Track conversations with media content
  Map<String, bool> _conversationsWithMedia = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkConversationsForMedia();
  }

  Future<void> _checkConversationsForMedia() async {
    setState(() {
      _isLoading = true;
    });

    final chatController = Provider.of<ChatController>(context, listen: false);
    final conversations = chatController.conversations;
    print("DEBUG: Checking ${conversations.length} conversations for media");

    for (final conversation in conversations) {
      try {
        // Get messages directly from Firestore to check for media
        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(conversation.id)
            .collection('messages')
            .where('fileUrl', isNotEqualTo: null)
            .limit(1)
            .get();

        final hasMedia = messagesSnapshot.docs.isNotEmpty;
        print("DEBUG: Conversation ${conversation.id} (${conversation.participantName}): hasMedia = $hasMedia");
        
        if (hasMedia) {
          print("DEBUG: Found media in conversation with ${conversation.participantName}");
        }

        _conversationsWithMedia[conversation.id] = hasMedia;
      } catch (e) {
        print("DEBUG: Error checking media for conversation ${conversation.id}: $e");
        _conversationsWithMedia[conversation.id] = false;
      }
    }

    print("DEBUG: Final conversations with media: ${_conversationsWithMedia.entries.where((e) => e.value).length}");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        final conversations = chatController.conversations;
        
        if (chatController.isLoading || _isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        print("DEBUG: Building chat list with ${conversations.length} total conversations");
        
        // Filter to only show conversations with media
        final conversationsWithMedia = conversations.where(
          (conversation) => _conversationsWithMedia[conversation.id] == true
        ).toList();

        print("DEBUG: Found ${conversationsWithMedia.length} conversations with media");

        if (conversationsWithMedia.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.image_not_supported,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No media resources found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Chats containing photos, videos, or files will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: conversationsWithMedia.length,
          itemBuilder: (context, index) {
            final conversation = conversationsWithMedia[index];
            final isSelected = conversation.id == widget.selectedConversationId;
            
            return ListTile(
              selected: isSelected,
              selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
              leading: CircleAvatar(
                backgroundColor: conversation.isGroup 
                    ? Colors.orange 
                    : AppTheme.primaryColor,
                child: Stack(
                  children: [
                    Icon(
                      conversation.isGroup 
                          ? Icons.group 
                          : Icons.person,
                      color: Colors.white,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.attach_file, 
                          size: 10, 
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              title: Text(
                conversation.participantName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Contains media files',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: conversation.isGroup
                  ? IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => widget.onShowDeleteOptions(
                        conversation.id,
                        conversation,
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => widget.onShowSoloChatOptions(conversation.id),
                    ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResourceChatDetailScreen(
                      conversationId: conversation.id,
                      conversationName: conversation.participantName,
                      isGroup: conversation.isGroup,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
} 