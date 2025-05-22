import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:acumen/features/dashboard/widgets/community_card_widget.dart';
import 'package:acumen/features/dashboard/widgets/members_dialog_widget.dart';

class CommunitiesTabWidget extends StatelessWidget {
  const CommunitiesTabWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatController>(
      builder: (context, chatController, child) {
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
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.group_off,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No communities yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Create a new community to start chatting',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Community Types:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.lock, size: 16, color: Colors.blue),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Private: You select which students to add',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.public, size: 16, color: Colors.green),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Public: Students can join on their own',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: communities.length,
              itemBuilder: (context, index) {
                final community = communities[index];
                return CommunityCardWidget(
                  community: community,
                  onDelete: () => _showDeleteCommunityConfirmation(context, community['id'] as String),
                  onEdit: () => _showEditCommunityDialog(context, community),
                  onViewMembers: () => MembersDialogWidget.show(context, community),
                );
              },
            );
          },
        );
      
      },
    );
  
  }

  void _showDeleteCommunityConfirmation(BuildContext context, String communityId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Community'),
        content: const Text('Are you sure you want to delete this community? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // Delete community
                await FirebaseFirestore.instance.collection('communities').doc(communityId).delete();
                
                // Delete all messages in the community
                final messagesQuery = await FirebaseFirestore.instance
                    .collection('community_messages')
                    .where('communityId', isEqualTo: communityId)
                    .get();
                    
                final batch = FirebaseFirestore.instance.batch();
                for (var doc in messagesQuery.docs) {
                  batch.delete(doc.reference);
                }
                await batch.commit();
                
                if (context.mounted) {
                  AppSnackbar.showSuccess(
                    context: context,
                    message: 'Community deleted successfully',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(
                    context: context,
                    message: 'Failed to delete community: $e',
                  );
                }
              }
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditCommunityDialog(BuildContext context, Map<String, dynamic> community) {
    final nameController = TextEditingController(text: community['name'] as String);
    final descriptionController = TextEditingController(
      text: community['description'] as String? ?? '',
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Community Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                AppSnackbar.showError(
                  context: context,
                  message: 'Community name cannot be empty',
                );
                return;
              }
              
              Navigator.pop(context);
              try {
                await FirebaseFirestore.instance
                    .collection('communities')
                    .doc(community['id'] as String)
                    .update({
                  'name': nameController.text.trim(),
                  'description': descriptionController.text.trim(),
                });
                
                if (context.mounted) {
                  AppSnackbar.showSuccess(
                    context: context,
                    message: 'Community updated successfully',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  AppSnackbar.showError(
                    context: context,
                    message: 'Failed to update community: $e',
                  );
                }
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
} 