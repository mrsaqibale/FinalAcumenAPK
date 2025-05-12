import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/common/custom_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityChatScreen extends StatefulWidget {
  final String communityId;
  final String communityName;
  final List<String>? memberIds;
  final String? imageUrl;

  const CommunityChatScreen({
    Key? key,
    required this.communityId,
    required this.communityName,
    this.memberIds,
    this.imageUrl,
  }) : super(key: key);

  @override
  State<CommunityChatScreen> createState() => _CommunityChatScreenState();
}

class _CommunityChatScreenState extends State<CommunityChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    // Scroll to bottom after messages load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Check if current user is a mentor
  bool _isMentor(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    return authController.appUser?.role == 'mentor';
  }

  // Check if user can send messages in this community
  bool _canSendMessages(BuildContext context) {
    // First check if the user is a mentor
    final isMentor = _isMentor(context);
    
    // If not a mentor, they can't send messages in mentor-only communities
    if (!isMentor) {
      return false;
    }
    
    return true;
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

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      await chatController.sendCommunityMessage(
        communityId: widget.communityId,
        text: text,
      );
      _messageController.clear();
    } catch (e) {
      print('Error sending message: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(widget.imageUrl!),
              )
            else
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Text(
                  widget.communityName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.communityName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.memberIds != null)
                    Text(
                      '${widget.memberIds!.length} members',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group, color: Colors.white),
            onPressed: () {
              // Show community members
              _showCommunityMembers();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: Provider.of<ChatController>(context).getCommunityMessagesStream(widget.communityId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];
                
                // Scroll to bottom when messages update
                if (messages.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                }

                if (messages.isEmpty) {
                  return const Center(child: Text('No messages yet'));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isCurrentUser = message['senderId'] == currentUserId;
                    final timestamp = message['timestamp'] != null
                        ? (message['timestamp'] as Timestamp).toDate()
                        : DateTime.now();
                    final messageType = message['type'] as String? ?? 'message';
                    
                    // For system messages (like welcome message)
                    if (messageType == 'system') {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message['text'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    }
                    
                    // Regular message bubbles
                    return Align(
                      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        child: Column(
                          crossAxisAlignment: isCurrentUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!isCurrentUser)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, bottom: 4),
                                child: Text(
                                  message['senderName'] as String? ?? 'Unknown',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? AppTheme.primaryColor
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message['text'] as String,
                                    style: TextStyle(
                                      color: isCurrentUser ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('h:mm a').format(timestamp),
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isCurrentUser
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // Message input - only show for mentors
          if (_canSendMessages(context))
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      minLines: 1,
                      maxLines: 5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Material(
                    color: AppTheme.primaryColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      onTap: _isLoading ? null : _sendMessage,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 24,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Show message for students that only mentors can send messages
          if (!_canSendMessages(context))
            Container(
              padding: const EdgeInsets.all(12),
              alignment: Alignment.center,
              color: Colors.grey.shade100,
              child: const Text(
                'Only mentors can send messages in this community',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showCommunityMembers() async {
    if (widget.memberIds == null || widget.memberIds!.isEmpty) return;
    
    final authController = Provider.of<AuthController>(context, listen: false);
    final members = await authController.getUsersByIds(widget.memberIds!);
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Community Members (${members.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                        child: Text(
                          (member['name'] as String).substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(member['name'] as String),
                      subtitle: Text(member['role'] as String),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
} 