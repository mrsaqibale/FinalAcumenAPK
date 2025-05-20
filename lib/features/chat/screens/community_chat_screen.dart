import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/chat/widgets/community_chat_app_bar.dart';
import 'package:acumen/features/chat/widgets/community_chat_input.dart';
import 'package:acumen/features/chat/widgets/community_chat_message_list.dart';
import 'package:acumen/features/chat/widgets/community_members_bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  String? currentUserId;
  late MessageController _messageController;
  List<Map<String, dynamic>> _optimisticMessages = [];

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _messageController = MessageController();
    
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

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
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

  Future<void> _sendMessage({String? text, File? mediaFile, String? mediaType, bool isOptimistic = false}) async {
    if (isOptimistic) {
      // Add message to optimistic list
      final optimisticMessage = {
        'id': 'temp_${DateTime.now().millisecondsSinceEpoch}',
        'communityId': widget.communityId,
        'senderId': currentUserId,
        'senderName': Provider.of<AuthController>(context, listen: false).appUser?.name ?? 'Unknown',
        'text': text ?? '',
        'imageUrl': null, // Will be updated when media is uploaded
        'contentType': mediaType ?? (text != null ? 'text' : null),
        'timestamp': Timestamp.now(),
        'type': 'message',
        'isOptimistic': true,
      };
      
      setState(() {
        _optimisticMessages.add(optimisticMessage);
      });

      // Scroll to bottom
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      // Start actual sending process
      _sendMessage(
        text: text,
        mediaFile: mediaFile,
        mediaType: mediaType,
        isOptimistic: false,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      await chatController.sendCommunityMessage(
        communityId: widget.communityId,
        text: text ?? '',
        mediaFile: mediaFile,
        mediaType: mediaType,
      );
      
      // Remove optimistic message after successful send
      if (_optimisticMessages.isNotEmpty) {
        setState(() {
          _optimisticMessages.removeAt(0);
        });
      }
      
      // Scroll to bottom after sending
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      // Remove optimistic message on error
      if (_optimisticMessages.isNotEmpty) {
        setState(() {
          _optimisticMessages.removeAt(0);
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _messageController,
      child: Scaffold(
        appBar: CommunityChatAppBar(
          communityName: widget.communityName,
          imageUrl: widget.imageUrl,
          memberIds: widget.memberIds,
          onMembersPressed: () {
            if (widget.memberIds != null) {
              CommunityMembersBottomSheet.show(context, widget.memberIds!);
            }
          },
        ),
        body: Column(
          children: [
            // Chat messages
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: Provider.of<ChatController>(context).getCommunityMessagesStream(widget.communityId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  // Combine real messages with optimistic messages
                  final realMessages = snapshot.data ?? [];
                  final allMessages = [...realMessages, ..._optimisticMessages];
                  
                  // Sort messages by timestamp
                  allMessages.sort((a, b) {
                    final aTime = (a['timestamp'] as Timestamp).millisecondsSinceEpoch;
                    final bTime = (b['timestamp'] as Timestamp).millisecondsSinceEpoch;
                    return aTime.compareTo(bTime);
                  });

                  if (allMessages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  return CommunityChatMessageList(
                    communityId: widget.communityId,
                    currentUserId: currentUserId,
                    scrollController: _scrollController,
                    messages: allMessages,
                  );
                },
              ),
            ),
            
            // Message input
            CommunityChatInput(
              onSendMessage: _sendMessage,
              isLoading: _isLoading,
              canSendMessages: _canSendMessages(context),
            ),
          ],
        ),
      ),
    );
  }
} 