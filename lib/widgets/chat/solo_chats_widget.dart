import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/widgets/chat/chat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/theme/app_theme.dart';

class SoloChatsWidget extends StatefulWidget {
  const SoloChatsWidget({super.key});

  @override
  State<SoloChatsWidget> createState() => _SoloChatsWidgetState();
}

class _SoloChatsWidgetState extends State<SoloChatsWidget> with SingleTickerProviderStateMixin {
  String? selectedConversationId;
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allStudents = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllStudents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllStudents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authController = Provider.of<AuthController>(context, listen: false);
      final students = await authController.getAllStudents();
      
      // Filter out current user
      final currentUserId = authController.currentUser?.uid;
      final filteredStudents = students.where((student) => student['id'] != currentUserId).toList();
      
      setState(() {
        _allStudents = filteredStudents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to load students: $e',
        );
      }
    }
  }

  Future<void> _createNewChat(Map<String, dynamic> student) async {
    final chatController = Provider.of<ChatController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    final currentUser = authController.currentUser;
    
    if (currentUser == null) return;
    
    try {
      setState(() {
        _isLoading = true;
      });
      
      // Create or get existing conversation
      final conversation = await chatController.createOneToOneConversation(
        participantId: student['id'],
        participantName: student['name'],
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (mounted && conversation != null) {
        // Navigate to chat
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              conversationId: conversation.id,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to create chat: $e',
        );
      }
    }
  }

  void _showDeleteOptions(String conversationId) {
    setState(() {
      selectedConversationId = conversationId;
    });

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.grey),
              title: const Text('Archive chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _archiveChat(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined, color: Colors.orange),
              title: const Text('Block contact', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showBlockConfirmation(conversationId);
              },
            ),
          ],
        ),
      ),
    ).then((_) {
      setState(() {
        selectedConversationId = null;
      });
    });
  }

  void _showDeleteConfirmation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this chat?'),
        content: const Text('Messages will be removed from this device only.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final chatController = Provider.of<ChatController>(context, listen: false);
              chatController.deleteConversation(conversationId);
              AppSnackbar.showInfo(
                context: context,
                message: 'Chat deleted',
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _archiveChat(String conversationId) {
    // Implement archive functionality
    AppSnackbar.showInfo(
      context: context,
      message: 'Chat archived',
    );
  }

  void _showBlockConfirmation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block this contact?'),
        content: const Text('Blocked contacts will no longer be able to call you or send you messages.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement block functionality
              AppSnackbar.showInfo(
                context: context,
                message: 'Contact blocked',
              );
            },
            child: const Text('BLOCK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'RECENT CHATS'),
            Tab(text: 'ALL STUDENTS'),
          ],
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicator: const UnderlineTabIndicator(
            borderSide: BorderSide(color: Colors.black, width: 2.0),
            insets: EdgeInsets.symmetric(horizontal: 10.0),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildRecentChats(),
              _buildAllStudents(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentChats() {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        if (chatController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (chatController.error != null) {
          return Center(
            child: Text('Error: ${chatController.error}'),
          );
        }
        
        final soloChats = chatController.conversations.where((chat) => !chat.isGroup).toList();
        
        if (soloChats.isEmpty) {
          return const Center(
            child: Text(
              'No conversations yet.\nTap the + button to start a chat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          itemCount: soloChats.length,
          itemBuilder: (context, index) {
            final conversation = soloChats[index];
            final isSelected = selectedConversationId == conversation.id;
            
            return InkWell(
              onLongPress: () => _showDeleteOptions(conversation.id),
              child: Container(
                color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
                child: ChatCardWidget(
                  conversation: conversation,
                  onTap: () {
                    chatController.markConversationAsRead(conversation.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetailScreen(
                          conversationId: conversation.id,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAllStudents() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_allStudents.isEmpty) {
      return const Center(
        child: Text(
          'No students found.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: _allStudents.length,
      itemBuilder: (context, index) {
        final student = _allStudents[index];
        
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppTheme.primaryColor,
            child: Text(
              student['name'][0].toUpperCase(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text(student['name'] ?? 'Unknown'),
          subtitle: Text(student['rollNumber'] != null && student['rollNumber'].toString().isNotEmpty 
              ? 'Roll: ${student['rollNumber']}' 
              : student['email'] ?? ''),
          trailing: IconButton(
            icon: const Icon(Icons.message, color: AppTheme.primaryColor),
            onPressed: () => _createNewChat(student),
          ),
          onTap: () => _createNewChat(student),
        );
      },
    );
  }
} 