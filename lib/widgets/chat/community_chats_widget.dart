import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';
import 'package:acumen/features/chat/models/conversation_extension.dart';
import 'package:acumen/features/chat/screens/chat_detail_screen.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/widgets/chat/chat_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../theme/app_theme.dart';
import '../../features/chat/controllers/chat_controller.dart';
import '../../features/chat/models/conversation_model.dart';
import '../../features/chat/screens/community_chat_screen.dart';

class CommunityChatsWidget extends StatefulWidget {
  const CommunityChatsWidget({super.key});

  @override
  State<CommunityChatsWidget> createState() => _CommunityChatsWidgetState();
}

class _CommunityChatsWidgetState extends State<CommunityChatsWidget> {
  String? selectedConversationId;
  bool _showJoinableCommunities = false;

  @override
  void initState() {
    super.initState();
    // Load available communities that user can join
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatController = Provider.of<ChatController>(context, listen: false);
      chatController.fetchAvailableCommunities();
    });
  }

  void _showDeleteOptions(String conversationId, ConversationModel conversation) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final isTeacher = authController.appUser?.isTeacher ?? false;
    final isCreator = conversation.createdBy == authController.currentUser?.uid;
    
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
            if (isTeacher && isCreator) ...[
              ListTile(
                leading: const Icon(Icons.group, color: Colors.blue),
                title: const Text('Manage members', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  _showManageMembersDialog(conversation);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete community chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.orange),
              title: const Text('Leave community', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _leaveCommunity(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined, color: Colors.grey),
              title: const Text('Mute notifications', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                _muteNotifications(conversationId);
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

  void _showManageMembersDialog(ConversationModel conversation) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);
    
    // Get all students
    List<Map<String, dynamic>> students = await authController.getAllStudents();
    List<String> currentMembers = conversation.members;
    List<String> selectedUsers = List.from(currentMembers);
    
    if (!mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Manage Members: ${conversation.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        final userId = student['id'] as String;
                        final isSelected = selectedUsers.contains(userId);
                        
                        return CheckboxListTile(
                          title: Text(student['name'] ?? 'Unknown'),
                          subtitle: Text(student['rollNumber'] ?? student['email'] ?? ''),
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedUsers.add(userId);
                              } else {
                                selectedUsers.remove(userId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        onPressed: () async {
                          // Update community members
                          final success = await chatController.updateCommunityMembers(
                            communityId: conversation.id,
                            memberIds: selectedUsers,
                          );
                          
                          if (success && context.mounted) {
                            Navigator.pop(context);
                            AppSnackbar.showSuccess(
                              context: context,
                              message: 'Community members updated',
                            );
                          }
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteConfirmation(String conversationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this community chat?'),
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
                message: 'Community chat deleted',
              );
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _leaveCommunity(String conversationId) {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave this community?'),
        content: const Text('You won\'t receive messages from this community anymore.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Implement leave functionality
              final success = await chatController.leaveCommunity(
                communityId: conversationId,
                userId: authController.currentUser!.uid,
              );
              
              if (success) {
              AppSnackbar.showInfo(
                context: context,
                message: 'You left the community',
              );
              }
            },
            child: const Text('LEAVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _muteNotifications(String conversationId) {
    // Implement mute functionality
    AppSnackbar.showInfo(
      context: context,
      message: 'Notifications muted',
    );
  }

  void _joinCommunity(String communityId) async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final chatController = Provider.of<ChatController>(context, listen: false);
    
    final success = await chatController.joinCommunity(
      communityId: communityId,
      userId: authController.currentUser!.uid,
    );
    
    if (success) {
      AppSnackbar.showSuccess(
        context: context,
        message: 'You joined the community',
      );
      
      setState(() {
        _showJoinableCommunities = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
        if (chatController.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Text(
                    _showJoinableCommunities ? 'Available Communities' : 'My Communities',
                    style: const TextStyle(
                fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showJoinableCommunities = !_showJoinableCommunities;
                      });
                    },
                    icon: Icon(
                      _showJoinableCommunities ? Icons.group : Icons.group_add,
                      color: AppTheme.primaryColor,
                    ),
                    label: Text(
                      _showJoinableCommunities ? 'My Communities' : 'Join Communities',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _showJoinableCommunities
                  ? _buildAvailableCommunities(chatController.availableCommunities)
                  : StreamBuilder<List<Map<String, dynamic>>>(
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
                            final isMentorOnly = (community['description'] as String?)?.contains('mentor-only') ?? false;
                            
                            final conversationModel = ConversationModel(
                              id: community['id'] as String,
                              name: community['name'] as String,
                              description: community['description'] as String?,
                              members: (community['members'] as List<dynamic>).cast<String>(),
                              createdBy: community['createdBy'] as String,
                              createdAt: (community['createdAt'] as Timestamp).toDate(),
                              lastMessageAt: (community['lastMessageAt'] as Timestamp).toDate(),
                              isGroup: true,
                              unreadCount: (community['unreadCount'] as int?) ?? 0,
                              lastMessage: community['lastMessage'] as String?,
                              lastMessageSender: community['lastMessageSender'] as String?,
                              imageUrl: community['imageUrl'] as String?,
                            );
            
            return InkWell(
                              onLongPress: () => _showDeleteOptions(community['id'], conversationModel),
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
                                      Expanded(child: Text(community['name'] as String)),
                                      if (isMentorOnly)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Mentor',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.primaryColor,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(community['lastMessage'] as String? ?? 'No messages yet'),
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
                                        builder: (context) => CommunityChatScreen(
                                          communityId: community['id'] as String,
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
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAvailableCommunities(List<ConversationModel> communities) {
    if (communities.isEmpty) {
      return const Center(
        child: Text(
          'No available communities to join',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            title: Text(community.name),
            subtitle: Text(community.description ?? 'No description'),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _joinCommunity(community.id),
              child: const Text('Join'),
            ),
          ),
        );
      },
    );
  }
} 