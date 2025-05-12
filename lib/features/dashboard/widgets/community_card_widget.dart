import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/auth/controllers/auth_controller.dart';
import 'package:acumen/features/chat/screens/community_chat_screen.dart';
import 'package:acumen/theme/app_theme.dart';

class CommunityCardWidget extends StatelessWidget {
  final Map<String, dynamic> community;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onViewMembers;

  const CommunityCardWidget({
    Key? key,
    required this.community,
    required this.onDelete,
    required this.onEdit,
    required this.onViewMembers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final members = community['members'] as List<dynamic>;
    final lastMessage = community['lastMessage'] as String? ?? 'No messages yet';
    final lastMessageTime = community['lastMessageAt'] != null
        ? (community['lastMessageAt'] as Timestamp).toDate()
        : DateTime.now();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                (community['name'] as String).substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              community['name'] as String,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${members.length} members',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete();
                } else if (value == 'edit') {
                  onEdit();
                } else if (value == 'members') {
                  onViewMembers();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'members',
                  child: Row(
                    children: [
                      Icon(Icons.group, size: 20),
                      SizedBox(width: 8),
                      Text('View Members'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit Community'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Delete Community', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
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
          // Show members preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: Provider.of<AuthController>(context, listen: false).getUsersByIds(
                (community['members'] as List<dynamic>).cast<String>(),
              ),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 0);
                }
                
                final membersList = snapshot.data ?? [];
                if (membersList.isEmpty) {
                  return const SizedBox(height: 0);
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Members:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: membersList.length > 10 ? 10 : membersList.length,
                        itemBuilder: (context, index) {
                          final member = membersList[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Tooltip(
                              message: member['name'] as String,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: member['role'] == 'mentor' 
                                    ? AppTheme.primaryColor 
                                    : Colors.grey.shade200,
                                child: Text(
                                  (member['name'] as String).substring(0, 1).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: member['role'] == 'mentor' ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (membersList.length > 10)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${membersList.length - 10} more',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 