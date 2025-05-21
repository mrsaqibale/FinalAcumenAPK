import 'package:flutter/material.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/resources/widgets/resource_community_chat_list.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';

class ResourceCommunityChatScreen extends StatefulWidget {
  final String communityId;
  final String communityName;
  final List<String> memberIds;
  final String? imageUrl;

  const ResourceCommunityChatScreen({
    Key? key,
    required this.communityId,
    required this.communityName,
    required this.memberIds,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<ResourceCommunityChatScreen> createState() => _ResourceCommunityChatScreenState();
}

class _ResourceCommunityChatScreenState extends State<ResourceCommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isAttaching = false;
  String? _replyToMessageId;
  String? _replyToText;
  String? _replyToSenderName;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatController = Provider.of<ChatController>(context, listen: false);
    final messageController = Provider.of<MessageController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUser = authController.currentUser;

    if (currentUser == null) {
      AppSnackbar.showError(
        context: context,
        message: 'You must be logged in to send messages',
      );
      return;
    }

    try {
      if (_replyToMessageId != null) {
        // Handle reply using MessageController
        await messageController.replyToMessage(
          widget.communityId,
          _replyToMessageId!,
          text,
        );
      } else {
        // Send normal message using ChatController
        await chatController.sendCommunityMessage(
          communityId: widget.communityId,
          text: text,
        );
      }

      _messageController.clear();
      _clearReply();
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to send message: $e',
        );
      }
    }
  }

  void _handleDeleteMessage(String messageId) async {
    final messageController = Provider.of<MessageController>(context, listen: false);
    
    try {
      await messageController.deleteSelectedMessages(widget.communityId);
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to delete message: $e',
        );
      }
    }
  }

  void _handleReplyToMessage(String messageId, String text) {
    setState(() {
      _replyToMessageId = messageId;
      _replyToText = text;
      _replyToSenderName = 'User'; // This should be the actual sender's name
    });
    
    FocusScope.of(context).requestFocus(FocusNode());
  }

  void _handleForwardMessage(String messageId) {
    // Implement forward functionality
    AppSnackbar.showInfo(
      context: context,
      message: 'Forward feature coming soon',
    );
  }

  void _clearReply() {
    setState(() {
      _replyToMessageId = null;
      _replyToText = null;
      _replyToSenderName = null;
    });
  }

  void _handleAttachment() {
    setState(() {
      _isAttaching = true;
    });

    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Image'),
            onTap: () {
              Navigator.pop(context);
              // Implement image attachment
            },
          ),
          ListTile(
            leading: const Icon(Icons.mic),
            title: const Text('Voice Message'),
            onTap: () {
              Navigator.pop(context);
              // Implement voice message
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: const Text('File'),
            onTap: () {
              Navigator.pop(context);
              // Implement file attachment
            },
          ),
        ],
      ),
    ).then((_) {
      setState(() {
        _isAttaching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final currentUserId = authController.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.communityName,
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              '${widget.memberIds.length} members',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              // Show community info
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider<MessageController>(
        create: (_) => MessageController(),
        child: Column(
          children: [
            if (_replyToMessageId != null)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey.shade200,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Replying to $_replyToSenderName',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _replyToText ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _clearReply,
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ResourceCommunityChatList(
                communityId: widget.communityId,
                currentUserId: currentUserId,
                scrollController: _scrollController,
                onDeleteMessage: _handleDeleteMessage,
                onReplyToMessage: _handleReplyToMessage,
                onForwardMessage: _handleForwardMessage,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _isAttaching ? Icons.close : Icons.attach_file,
                      color: _isAttaching ? Colors.red : AppTheme.primaryColor,
                    ),
                    onPressed: _handleAttachment,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: AppTheme.primaryColor),
                    onPressed: _handleSendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 