import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/chat/widgets/message_components.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/cached_profile_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CommunityChatMessageList extends StatefulWidget {
  final String communityId;
  final String? currentUserId;
  final ScrollController scrollController;
  final List<Map<String, dynamic>>? messages;

  const CommunityChatMessageList({
    Key? key,
    required this.communityId,
    required this.currentUserId,
    required this.scrollController,
    this.messages,
  }) : super(key: key);

  @override
  State<CommunityChatMessageList> createState() => _CommunityChatMessageListState();
}

class _CommunityChatMessageListState extends State<CommunityChatMessageList> {
  late MessageController _messageController;
  List<Map<String, dynamic>> _messages = [];
  
  @override
  void initState() {
    super.initState();
    _messageController = Provider.of<MessageController>(context, listen: false);
  }
  
  void _scrollToBottom() {
    if (widget.scrollController.hasClients) {
      widget.scrollController.animateTo(
        widget.scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  
  void _handleMediaTap(String messageId, String url, String contentType) async {
    try {
      await _messageController.openMedia(messageId, url, contentType);
      
      // If it's a voice message, the controller handles playback
      if (contentType == 'voice') {
        return;
      }
      
      // For images, open fullscreen view
      if (contentType == 'image' && _messageController.isDownloaded(messageId)) {
        _openImageFullScreen(url);
      }
      
      // For other file types, launch URL
      if (contentType != 'image' && contentType != 'voice' && _messageController.isDownloaded(messageId)) {
        final Uri uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open this file')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
  
  void _openImageFullScreen(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          backgroundColor: Colors.black,
          body: Center(
            child: PhotoView(
              imageProvider: CachedNetworkImageProvider(url),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleMessageLongPress(String messageId) {
    _messageController.toggleMessageSelection(messageId);
    HapticFeedback.mediumImpact();
  }
  
  void _handleMessageOptionsPressed(Map<String, dynamic> message) {
    final bool isCurrentUser = message['senderId'] == widget.currentUserId;
    
    MessageComponents.showMessageOptions(
      context: context,
      message: message,
      isCurrentUser: isCurrentUser,
      onAction: (action) async {
        switch (action) {
          case 'reply':
            // Show reply dialog
            _showReplyDialog(message);
            break;
          case 'delete':
            if (isCurrentUser) {
              // Show delete confirmation
              _showDeleteConfirmation([message['id']]);
            }
            break;
          case 'copy':
            // Copy message text
            if (message['text'] != null && message['text'].isNotEmpty) {
              await Clipboard.setData(ClipboardData(text: message['text']));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message copied to clipboard')),
                );
              }
            }
            break;
          case 'forward':
            // Show forward dialog
            _showForwardDialog(message);
            break;
        }
      },
    );
  }
  
  void _handleSelectedMessagesAction() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copy'),
            onTap: () {
              Navigator.pop(context);
              _copySelectedMessages();
            },
          ),
          if (_messageController.selectedMessageIds.length == 1)
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                final messageId = _messageController.selectedMessageIds.first;
                final message = _messages.firstWhere((m) => m['id'] == messageId);
                _showReplyDialog(message);
              },
            ),
          ListTile(
            leading: const Icon(Icons.forward),
            title: const Text('Forward'),
            onTap: () {
              Navigator.pop(context);
              _forwardSelectedMessages();
            },
          ),
          // Only show delete if all selected messages are from current user
          if (_canDeleteSelectedMessages())
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(_messageController.selectedMessageIds);
              },
            ),
        ],
      ),
    );
  }
  
  bool _canDeleteSelectedMessages() {
    final selectedIds = _messageController.selectedMessageIds;
    for (final id in selectedIds) {
      final message = _messages.firstWhere((m) => m['id'] == id, orElse: () => {'senderId': ''});
      if (message['senderId'] != widget.currentUserId) {
        return false;
      }
    }
    return true;
  }
  
  void _copySelectedMessages() async {
    final textList = _messageController.getSelectedMessagesText(_messages);
    if (textList.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: textList.join('\n\n')));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Messages copied to clipboard')),
        );
      }
    }
    _messageController.clearSelection();
  }
  
  void _showReplyDialog(Map<String, dynamic> message) {
    final TextEditingController replyController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message['senderName'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message['text'] ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                hintText: 'Type your reply...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final text = replyController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                try {
                  await _messageController.replyToMessage(
                    widget.communityId,
                    message['id'],
                    text,
                  );
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error sending reply: $e')),
                    );
                  }
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteConfirmation(List<String> messageIds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
          messageIds.length == 1
              ? 'Are you sure you want to delete this message?'
              : 'Are you sure you want to delete ${messageIds.length} messages?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _messageController.deleteSelectedMessages(widget.communityId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message(s) deleted')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting message(s): $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  void _showForwardDialog(Map<String, dynamic> message) {
    // This would typically show a list of communities to forward to
    // For simplicity, we'll just show a snackbar
    _messageController.clearSelection();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Forward feature coming soon')),
      );
    }
  }
  
  void _forwardSelectedMessages() {
    // This would typically show a list of communities to forward to
    // For simplicity, we'll just show a snackbar
    _messageController.clearSelection();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Forward feature coming soon')),
      );
    }
  }

  Widget _buildMessageContent(Map<String, dynamic> message, bool isCurrentUser) {
    final String text = message['text'] as String? ?? '';
    final String? imageUrl = message['imageUrl'] as String?;
    final String? fileUrl = message['fileUrl'] as String?;
    final String contentType = message['contentType'] as String? ?? 'text';
    final String? fileType = message['fileType'] as String?;
    final String messageId = message['id'] as String;
    final bool isOptimistic = message['isOptimistic'] == true;
    final bool isUploading = message['isUploading'] == true;
    final String? error = message['error'] as String?;
    final bool hasVerifiedSkills = message['senderHasVerifiedSkills'] == true;
    
    // Handle timestamp with fallbacks
    DateTime timestamp;
    try {
      if (message['timestamp'] != null) {
        if (message['timestamp'] is Timestamp) {
          timestamp = (message['timestamp'] as Timestamp).toDate();
        } else if (message['timestamp'] is FieldValue) {
          // If it's a server timestamp that hasn't been resolved yet
          timestamp = DateTime.now();
        } else {
          timestamp = DateTime.now();
        }
      } else if (message['createdAt'] != null) {
        // Try backup timestamp field
        if (message['createdAt'] is Timestamp) {
          timestamp = (message['createdAt'] as Timestamp).toDate();
        } else {
          timestamp = DateTime.now();
        }
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      print("DEBUG: Error parsing timestamp for message $messageId: $e");
      timestamp = DateTime.now();
    }
    
    // Use fileUrl as a fallback if imageUrl is null
    final String? effectiveImageUrl = imageUrl ?? fileUrl;
    final String effectiveContentType = contentType ?? fileType ?? 'text';
    
    // If message has a reply reference
    final bool isReply = message['type'] == 'reply';
    final bool isForwarded = message['type'] == 'forwarded';
    
    // Show error state if there's an error
    if (error != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Failed to send message',
              style: TextStyle(color: Colors.red.shade900),
            ),
            if (text.isNotEmpty) Text(text),
            Text(
              DateFormat('h:mm a').format(timestamp),
              style: TextStyle(
                fontSize: 10,
                color: Colors.red.shade900.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }
    
    // Show uploading state
    if (isOptimistic && isUploading) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isCurrentUser
              ? AppTheme.primaryColor.withOpacity(0.7)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (text.isNotEmpty) Text(
              text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCurrentUser ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Uploading...',
                  style: TextStyle(
                    fontSize: 12,
                    color: isCurrentUser ? Colors.white70 : Colors.grey.shade700,
                  ),
                ),
              ],
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
      );
    }
    
    // Regular message content
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppTheme.primaryColor
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show reply info
          if (isReply) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reply to ${message['replyToSenderName'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white.withOpacity(0.9) : Colors.black87,
                    ),
                  ),
                  Text(
                    message['replyToText'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white.withOpacity(0.7) : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
          
          // Show forwarded info
          if (isForwarded) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.forward,
                    size: 14,
                    color: isCurrentUser ? Colors.white.withOpacity(0.7) : Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Forwarded from ${message['forwardedFromName'] ?? 'Unknown'}',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: isCurrentUser ? Colors.white.withOpacity(0.7) : Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Regular text message
          if (text.isNotEmpty && effectiveContentType != 'voice')
            Text(
              text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          
          // Voice message
          if (effectiveContentType == 'voice') ...[
            Consumer<MessageController>(
              builder: (context, controller, child) {
                final isDownloaded = controller.isDownloaded(messageId);
                final isDownloading = controller.isDownloading(messageId);
                final downloadProgress = controller.getDownloadProgress(messageId);
                final isPlaying = controller.isPlaying(messageId);
                final playbackProgress = messageId == controller.currentlyPlayingId
                    ? controller.playbackProgress
                    : 0.0;
                
                return MessageComponents.voiceMessageWidget(
                  context: context,
                  url: effectiveImageUrl ?? '',
                  isCurrentUser: isCurrentUser,
                  isPlaying: isPlaying,
                  playbackProgress: playbackProgress,
                  duration: const Duration(seconds: 30), // Placeholder, should come from message
                  onPlayPause: () => _handleMediaTap(messageId, effectiveImageUrl ?? '', effectiveContentType),
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  downloadProgress: downloadProgress,
                );
              },
            ),
          ]
          
          // Images, videos, documents
          else if (effectiveImageUrl != null && effectiveContentType != 'voice') ...[
            if (text.isNotEmpty) 
              const SizedBox(height: 8),
            
            Consumer<MessageController>(
              builder: (context, controller, child) {
                final isDownloaded = controller.isDownloaded(messageId);
                final isDownloading = controller.isDownloading(messageId);
                final downloadProgress = controller.getDownloadProgress(messageId);
                
                return MessageComponents.mediaDownloadWidget(
                  context: context,
                  url: effectiveImageUrl,
                  contentType: effectiveContentType,
                  isCurrentUser: isCurrentUser,
                  onTap: () => _handleMediaTap(messageId, effectiveImageUrl, effectiveContentType),
                  fileName: message['fileName'] as String?,
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  downloadProgress: downloadProgress,
                );
              },
            ),
          ],
          
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
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use provided messages if available, otherwise use stream
    if (widget.messages != null) {
      _messages = widget.messages!.map((message) {
        // Ensure each message has a valid timestamp
        if (message['timestamp'] == null && message['createdAt'] == null) {
          return {
            ...message,
            'timestamp': Timestamp.now(),
          };
        }
        return message;
      }).toList();
      
      return _buildMessageList();
    }

    return Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: Provider.of<ChatController>(context).getCommunityMessagesStream(widget.communityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Ensure all messages have valid timestamps
            _messages = (snapshot.data ?? []).map((message) {
              if (message['timestamp'] == null && message['createdAt'] == null) {
                return {
                  ...message,
                  'timestamp': Timestamp.now(),
                };
              }
              return message;
            }).toList();
            
            // Scroll to bottom when messages update
            if (_messages.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            if (_messages.isEmpty) {
              return const Center(child: Text('No messages yet'));
            }

            return _buildMessageList();
          },
        ),
        
        // Selection mode actions
        Consumer<MessageController>(
          builder: (context, controller, child) {
            if (controller.isSelectionMode) {
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: controller.clearSelection,
                      ),
                      Text(
                        '${controller.selectedMessageIds.length} selected',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: _handleSelectedMessagesAction,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildMessageList() {
    return Consumer<MessageController>(
      builder: (context, messageController, child) {
        final isSelectionMode = messageController.isSelectionMode;
        
        return ListView.builder(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: _messages.length,
          itemBuilder: (context, index) {
            final message = _messages[index];
            final isCurrentUser = message['senderId'] == widget.currentUserId;
            final messageType = message['type'] as String? ?? 'message';
            final messageId = message['id'] as String;
            final isSelected = messageController.isSelected(messageId);
            final isOptimistic = message['isOptimistic'] == true;
            
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
            return GestureDetector(
              onLongPress: isOptimistic ? null : () => _handleMessageLongPress(messageId),
              onTap: isOptimistic 
                  ? null 
                  : (isSelectionMode ? () => _handleMessageLongPress(messageId) : null),
              child: MessageComponents.selectionOverlay(
                isSelected: isSelected,
                onTap: isOptimistic 
                    ? () {} // Empty callback for optimistic messages
                    : () => _handleMessageLongPress(messageId),
                child: Opacity(
                  opacity: isOptimistic ? 0.7 : 1.0,
                  child: Align(
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CachedProfileImage(
                                    imageUrl: message['senderImageUrl'],
                                    size: 32,
                                    radius: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    message['senderName'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
                                  ),
                                  if (message['senderHasVerifiedSkills'] == true)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4.0),
                                      child: Icon(
                                        FontAwesomeIcons.solidCircleCheck,
                                        color: Colors.blue,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          GestureDetector(
                            onLongPress: isOptimistic 
                                ? null 
                                : () => _handleMessageLongPress(messageId),
                            onTap: isOptimistic 
                                ? null 
                                : (isSelectionMode ? () => _handleMessageLongPress(messageId) : null),
                            child: _buildMessageContent(message, isCurrentUser),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
} 
 
 