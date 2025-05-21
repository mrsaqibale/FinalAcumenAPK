import 'package:flutter/material.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';
import 'package:acumen/theme/app_theme.dart';

class ChatDialogWidgets {
  static void showSoloChatOptions({
    required BuildContext context,
    required String conversationId,
    required Function(String) onDelete,
    required Function(String) onArchive,
    required Function(String) onBlock,
  }) {
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
                showDeleteConfirmation(context, conversationId, onDelete);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined, color: Colors.grey),
              title: const Text('Archive chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                onArchive(conversationId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined, color: Colors.orange),
              title: const Text('Block contact', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                showBlockConfirmation(context, conversationId, onBlock);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showDeleteConfirmation(
    BuildContext context,
    String conversationId,
    Function(String) onDelete,
  ) {
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
              onDelete(conversationId);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showBlockConfirmation(
    BuildContext context,
    String conversationId,
    Function(String) onBlock,
  ) {
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
              onBlock(conversationId);
            },
            child: const Text('BLOCK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showCommunityOptions({
    required BuildContext context,
    required String conversationId,
    required ConversationModel conversation,
    required bool isTeacher,
    required bool isCreator,
    required Function(String) onDelete,
    required Function(String) onLeave,
    required Function(String) onMute,
    required Function(ConversationModel) onManageMembers,
  }) {
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
            if (isTeacher && isCreator)
              ListTile(
                leading: const Icon(Icons.group, color: Colors.blue),
                title: const Text('Manage members', style: TextStyle(fontSize: 16)),
                onTap: () {
                  Navigator.pop(context);
                  onManageMembers(conversation);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete community chat', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                showCommunityDeleteConfirmation(context, conversationId, onDelete);
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.orange),
              title: const Text('Leave community', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                showLeaveCommunityConfirmation(context, conversationId, onLeave);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_off_outlined, color: Colors.grey),
              title: const Text('Mute notifications', style: TextStyle(fontSize: 16)),
              onTap: () {
                Navigator.pop(context);
                onMute(conversationId);
              },
            ),
          ],
        ),
      ),
    );
  }

  static void showCommunityDeleteConfirmation(
    BuildContext context,
    String conversationId,
    Function(String) onDelete,
  ) {
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
              onDelete(conversationId);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static void showLeaveCommunityConfirmation(
    BuildContext context,
    String conversationId,
    Function(String) onLeave,
  ) {
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
            onPressed: () {
              Navigator.pop(context);
              onLeave(conversationId);
            },
            child: const Text('LEAVE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  static Future<void> showManageMembersDialog({
    required BuildContext context,
    required ConversationModel conversation,
    required List<Map<String, dynamic>> students,
    required List<String> currentMembers,
    required Function(String, List<String>) onUpdateMembers,
  }) async {
    List<String> selectedUsers = List.from(currentMembers);
    
    await showDialog(
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
                        onPressed: () {
                          Navigator.pop(context);
                          onUpdateMembers(conversation.id, selectedUsers);
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
} 