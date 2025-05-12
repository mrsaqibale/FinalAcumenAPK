import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/features/profile/screens/mentor_profile_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:acumen/widgets/chat/chat_message_bubble_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      final messages = await chatController.getMessages(widget.conversationId);
      
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        
        // Scroll to bottom after messages load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        AppSnackbar.showError(
          context: context,
          message: 'Error loading messages: $e',
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      await chatController.sendMessage(
        conversationId: widget.conversationId,
        text: text,
      );
      
      // Reload messages
      final messages = await chatController.getMessages(widget.conversationId);
      
      if (mounted) {
        setState(() {
          _messages = messages;
        });
        
        // Scroll to bottom
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Error sending message: $e',
        );
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final conversation = chatController.getConversation(widget.conversationId);
    
    if (conversation == null) {
      // Handle case where conversation doesn't exist
      return Scaffold(
        backgroundColor: AppTheme.primaryColor,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: Text(
            'Conversation not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                  ? const Center(child: Text('No messages yet. Start a conversation!'))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        return ChatMessageBubbleWidget(message: message);
                      },
                    ),
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 
