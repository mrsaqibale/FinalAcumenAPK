import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/chat/services/chat_service.dart';
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
  bool _isFirstLoad = true;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _messageController = MessageController();
    
    // Schedule a post-frame callback to scroll to bottom after initial render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
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
      // Create a timestamp for the optimistic message
      final now = DateTime.now();
      final optimisticTimestamp = Timestamp.fromDate(now);
      
      // Add message to optimistic list with proper initial values
      final optimisticMessage = {
        'id': 'temp_${now.millisecondsSinceEpoch}',
        'communityId': widget.communityId,
        'senderId': currentUserId,
        'senderName': Provider.of<AuthController>(context, listen: false).appUser?.name ?? 'Unknown',
        'text': text ?? '',
        'imageUrl': null,
        'fileUrl': null,
        'contentType': mediaType ?? (text != null ? 'text' : 'document'),
        'fileType': mediaType ?? 'document',
        'timestamp': optimisticTimestamp,
        'createdAt': optimisticTimestamp,
        'type': 'message',
        'isOptimistic': true,
        'isUploading': true,
      };
      
      setState(() {
        _optimisticMessages.add(optimisticMessage);
      });

      // Scroll to bottom after adding optimistic message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      // Start actual sending process
      await _sendMessage(
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
      String? fileUrl;
      
      // Upload media file if present
      if (mediaFile != null) {
        // Update optimistic message to show upload in progress
        if (_optimisticMessages.isNotEmpty) {
          setState(() {
            final optimisticMessage = _optimisticMessages.first;
            optimisticMessage['isUploading'] = true;
          });
        }

        fileUrl = await ChatService.uploadMediaFile(
          file: mediaFile,
          path: 'communities/${widget.communityId}/media',
        );

        // Update optimistic message with file URL
        if (_optimisticMessages.isNotEmpty) {
          setState(() {
            final optimisticMessage = _optimisticMessages.first;
            optimisticMessage['fileUrl'] = fileUrl;
            optimisticMessage['imageUrl'] = fileUrl;
            optimisticMessage['isUploading'] = false;
          });
        }
      }

      // Send the message with the uploaded file URL
      await chatController.sendCommunityMessage(
        communityId: widget.communityId,
        text: text ?? '',
        fileUrl: fileUrl,
        fileType: mediaType,
      );
      
      // Remove optimistic message after successful send
      if (_optimisticMessages.isNotEmpty) {
        setState(() {
          _optimisticMessages.removeAt(0);
        });
      }
      
      // Scroll to bottom again after sending the real message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      // Update optimistic message to show error
      if (_optimisticMessages.isNotEmpty) {
        setState(() {
          final optimisticMessage = _optimisticMessages.first;
          optimisticMessage['error'] = e.toString();
          optimisticMessage['isUploading'] = false;
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
                  
                  // Sort messages by timestamp with null safety
                  allMessages.sort((a, b) {
                    // Helper function to safely get timestamp
                    DateTime getMessageTime(Map<String, dynamic> message) {
                      try {
                        if (message['timestamp'] != null) {
                          if (message['timestamp'] is Timestamp) {
                            return (message['timestamp'] as Timestamp).toDate();
                          }
                          if (message['timestamp'] is FieldValue) {
                            return DateTime.now();
                          }
                        }
                        if (message['createdAt'] != null && message['createdAt'] is Timestamp) {
                          return (message['createdAt'] as Timestamp).toDate();
                        }
                        // For optimistic messages or messages without timestamp
                        if (message['isOptimistic'] == true) {
                          return DateTime.now();
                        }
                        return DateTime.now();
                      } catch (e) {
                        print("DEBUG: Error getting message time: $e");
                        return DateTime.now();
                      }
                    }

                    final aTime = getMessageTime(a);
                    final bTime = getMessageTime(b);
                    return aTime.compareTo(bTime);
                  });

                  if (allMessages.isEmpty) {
                    return const Center(child: Text('No messages yet'));
                  }

                  // Scroll to bottom on first load or when new messages arrive
                  if (_isFirstLoad || realMessages.length > 0) {
                    _isFirstLoad = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom();
                    });
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