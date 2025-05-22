import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:acumen/features/chat/controllers/chat_controller.dart';
import 'package:acumen/features/chat/models/conversation_model.dart';
import 'package:acumen/theme/app_theme.dart';
import 'package:acumen/utils/app_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicCommunitiesTabWidget extends StatelessWidget {
  const PublicCommunitiesTabWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final chatController = Provider.of<ChatController>(context);
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return chatController.isLoading
        ? const Center(child: CircularProgressIndicator())
        : chatController.availableCommunities.isEmpty
            ? _buildEmptyState(context)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chatController.availableCommunities.length,
                itemBuilder: (context, index) {
                  final community = chatController.availableCommunities[index];
                  return _buildCommunityCard(context, community, userId, chatController);
                },
              );
  }

  Widget _buildEmptyState(BuildContext context) {
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
            'No public communities available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'All available communities have been joined',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Provider.of<ChatController>(context, listen: false).fetchAvailableCommunities();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityCard(
    BuildContext context,
    ConversationModel community,
    String userId,
    ChatController chatController,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    community.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        community.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (community.description != null && community.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            community.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${community.members.length} members',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _joinCommunity(context, community.id, userId),
                icon: const Icon(Icons.person_add),
                label: const Text('Join Community'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 40),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinCommunity(BuildContext context, String communityId, String userId) async {
    try {
      final chatController = Provider.of<ChatController>(context, listen: false);
      
      final success = await chatController.joinCommunity(
        communityId: communityId,
        userId: userId,
      );
      
      if (success && context.mounted) {
        AppSnackbar.showSuccess(
          context: context,
          message: 'Successfully joined the community',
        );
        
        // Refresh available communities
        chatController.fetchAvailableCommunities();
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context: context,
          message: 'Failed to join community: $e',
        );
      }
    }
  }
} 