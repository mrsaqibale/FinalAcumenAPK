import 'dart:async';
import 'dart:io';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/chat_detail_controller.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:acumen/features/chat/widgets/chat_message_item.dart';

// Update the ChatMessage model to support file information
class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final String receiverId;
  final DateTime timestamp;
  final bool isRead;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    required this.receiverId,
    required this.timestamp,
    this.isRead = false,
    this.fileUrl,
    this.fileName,
    this.fileType,
  });
}

class ChatDetailScreen extends StatefulWidget {
  final String conversationId;

  const ChatDetailScreen({super.key, required this.conversationId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Listen for text changes to update the send button
    _messageController.addListener(_onMessageChanged);
  }

  void _onMessageChanged() {
    setState(() {}); // Triggers rebuild for send button state
  }

  Future<void> _pickImage(
    ImageSource source,
    ChatDetailController controller,
  ) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        await controller.uploadFile(
          File(image.path),
          'image',
          image.name,
          context,
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (!mounted) return;
      AppSnackbar.showError(
        context: context,
        message: 'Failed to pick image: [31m${e.toString()}[0m',
      );
    }
  }

  Future<void> _pickFile(ChatDetailController controller) async {
    try {
      print("Opening file picker...");
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Explicitly allow any file type
        allowMultiple: false,
      );
      print("File picker result: $result");

      if (result != null && result.files.single.path != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
        String type = 'file';

        if (mimeType.startsWith('image/')) {
          type = 'image';
        } else if (mimeType.startsWith('video/')) {
          type = 'video';
        } else if (mimeType.startsWith('audio/')) {
          type = 'audio';
        } else if (mimeType == 'application/pdf') {
          type = 'pdf';
        } else if (mimeType.contains('zip') ||
            mimeType.contains('compressed')) {
          type = 'zip';
        }

        // Check file size before uploading (limit to 10MB)
        final fileSize = await file.length();
        if (fileSize > 10 * 1024 * 1024) {
          if (!mounted) return;
          AppSnackbar.showError(
            context: context,
            message: 'File is too large. Maximum size is 10MB.',
          );
          return;
        }

        await controller.uploadFile(file, type, fileName, context);
      } else {
        print("No file selected or file path is null.");
      }
    } catch (e) {
      print("File picker error: $e");
      if (!mounted) return;
      AppSnackbar.showError(
        context: context,
        message: 'Failed to pick file: [31m${e.toString()}[0m',
      );
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onMessageChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final conversation = chatController.getConversation(widget.conversationId);

    if (conversation == null) {
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

    final isGroup = conversation.isGroup;

    return ChangeNotifierProvider<ChatDetailController>(
      create:
          (_) => ChatDetailController(
            conversationId: widget.conversationId,
            authController: Provider.of<AuthController>(context, listen: false),
            chatController: chatController,
          ),
      builder: (context, child) {
        return Consumer<ChatDetailController>(
          builder: (context, controller, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted &&
                  _scrollController.hasClients &&
                  controller.messages.isNotEmpty) {
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            });
            return Scaffold(
              backgroundColor: AppTheme.primaryColor,
              appBar: AppBar(
                backgroundColor: AppTheme.primaryColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    FontAwesomeIcons.angleLeft,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      backgroundImage:
                          !isGroup && conversation.participantImageUrl != null
                              ? NetworkImage(conversation.participantImageUrl!)
                              : null,
                      child:
                          isGroup
                              ? Icon(Icons.groups, color: AppTheme.primaryColor)
                              : (conversation.participantImageUrl == null
                                  ? Text(
                                    conversation.participantName.isNotEmpty
                                        ? conversation.participantName[0]
                                            .toUpperCase()
                                        : '?',
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                  : null),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isGroup
                                    ? conversation.participantName
                                    : conversation.participantName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              if (isGroup)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4.0),
                                  child: Icon(
                                    Icons.groups,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              if (!isGroup && conversation.participantHasVerifiedSkills)
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
                          const SizedBox(height: 2),
                          if (!isGroup)
                            controller.typingUsers.containsKey(
                                      conversation.participantId,
                                    ) &&
                                    controller.typingUsers[conversation
                                            .participantId] ==
                                        true
                                ? const Text(
                                  'Typing...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                )
                                : Text(
                                  controller.onlineUsers[conversation
                                              .participantId] ==
                                          true
                                      ? 'Online'
                                      : 'Offline',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        controller.onlineUsers[conversation
                                                    .participantId] ==
                                                true
                                            ? Colors.green[100]
                                            : Colors.white70,
                                  ),
                                ),
                          if (isGroup)
                            Text(
                              'Group chat',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  if (isGroup)
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        // TODO: Show group members modal
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder:
                            (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isGroup)
                                  ListTile(
                                    leading: const Icon(Icons.person),
                                    title: const Text('View Profile'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // TODO: Navigate to profile screen
                                    },
                                  ),
                                ListTile(
                                  leading: const Icon(Icons.notifications_off),
                                  title: const Text('Mute Notifications'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    // TODO: Implement muting
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    'Clear Chat',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                    controller.clearChat();
                                    AppSnackbar.showSuccess(
                                      context: context,
                                      message: 'Chat cleared successfully',
                                    );
                                  },
                                ),
                              ],
                            ),
                      );
                    },
                  ),
                ],
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
                      child:
                          controller.isLoading && controller.messages.isEmpty
                              ? const Center(child: CircularProgressIndicator())
                              : controller.messages.isEmpty
                              ? const Center(
                                child: Text(
                                  'No messages yet. Start a conversation!',
                                ),
                              )
                              : ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount: controller.messages.length,
                                itemBuilder: (context, index) {
                                  final message = controller.messages[index];
                                  print(
                                    '[UI] Rendering message: id=${message.id}, text="${message.text}", senderId=${message.senderId}, fileType=${message.fileType}',
                                  );
                                  final authController =
                                      Provider.of<AuthController>(
                                        context,
                                        listen: false,
                                      );
                                  final isMine =
                                      message.senderId ==
                                      authController.currentUser?.uid;
                                  final isTempMessage = controller
                                      .tempMessageIds
                                      .containsKey(message.id);
                                  return ChatMessageItem(
                                    message: message,
                                    isMine: isMine,
                                    isTempMessage: isTempMessage,
                                    uploadProgress:
                                        controller.uploadProgress[message.id],
                                    isUploadComplete:
                                        controller.uploadComplete[message.id],
                                  );
                                },
                              ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file),
                          onPressed: () {
                            final controller =
                                Provider.of<ChatDetailController>(
                                  context,
                                  listen: false,
                                );
                            showModalBottomSheet(
                              context: context,
                              builder:
                                  (context) => Wrap(
                                    children: [
                                      ListTile(
                                        leading: const Icon(Icons.photo),
                                        title: const Text('Photo'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(
                                            ImageSource.gallery,
                                            controller,
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(Icons.camera_alt),
                                        title: const Text('Camera'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickImage(
                                            ImageSource.camera,
                                            controller,
                                          );
                                        },
                                      ),
                                      ListTile(
                                        leading: const Icon(
                                          Icons.insert_drive_file,
                                        ),
                                        title: const Text('Document'),
                                        onTap: () {
                                          Navigator.pop(context);
                                          _pickFile(controller);
                                        },
                                      ),
                                    ],
                                  ),
                            );
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[200],
                            ),
                            onChanged: (value) {
                              controller.updateTypingStatus(value.isNotEmpty);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send),
                          color: AppTheme.primaryColor,
                          onPressed:
                              _messageController.text.trim().isNotEmpty
                                  ? () {
                                    if (isGroup) {
                                      chatController.sendCommunityMessage(
                                        communityId: conversation.id,
                                        text: _messageController.text.trim(),
                                      );
                                    } else {
                                      controller.sendMessage(
                                        _messageController.text.trim(),
                                      );
                                    }
                                    _messageController.clear();
                                  }
                                  : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
