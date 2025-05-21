import 'package:flutter/material.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/chat_conversation_model.dart';
import 'package:acumen/features/chat/models/conversation_extension.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/features/resources/widgets/resource_community_chat_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/features/resources/widgets/chat_list_widget.dart';
import 'package:acumen/features/resources/widgets/student_list_widget.dart';
import 'package:acumen/features/resources/controllers/resources_tab_controller.dart';
import 'package:acumen/features/resources/widgets/chat_dialog_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResourcesTabWidget extends StatefulWidget {
  const ResourcesTabWidget({super.key});

  @override
  State<ResourcesTabWidget> createState() => _ResourcesTabWidgetState();
}

class _ResourcesTabWidgetState extends State<ResourcesTabWidget> with SingleTickerProviderStateMixin {
  String? selectedConversationId;
  late TabController _tabController;
  bool _isLoading = false;
  List<Map<String, dynamic>> _allStudents = [];
  late ResourcesTabController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _controller = ResourcesTabController(context);
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

  void _showSoloChatOptions(String conversationId) {
    setState(() {
      selectedConversationId = conversationId;
    });

    ChatDialogWidgets.showSoloChatOptions(
      context: context,
      conversationId: conversationId,
      onDelete: (id) {
        _controller.deleteConversation(id);
      setState(() {
        selectedConversationId = null;
      });
      },
      onArchive: (id) {
        _controller.archiveChat(id);
        setState(() {
          selectedConversationId = null;
        });
      },
      onBlock: (id) {
              // Implement block functionality
        setState(() {
          selectedConversationId = null;
        });
      },
      );
  }

  void _showDeleteOptions(String conversationId, ChatConversation conversation) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final isTeacher = authController.appUser?.isTeacher ?? false;
    final isCreator = conversation.participantId == authController.currentUser?.uid;
    
    setState(() {
      selectedConversationId = conversationId;
    });

    ChatDialogWidgets.showCommunityOptions(
      context: context,
      conversationId: conversationId,
      conversation: conversation.toConversationModel(),
      isTeacher: isTeacher,
      isCreator: isCreator,
      onDelete: (id) {
        _controller.deleteConversation(id);
        setState(() {
          selectedConversationId = null;
        });
      },
      onLeave: (id) {
        _controller.leaveCommunity(id);
        setState(() {
          selectedConversationId = null;
        });
      },
      onMute: (id) {
        _controller.muteNotifications(id);
        setState(() {
          selectedConversationId = null;
        });
      },
      onManageMembers: (conversation) async {
        final authController = Provider.of<AuthController>(context, listen: false);
        final students = await authController.getAllStudents();
    
        if (!mounted) return;
    
        await ChatDialogWidgets.showManageMembersDialog(
          context: context,
          conversation: conversation,
          students: students,
          currentMembers: [conversation.members.first],
          onUpdateMembers: (communityId, memberIds) {
            _controller.updateCommunityMembers(
              communityId: communityId,
              memberIds: memberIds,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'MY CHATS'),
            Tab(text: 'COMMUNITIES'),
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
              ChatListWidget(
                selectedConversationId: selectedConversationId,
                onShowSoloChatOptions: _showSoloChatOptions,
                onShowDeleteOptions: _showDeleteOptions,
              ),
              _buildCommunitiesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunitiesTab() {
    final chatController = Provider.of<ChatController>(context);
    
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chatController.getUserCommunitiesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final communities = snapshot.data ?? [];
        
        if (communities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_off,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No communities yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Join a community or create a new one',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          itemCount: communities.length,
          itemBuilder: (context, index) {
            final community = communities[index];
            final isSelected = selectedConversationId == community['id'];
            final communityId = community['id'] as String;
            
            // For each community, check if it has media content
            return StreamBuilder<List<Map<String, dynamic>>>(
              stream: chatController.getCommunityMediaMessagesStream(communityId),
              builder: (context, messagesSnapshot) {
                // If still loading or has error, show a placeholder
                if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox.shrink();
                }
                
                final mediaMessages = messagesSnapshot.data ?? [];
                // Skip communities without media messages
                if (mediaMessages.isEmpty) {
                  return const SizedBox.shrink();
                }
                
                // This community has media, show it in the list
                return InkWell(
                  onLongPress: () {
                    final conversationModel = ChatConversation(
                      id: communityId,
                      participantId: community['createdBy'] as String,
                      participantName: community['name'] as String,
                      lastMessage: community['lastMessage'] as String? ?? '',
                      lastMessageTime: (community['lastMessageAt'] as Timestamp).toDate(),
                      hasUnreadMessages: ((community['unreadCount'] as int?) ?? 0) > 0,
                      isGroup: true,
                    );
                    _showDeleteOptions(communityId, conversationModel);
                  },
                  child: Container(
                    color: isSelected ? Colors.grey.withOpacity(0.1) : Colors.transparent,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (community['name'] as String).substring(0, 1).toUpperCase(),
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(child: Text(community['name'] as String, overflow: TextOverflow.ellipsis)),
                          const SizedBox(width: 4),
                          Icon(Icons.insert_drive_file, size: 16, color: Colors.grey[600]),
                        ],
                      ),
                      subtitle: Text('${mediaMessages.length} media resources'),
                      trailing: community['unreadCount'] != null && (community['unreadCount'] as int) > 0
                        ? Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${community['unreadCount']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : null,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ResourceCommunityChatScreen(
                              communityId: communityId,
                              communityName: community['name'] as String,
                              memberIds: (community['members'] as List<dynamic>).cast<String>(),
                              imageUrl: community['imageUrl'] as String?,
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
      },
    );
  }
}