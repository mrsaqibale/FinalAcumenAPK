import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/message_controller.dart';
import 'package:acumen/features/chat/widgets/message_components.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';

class ResourceCommunityChatList extends StatefulWidget {
  final String communityId;
  final String? currentUserId;
  final ScrollController scrollController;
  final List<Map<String, dynamic>>? messages;
  final Function(String) onDeleteMessage;
  final Function(String, String) onReplyToMessage;
  final Function(String) onForwardMessage;

  const ResourceCommunityChatList({
    Key? key,
    required this.communityId,
    required this.currentUserId,
    required this.scrollController,
    required this.onDeleteMessage,
    required this.onReplyToMessage,
    required this.onForwardMessage,
    this.messages,
  }) : super(key: key);

  @override
  State<ResourceCommunityChatList> createState() => _ResourceCommunityChatListState();
}

class _ResourceCommunityChatListState extends State<ResourceCommunityChatList> {
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
      
      if (contentType == 'voice') {
        return;
      }
      
      if (contentType == 'image' && _messageController.isDownloaded(messageId)) {
        _openImageFullScreen(url);
      }
      
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
            widget.onReplyToMessage(message['id'], message['text'] ?? '');
            break;
          case 'delete':
            if (isCurrentUser) {
              widget.onDeleteMessage(message['id']);
            }
            break;
          case 'copy':
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
            widget.onForwardMessage(message['id']);
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
                widget.onReplyToMessage(messageId, message['text'] ?? '');
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
          if (_canDeleteSelectedMessages())
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                for (final id in _messageController.selectedMessageIds) {
                  widget.onDeleteMessage(id);
                }
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
  
  void _forwardSelectedMessages() {
    for (final id in _messageController.selectedMessageIds) {
      widget.onForwardMessage(id);
    }
    _messageController.clearSelection();
  }

  Widget _buildMessageContent(Map<String, dynamic> message, bool isCurrentUser) {
    final String text = message['text'] as String? ?? '';
    final String? imageUrl = message['imageUrl'] as String?;
    final String contentType = message['contentType'] as String? ?? 'text';
    final String messageId = message['id'] as String;
    final timestamp = message['timestamp'] != null
        ? (message['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    
    final bool isReply = message['type'] == 'reply';
    final bool isForwarded = message['type'] == 'forwarded';
    
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
          
          if (text.isNotEmpty && contentType != 'voice')
            Text(
              text,
              style: TextStyle(
                color: isCurrentUser ? Colors.white : Colors.black87,
                fontSize: 15,
              ),
            ),
          
          if (contentType == 'voice') ...[
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
                  url: imageUrl ?? '',
                  isCurrentUser: isCurrentUser,
                  isPlaying: isPlaying,
                  playbackProgress: playbackProgress,
                  duration: const Duration(seconds: 30),
                  onPlayPause: () => _handleMediaTap(messageId, imageUrl ?? '', contentType),
                  isDownloaded: isDownloaded,
                  isDownloading: isDownloading,
                  downloadProgress: downloadProgress,
                );
              },
            ),
          ]
          else if (imageUrl != null && contentType != 'voice') ...[
            if (text.isNotEmpty) 
              const SizedBox(height: 8),
            
            Consumer<MessageController>(
              builder: (context, controller, child) {
                final isDownloaded = controller.isDownloaded(messageId);
                final isDownloading = controller.isDownloading(messageId);
                final downloadProgress = controller.getDownloadProgress(messageId);
                
                return MessageComponents.mediaDownloadWidget(
                  context: context,
                  url: imageUrl,
                  contentType: contentType,
                  isCurrentUser: isCurrentUser,
                  onTap: () => _handleMediaTap(messageId, imageUrl, contentType),
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
    if (widget.messages != null) {
      _messages = widget.messages!;
      return _buildMessageList();
    }

    return Stack(
      children: [
        StreamBuilder<List<Map<String, dynamic>>>(
          stream: Provider.of<ChatController>(context).getCommunityMediaMessagesStream(widget.communityId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            _messages = snapshot.data ?? [];
            
            if (_messages.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }

            if (_messages.isEmpty) {
              return const Center(child: Text('No media resources found in this chat'));
            }

            return _buildMessageList();
          },
        ),
        
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
            
            return GestureDetector(
              onLongPress: isOptimistic ? null : () => _handleMessageLongPress(messageId),
              onTap: isOptimistic 
                  ? null 
                  : (isSelectionMode ? () => _handleMessageLongPress(messageId) : null),
              child: MessageComponents.selectionOverlay(
                isSelected: isSelected,
                onTap: isOptimistic 
                    ? () {} 
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
                              child: Text(
                                message['senderName'] as String? ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade700,
                                ),
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