import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/resources/screens/resource_chat_detail_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';

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
        final messagesSnapshot =
            await FirebaseFirestore.instance
                .collection('chats')
                .doc(conversation.id)
                .collection('messages')
                .where('fileUrl', isNotEqualTo: null)
                .limit(1)
                .get();

        final hasMedia = messagesSnapshot.docs.isNotEmpty;
        print(
          "DEBUG: Conversation ${conversation.id} (${conversation.participantName}): hasMedia = $hasMedia",
        );

        if (hasMedia) {
          print(
            "DEBUG: Found media in conversation with ${conversation.participantName}",
          );
        }

        _conversationsWithMedia[conversation.id] = hasMedia;
      } catch (e) {
        print(
          "DEBUG: Error checking media for conversation ${conversation.id}: $e",
        );
        _conversationsWithMedia[conversation.id] = false;
      }
    }

    print(
      "DEBUG: Final conversations with media: ${_conversationsWithMedia.entries.where((e) => e.value).length}",
    );
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        if (chatController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (chatController.error != null) {
          return Center(child: Text('Error: \\${chatController.error}'));
        }
        final authController = Provider.of<AuthController>(
          context,
          listen: false,
        );
        final currentUserId = authController.currentUser?.uid;
        final soloChats =
            chatController.conversations
                .where(
                  (chat) =>
                      !chat.isGroup && chat.participantId != currentUserId,
                )
                .toList();
        final groupChats =
            chatController.conversations.where((chat) => chat.isGroup).toList();
        if (soloChats.isEmpty && groupChats.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No conversations yet!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the + button below or select a student to start a new chat.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await chatController.reloadConversations();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
              if (groupChats.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Groups',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...groupChats.map((conversation) {
                  final isSelected =
                      widget.selectedConversationId == conversation.id;
                  final isUnread = conversation.hasUnreadMessages;
                  final isOnline = false; // TODO: implement real online logic
                  return InkWell(
                    onLongPress:
                        () => widget.onShowDeleteOptions(
                          conversation.id,
                          conversation,
                        ),
                    child: Container(
                      color:
                          isSelected
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.transparent,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  conversation.isGroup
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
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          conversation.participantName,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'Contains media files',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed:
                              () => widget.onShowDeleteOptions(
                                conversation.id,
                                conversation,
                              ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ResourceChatDetailScreen(
                                    conversationId: conversation.id,
                                    conversationName:
                                        conversation.participantName,
                                    isGroup: conversation.isGroup,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
              if (soloChats.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Direct Messages',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...soloChats.map((conversation) {
                  final isSelected =
                      widget.selectedConversationId == conversation.id;
                  final isUnread = conversation.hasUnreadMessages;
                  final isOnline = false; // TODO: implement real online logic
                  return InkWell(
                    onLongPress:
                        () => widget.onShowDeleteOptions(
                          conversation.id,
                          conversation,
                        ),
                    child: Container(
                      color:
                          isSelected
                              ? Colors.grey.withOpacity(0.1)
                              : Colors.transparent,
                      child: ListTile(
                        leading: Stack(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                                  conversation.isGroup
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
                            if (isOnline)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          conversation.participantName,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          'Contains media files',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed:
                              () =>
                                  widget.onShowSoloChatOptions(conversation.id),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ResourceChatDetailScreen(
                                    conversationId: conversation.id,
                                    conversationName:
                                        conversation.participantName,
                                    isGroup: conversation.isGroup,
                                  ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }).toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}
