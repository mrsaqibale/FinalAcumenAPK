import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/controllers/chat_detail_controller.dart';
import 'package:acumen/features/chat/models/chat_message_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceChatDetailScreen extends StatefulWidget {
  final String conversationId;
  final String conversationName;
  final bool isGroup;

  const ResourceChatDetailScreen({
    super.key,
    required this.conversationId,
    required this.conversationName,
    this.isGroup = false,
  });

  @override
  State<ResourceChatDetailScreen> createState() => _ResourceChatDetailScreenState();
}

class _ResourceChatDetailScreenState extends State<ResourceChatDetailScreen> {
  late ChatDetailController _chatDetailController;
  bool _isLoading = true;
  List<ChatMessage> _mediaMessages = [];

  @override
  void initState() {
    super.initState();
    _initializeController();
    _loadMediaMessages();
  }

  void _initializeController() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);
    
    _chatDetailController = ChatDetailController(
      conversationId: widget.conversationId,
      authController: authController,
      chatController: chatController,
    );
  }

  Future<void> _loadMediaMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.conversationId)
          .collection('messages')
          .where('fileUrl', isNotEqualTo: null)
          .orderBy('timestamp', descending: true)
          .get();

      _mediaMessages = messagesSnapshot.docs.map((doc) {
        final data = doc.data();
        return ChatMessage(
          id: doc.id,
          text: data['text'] ?? '',
          senderId: data['senderId'] ?? '',
          receiverId: data['receiverId'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
          fileUrl: data['fileUrl'],
          fileName: data['fileName'],
          fileType: data['type'],
        );
      }).toList();

      print("DEBUG: Loaded ${_mediaMessages.length} media messages");
    } catch (e) {
      print("DEBUG: Error loading media messages: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openFile(String url, String fileName, String fileType) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open file')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening file: $e')),
        );
      }
    }
  }

  Widget _buildMediaPreview(ChatMessage message) {
    if (message.fileUrl == null) return const SizedBox.shrink();

    final fileType = message.fileType?.toLowerCase() ?? '';
    final fileName = message.fileName ?? 'Unknown file';

    if (fileType.contains('image')) {
      return GestureDetector(
        onTap: () => _openFile(message.fileUrl!, fileName, fileType),
        child: Container(
          height: 200,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: NetworkImage(message.fileUrl!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    // For other file types, show a file card
    IconData fileIcon;
    Color fileColor;

    switch (fileType) {
      case 'pdf':
        fileIcon = Icons.picture_as_pdf;
        fileColor = Colors.red;
        break;
      case 'doc':
      case 'docx':
        fileIcon = Icons.description;
        fileColor = Colors.blue;
        break;
      case 'xls':
      case 'xlsx':
        fileIcon = Icons.table_chart;
        fileColor = Colors.green;
        break;
      case 'ppt':
      case 'pptx':
        fileIcon = Icons.slideshow;
        fileColor = Colors.orange;
        break;
      case 'zip':
        fileIcon = Icons.archive;
        fileColor = Colors.purple;
        break;
      default:
        fileIcon = Icons.insert_drive_file;
        fileColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(fileIcon, color: fileColor, size: 32),
        title: Text(
          fileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Sent on ${message.timestamp.toString().split('.')[0]}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => _openFile(message.fileUrl!, fileName, fileType),
        ),
        onTap: () => _openFile(message.fileUrl!, fileName, fileType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.conversationName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadMediaMessages,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _mediaMessages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_not_supported,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No media resources found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Media files shared in this chat will appear here',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _mediaMessages.length,
                    itemBuilder: (context, index) {
                      final message = _mediaMessages[index];
                      return _buildMediaPreview(message);
                    },
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _chatDetailController.dispose();
    super.dispose();
  }
} 